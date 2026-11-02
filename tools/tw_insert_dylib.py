#!/usr/bin/env python3
"""
tw_insert_dylib.py — инжектор LC_LOAD_DYLIB в Mach-O (arm64) бинарник.
Питон-порт insert_dylib (Tyilo) для Windows-сборки без host-компилятора.

Реализованы ДВА пути:
  1. PADDING: если после load commands есть достаточно нулей — вписать туда (смещения не трогаем).
  2. EXTEND (по умолчанию для TikTok): сдвинуть всё, что после load commands, на размер новой LC
     с выравниванием. При этом:
       - все cmdsize-смещения самих load commands не меняются (они до точки вставки)
       - LC_SEGMENT_64 (__TEXT/__LINKEDIT) file offsets сдвигаются на delta
       - LC_CODE_SIGNATURE / DYLD_INFO / FUNCTION_STARTS / DATA_IN_CODE offsets сдвигаются
       - LC_ENCRYPTION_INFO_64.cryptoff сдвигается
       - vmsize/vmaddr НЕ трогаем (виртуальная память не меняется, только file layout)
     ВАЖНО: сегмент __TEXT содержит код, зашитый по file offsets. Сдвиг file offset
     требует перезаливки. insert_dylib делает именно это и затем dyld+AMFI требуют
     пересоздания кодовой сигнатуры (ldid -S после инжекта решает).
"""
import struct, sys, shutil, os

LC_SEGMENT_64 = 0x19
LC_LOAD_DYLIB = 0xC
LC_CODE_SIGNATURE = 0x1D
LC_DYLD_INFO = 0x22
LC_DYLD_INFO_ONLY = 0x80000022
LC_FUNCTION_STARTS = 0x26
LC_DATA_IN_CODE = 0x29
LC_ENCRYPTION_INFO_64 = 0x2C
LC_DYLD_CHAINED_FIXUPS = 0x80000034
LC_DYLD_EXPORTS_TRIE = 0x80000033
MH_MAGIC_64 = 0xFEEDFACF
CPU_TYPE_ARM64 = 0x0100000C

def align(v, a=8):
    return (v + a - 1) & ~(a - 1)

def make_load_dylib(path: str) -> bytes:
    p = path.encode() + b'\0'
    cmdsize = 24 + len(p)
    cmdsize = align(cmdsize, 8)
    p = p + b'\0' * (cmdsize - 24 - len(p))
    return struct.pack('<IIIIII', LC_LOAD_DYLIB, cmdsize, 24, 2, 0, 0) + p

def inject(mach: bytes, dylib_path: str) -> bytes:
    (magic, cputype, cpusub, filetype, ncmds,
     sizeofcmds, flags, reserved) = struct.unpack('<IiiIIIII', mach[:32])
    assert magic == MH_MAGIC_64, f'not mach-o 64: {magic:#x}'

    # уже есть?
    off = 32
    for _ in range(ncmds):
        cmd, cmdsize = struct.unpack('<II', mach[off:off+8])
        if cmd == LC_LOAD_DYLIB:
            lc_str = struct.unpack('<I', mach[off+8:off+12])[0]
            name = mach[off+lc_str:off+cmdsize].split(b'\0')[0].decode()
            if name == dylib_path:
                print(f'  [skip] LC_LOAD_DYLIB "{dylib_path}" already present')
                return mach
        off += cmdsize

    new_cmd = make_load_dylib(dylib_path)
    end_of_cmds = 32 + sizeofcmds

    # --- путь 1: padding
    pad = 0
    i = end_of_cmds
    while i < len(mach) and mach[i] == 0 and pad < 8192:
        pad += 1
        i += 1
    if pad >= len(new_cmd):
        out = bytearray(mach)
        out[end_of_cmds:end_of_cmds] = new_cmd
        struct.pack_into('<I', out, 16, ncmds + 1)
        struct.pack_into('<I', out, 20, sizeofcmds + len(new_cmd))
        print(f'  [padding] inserted {len(new_cmd)} bytes into {pad}-byte pad')
        return bytes(out)

    # --- путь 2: extend со сдвигом
    delta = len(new_cmd)
    out = bytearray(mach[:end_of_cmds])
    out += new_cmd
    out += mach[end_of_cmds:]

    # 2a. сдвиг file-offset полей в load commands (только КОМАНДЫ; сами они до вставки)
    def shift_u32(pos, add):
        v = struct.unpack_from('<I', out, pos)[0]
        if v != 0 or True:
            struct.pack_into('<I', out, pos, v + add)

    off = 32
    for _ in range(ncmds):
        cmd, cmdsize = struct.unpack('<II', out[off:off+8])
        base = off
        if cmd == LC_SEGMENT_64:
            segname = out[base+8:base+24].split(b'\0')[0].decode()
            # fileoff (base+40), filesize не меняем; но если fileoff >= end_of_cmds — сдвиг
            fileoff = struct.unpack_from('<Q', out, base+40)[0]
            if fileoff >= end_of_cmds:
                struct.pack_into('<Q', out, base+40, fileoff + delta)
            # nsects
            nsects = struct.unpack_from('<I', out, base+64)[0]
            sect = base + 72
            for s_i in range(nsects):
                s_off = sect + s_i * 80
                offset_field = s_off + 48  # section 64: offset uint32
                soff = struct.unpack_from('<I', out, offset_field)[0]
                if soff >= end_of_cmds:
                    struct.pack_into('<I', out, offset_field, soff + delta)
                # reloff
                reloff_field = s_off + 64
                roff = struct.unpack_from('<I', out, reloff_field)[0]
                if roff >= end_of_cmds and roff != 0:
                    struct.pack_into('<I', out, reloff_field, roff + delta)
        elif cmd in (LC_CODE_SIGNATURE, LC_FUNCTION_STARTS, LC_DATA_IN_CODE):
            # struct: cmd, cmdsize, dataoff, datasize
            d = struct.unpack_from('<I', out, base+8+4)[0]
            if d >= end_of_cmds:
                struct.pack_into('<I', out, base+8+4, d + delta)
        elif cmd in (LC_DYLD_INFO, LC_DYLD_INFO_ONLY):
            # cmd, cmdsize, reloff, relosz, locreoff, locresz, exptoff, exptsz
            for fo in (base+8, base+16, base+24):
                d = struct.unpack_from('<I', out, fo)[0]
                if d >= end_of_cmds and d != 0:
                    struct.pack_into('<I', out, fo, d + delta)
        elif cmd == LC_ENCRYPTION_INFO_64:
            # cmd, cmdsize, cryptoff, cryptsize, cryptid, pad
            d = struct.unpack_from('<I', out, base+8)[0]
            if d >= end_of_cmds:
                struct.pack_into('<I', out, base+8, d + delta)
        elif cmd == LC_DYLD_CHAINED_FIXUPS or cmd == LC_DYLD_EXPORTS_TRIE:
            # 0x80000034: cmd, cmdsize, dataoff, datasize
            d = struct.unpack_from('<I', out, base+8)[0]
            if d >= end_of_cmds and d != 0:
                struct.pack_into('<I', out, base+8, d + delta)
        off += cmdsize

    # 2b. обновить заголовок
    struct.pack_into('<I', out, 16, ncmds + 1)
    struct.pack_into('<I', out, 20, sizeofcmds + delta)
    print(f'  [extend] inserted {delta} bytes, shifted file offsets by {delta}')
    return bytes(out)

def main():
    if len(sys.argv) < 3:
        print('usage: tw_insert_dylib.py <binary> <@rpath/dylib-path>')
        sys.exit(1)
    binary, dylib = sys.argv[1], sys.argv[2]
    backup = binary + '.twbak'
    if not os.path.exists(backup):
        shutil.copy(binary, backup)
    with open(backup, 'rb') as f:
        data = f.read()

    magic_be = struct.unpack('>I', data[:4])[0]
    if magic_be == 0xCAFEBABE:
        # fat (unlikely for arm64-store build, but handle)
        nfat = struct.unpack('>I', data[4:8])[0]
        out = bytearray(data)
        for i in range(nfat):
            rec = 8 + i * 20
            cputype = struct.unpack('>I', data[rec:rec+4])[0]
            offset, size = struct.unpack('>II', data[rec+8:rec+16])
            if cputype == CPU_TYPE_ARM64:
                thin = data[offset:offset+size]
                patched = inject(thin, dylib)
                out[offset:offset+len(patched)] = patched
        with open(binary, 'wb') as f:
            f.write(bytes(out))
    else:
        patched = inject(data, dylib)
        with open(binary, 'wb') as f:
            f.write(patched)
    print(f'  done: {binary} (backup {backup})')

if __name__ == '__main__':
    main()
