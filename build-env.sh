#!/usr/bin/env bash
# build-env.sh — окружение сборки TweryTok на Windows (Git Bash + theos C:\theos)
# Источник тулчейна: CacheW/TheosWin (LLVM 19, ld64.lld), ldid: ProcursusTeam
# Использование: source build-env.sh
export THEOS=/c/theos
export PATH="$THEOS/bin:$THEOS/toolchain/windows/iphone/bin:$PATH"
# Отключить MSYS-конвертацию путей для аргументов линкера (иначе /usr/lib → C:/Program Files/Git/usr/lib)
export MSYS2_ARG_CONV_EXCL="-install_name;-dylib_install_name;/Library;/var;/usr;-e"
