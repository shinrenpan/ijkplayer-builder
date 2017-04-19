set -e

CLONE_PATH="${HOME}/Downloads/ijkplayer"
FRAMEWORK_NAME="IJKMediaFramework"
VERSION="k0.7.6"

do_clone_and_checkout()
{
    if [ -d ${CLONE_PATH} ]; then
        rm -rf ${CLONE_PATH}
    fi

    git clone "https://github.com/Bilibili/ijkplayer.git" ${CLONE_PATH}
    cd ${CLONE_PATH}
    git checkout -B latest ${VERSION}
}

do_run_ijkplayer_script()
{
    cd ${CLONE_PATH}
    ./init-ios.sh
    cd ios
    ./compile-ffmpeg.sh clean
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
    lipo -create -output "${HOME}/Desktop/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" "build/Release-iphoneos/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" "build/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"

    # 修改版本號
    /usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString ${VERSION}" "${HOME}/Desktop/${FRAMEWORK_NAME}.framework/Info.plist"

    if [ -d ${CLONE_PATH} ]; then
        rm -rf ${CLONE_PATH}
    fi
}

do_clone_and_checkout
do_run_ijkplayer_script
do_build_device_framework
do_build_simulator_framework
do_lipo_framework
