#!/usr/bin/env bash
# ============================================================================
# build_ipa.sh — локальная сборка TweryTok_Modded.ipa на Windows (Git Bash).
# Пайплайн повторяет шаг inject из .github/workflows/build.yml, но полностью
# локально: theos (C:\theos), python-инжектор вместо insert_dylib (нет host-clang),
# PowerShell Compress-Archive вместо zip.
#
# Использование:
#   source build-env.sh          # окружение theos
#   bash build_ipa.sh            # собрать dylib + инжект + запаковать
#
# Переменные:
#   TIKTOK_IPA_PATH — путь к декриптованной TikTok IPA (по умолчанию качается
#                     base-ipa 47.5.0 из репо TweakiTok — тот же fallback, что в CI)
#   WORK_DIR        — рабочая папка (по умолчанию /d/twerytok-build)
# ============================================================================
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="${WORK_DIR:-/d/twerytok-build}"
BASE_IPA_URL="https://github.com/talhaeenss/TweakiTok/releases/download/base-ipa-47.5.0/com.zhiliaoapp.musically-47.5.0-Decrypted.ipa"
SUBSTRATE_DEB_URL="https://apt.bingner.com/debs/1443.00/mobilesubstrate_0.9.7113_iphoneos-arm.deb"

echo "==> [1/8] сборка dylib (theos, arm64)"
cd "$REPO_DIR"
[ -n "$THEOS" ] || { echo "ошибка: сначала source build-env.sh"; exit 1; }
ARCHS=arm64 make clean >/dev/null 2>&1 || true
ARCHS=arm64 make
DYLIB="$REPO_DIR/.theos/obj/debug/arm64/TweryTok.dylib"
[ -f "$DYLIB" ] || { echo "ошибка: dylib не собран"; exit 1; }
echo "    dylib: $DYLIB ($(stat -c%s "$DYLIB") bytes)"

mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "==> [2/8] базовая IPA"
if [ -n "$TIKTOK_IPA_PATH" ] && [ -f "$TIKTOK_IPA_PATH" ]; then
    echo "    использую $TIKTOK_IPA_PATH"
    cp "$TIKTOK_IPA_PATH" "$WORK_DIR/base.ipa"
elif [ -f "$WORK_DIR/base.ipa" ]; then
    echo "    использую ранее скачанную $WORK_DIR/base.ipa"
else
    echo "    качаю $BASE_IPA_URL"
    curl -L "$BASE_IPA_URL" -o "$WORK_DIR/base.ipa"
fi

echo "==> [3/8] распаковка"
rm -rf "$WORK_DIR/extracted"
unzip -q -o "$WORK_DIR/base.ipa" -d "$WORK_DIR/extracted"
APP="$WORK_DIR/extracted/Payload/TikTok.app"
[ -d "$APP" ] || { echo "ошибка: Payload/TikTok.app не найден"; exit 1; }
BINARY="$APP/TikTok"
echo "    app: $APP (TikTok $(python -c "
import plistlib
with open('$APP/Info.plist','rb') as f: print(plistlib.load(f).get('CFBundleShortVersionString','?'))
"))"

echo "==> [4/8] substrate (CydiaSubstrate внутрь IPA)"
if [ ! -f "$WORK_DIR/usr/lib/libsubstrate.dylib" ]; then
    curl -sL "$SUBSTRATE_DEB_URL" -o "$WORK_DIR/sub.deb"
    python << 'PYEOF'
import io, lzma, tarfile, os
with open(os.environ.get('WORK_DIR', r'D:\twerytok-build') + r'\sub.deb', 'rb') as f:
    data = f.read()
assert data[:8] == b'!<arch>\n'
off = 8
while off + 60 <= len(data):
    hdr = data[off:off+60]
    name = hdr[0:16].decode().strip()
    size = int(hdr[48:58].decode().strip())
    body = data[off+60:off+60+size]
    if name.startswith('data.tar'):
        try:
            tar_bytes = lzma.LZMADecompressor(format=lzma.FORMAT_XZ).decompress(body)
        except Exception:
            tar_bytes = lzma.LZMADecompressor(format=lzma.FORMAT_ALONE).decompress(body)
        tarfile.open(fileobj=io.BytesIO(tar_bytes)).extractall(os.environ.get('WORK_DIR', r'D:\twerytok-build'))
    off += 60 + size
    if off % 2 == 1: off += 1
print('    substrate extracted')
PYEOF
fi
cp "$WORK_DIR/usr/lib/libsubstrate.dylib" "$APP/Frameworks/libsubstrate.dylib"
chmod +x "$APP/Frameworks/libsubstrate.dylib"

echo "==> [5/8] копирование TweryTok.dylib + патч зависимостей"
cp "$DYLIB" "$APP/Frameworks/TweryTok.dylib"
chmod +x "$APP/Frameworks/TweryTok.dylib"
WORK_DIR_WIN="$(cygpath -w "$WORK_DIR")" python << 'PYEOF'
import struct, os
# 1) install_name TweryTok.dylib -> @rpath (theos ставит /Library/MobileSubstrate/...)
# 2) зависимость CydiaSubstrate -> @rpath/libsubstrate.dylib (substrate кладём рядом)
app = os.path.join(os.environ['WORK_DIR_WIN'], 'extracted', 'Payload', 'TikTok.app')
dylib = os.path.join(app, 'Frameworks', 'TweryTok.dylib')
with open(dylib, 'rb') as f:
    data = f.read()
out = bytearray(data)

def patch_cmds(buf):
    (magic, cputype, cpusub, filetype, ncmds, sizeofcmds, flags, reserved) = struct.unpack('<IiiIIIII', buf[:32])
    off = 32
    n = 0
    for _ in range(ncmds):
        cmd, cmdsize = struct.unpack('<II', bytes(buf[off:off+8]))
        if cmd in (0xC, 0xD):  # LC_LOAD_DYLIB / LC_ID_DYLIB
            lc_str = struct.unpack('<I', bytes(buf[off+8:off+12]))[0]
            old = bytes(buf[off+lc_str:off+cmdsize]).split(b'\0')[0]
            new = None
            if cmd == 0xD and b'MobileSubstrate' in old:
                new = b'@rpath/TweryTok.dylib\x00'
            elif cmd == 0xC and b'CydiaSubstrate' in old:
                new = b'@rpath/libsubstrate.dylib\x00'
            if new:
                seg = bytearray(cmdsize)
                seg[0:8] = struct.pack('<II', cmd, cmdsize)
                seg[8:24] = bytes(buf[off+8:off+24])
                seg[24:24+len(new)] = new
                buf[off:off+cmdsize] = seg
                print(f'    patched: {old.decode()} -> {new.decode()}')
                n += 1
        off += cmdsize
    return n

patch_cmds(out)
with open(dylib, 'wb') as f:
    f.write(bytes(out))
print('    TweryTok.dylib paths patched')
PYEOF

echo "==> [6/8] инжект LC_LOAD_DYLIB в TikTok"
python "$REPO_DIR/tools/tw_insert_dylib.py" "$BINARY" "@rpath/TweryTok.dylib"
rm -f "$BINARY.twbak"

echo "==> [7/8] подписи (ldid)"
(cd "$APP/Frameworks" && /c/theos/bin/ldid.exe -S TweryTok.dylib && /c/theos/bin/ldid.exe -S libsubstrate.dylib) || true

echo "==> [8/8] упаковка IPA"
rm -f "$WORK_DIR/TweryTok_Modded.ipa" "$WORK_DIR/ipa_payload.zip"
powershell.exe -Command "Compress-Archive -Path '$(cygpath -w "$WORK_DIR")\extracted\Payload' -DestinationPath '$(cygpath -w "$WORK_DIR")\ipa_payload.zip' -Force"
mv "$WORK_DIR/ipa_payload.zip" "$WORK_DIR/TweryTok_Modded.ipa"

echo ""
echo "=========== ГОТОВО ==========="
ls -lh "$WORK_DIR/TweryTok_Modded.ipa"
echo "Проверка:"
python -c "
import zipfile
z = zipfile.ZipFile(r'$(cygpath -w "$WORK_DIR")\TweryTok_Modded.ipa')
names = z.namelist()
for want in ['Payload/TikTok.app/Frameworks/TweryTok.dylib', 'Payload/TikTok.app/Frameworks/libsubstrate.dylib', 'Payload/TikTok.app/TikTok']:
    print(' ', 'OK' if want in names else 'MISSING!', want)
"
echo ""
echo "Установка: AltStore/Sideloadly/ESign → TweryTok_Modded.ipa (подпись сертификатом установщика)"
