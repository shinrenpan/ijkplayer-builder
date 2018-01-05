#!/bin/bash

set -e

DEFAULT_TARGET='master'
TARGET=${1:-$DEFAULT_TARGET}
CLONE_PATH="${HOME}/Downloads/ijkplayer"
FRAMEWORK_NAME="IJKMediaFramework"

do_clone_and_checkout()
{
    if [ -d ${CLONE_PATH} ]; then
        cd ${CLONE_PATH}
        git checkout master
        git pull    
    else
        git clone "https://github.com/Bilibili/ijkplayer.git" ${CLONE_PATH}
        cd ${CLONE_PATH}
    fi

    if git rev-parse $1 >/dev/null 2>&1; then
        printf "\n\n\033[1;37mStart build at branch(tag): ${TARGET}\033[0m\n\n"
        git checkout ${TARGET}
    else
        printf "\n\033[1;31mBuild fail no branch(tag): ${TARGET}\033[0m\n\n"
        exit 1
    fi
}

do_run_ijkplayer_script()
{
    cd ${CLONE_PATH}
    ./init-ios-openssl.sh
    ./init-ios.sh
    cd ios
    ./compile-openssl.sh clean
    ./compile-ffmpeg.sh clean
    ./compile-openssl.sh all
    ./compile-ffmpeg.sh all
}

# enable bitcode 參考 https://medium.com/@heitorburger/static-libraries-frameworks-and-bitcode-6d8f784478a9#.xq8m65w7y
# 編譯實機 framework
do_build_device_framework()
{
    cd IJKMediaPlayer
    xcodebuild -project "IJKMediaPlayer.xcodeproj" -target "${FRAMEWORK_NAME}" -configuration Release -arch arm64 -arch armv7 only_active_arch=no defines_module=yes -sdk iphoneos -OTHER_CFLAGS="-fembed-bitcode"

    if [ -d "${HOME}/Desktop/${FRAMEWORK_NAME}.framework" ]; then
        rm -rf "${HOME}/Desktop/${FRAMEWORK_NAME}.framework"
    fi

    cp -r "build/Release-iphoneos/${FRAMEWORK_NAME}.framework" "${HOME}/Desktop/${FRAMEWORK_NAME}.framework"
}

# 編譯模擬器 framework
do_build_simulator_framework()
{
    xcodebuild -project "IJKMediaPlayer.xcodeproj" -target "${FRAMEWORK_NAME}" -configuration Release -arch i386 -arch x86_64 only_active_arch=no VALID_ARCHS="i386 x86_64" -sdk iphonesimulator -OTHER_CFLAGS="-fembed-bitcode"
}

# 利用 lipo 組成 fat framewok 並放到桌面
do_lipo_framework()
{   
    libssl="${CLONE_PATH}/ios/build/universal/lib/libssl.a"

    if [ -f ${libssl} ]; then
        cp ${libssl} "${HOME}/Desktop"
    else
        printf "\n\033[1;31mMissing ${libssl}\033[0m\n\n"
        exit 1
    fi

    libcrypto="${CLONE_PATH}/ios/build/universal/lib/libcrypto.a"

    if [ -f ${libcrypto} ]; then
        cp ${libcrypto} "${HOME}/Desktop"
    else
        printf "\n\033[1;31mMissing ${libcrypto}\033[0m\n\n"
        exit 1
    fi

    lipo -create -output "${HOME}/Desktop/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" "build/Release-iphoneos/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" "build/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"

    # 修改版本號
    /usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString ${TARGET}" "${HOME}/Desktop/${FRAMEWORK_NAME}.framework/Info.plist"

    printf "\n\n\033[1;37mStart build at branch(tag): ${TARGET} Success!!!\033[0m\n\n"
}

do_clone_and_checkout
do_run_ijkplayer_script
do_build_device_framework
do_build_simulator_framework
do_lipo_framework
