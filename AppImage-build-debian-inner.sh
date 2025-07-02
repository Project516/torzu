#! /bin/bash
set -e

# Make sure script is called from inside our container
test -e /tmp/torzu-src-ro || (echo "Script MUST NOT be called directly!" ; exit 1)

# Set up environment
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
unset LC_ADDRESS LC_NAME LC_MONETARY LC_PAPER LC_TELEPHONE LC_MEASUREMENT LC_TIME

# Raise max open files count
ulimit -n 50000

# Install dependencies
apt -y install cmake ninja-build build-essential autoconf pkg-config locales wget git file mold libtool lsb-release wget software-properties-common gnupg \
               glslang-tools libssl-dev libavcodec-dev libavfilter-dev libavutil-dev libswscale-dev libpulse-dev libasound2-dev libudev-dev libice6
if [ "$BUILD_QT" = 1 ]; then
    apt -y install libxcb-composite0-dev libxcb-damage0-dev libxcb-dpms0-dev libxcb-dri2-0-dev libxcb-dri3-dev libxcb-ewmh-dev libxcb-present-dev libxcb-record0-dev libxcb-res0-dev libxcb-screensaver0-dev libxcb-xf86dri0-dev libxcb-xtest0-dev libxcb-xv0-dev libxcb-xvmc0-dev libfontconfig1-dev libfreetype6-dev libx11-dev libx11-xcb-dev libxext-dev libxfixes-dev libxi-dev libxrender-dev libxcb1-dev libxcb-cursor-dev libxcb-glx0-dev libxcb-keysyms1-dev libxcb-image0-dev libxcb-shm0-dev libxcb-icccm4-dev libxcb-sync-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-randr0-dev libxcb-render-util0-dev libxcb-util-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev libgl-dev
else
    apt -y install qt6-base-dev qt6-base-private-dev qt6-multimedia-dev qt6-qpa-plugins
fi
if [ ! "$BUILD_USE_CPM" = 1 ]; then
    apt -y install libfmt-dev libenet-dev liblz4-dev nlohmann-json3-dev zlib1g-dev libopus-dev libsimpleini-dev libstb-dev libzstd-dev libusb-1.0-0-dev libcubeb-dev libcpp-jwt-dev libvulkan-dev gamemode-dev libasound2-dev libglu1-mesa-dev libxext-dev mesa-common-dev libva-dev

    if [ ! -f /usr/local/lib/cmake/Boost-1.88.0/BoostConfigVersion.cmake ]; then
        # Install Boost
        wget https://archives.boost.io/release/1.88.0/source/boost_1_88_0.tar.bz2
        echo "Extracting Boost sources..."
        tar xf boost_1_88_0.tar.bz2
        cd boost_1_88_0
        ./bootstrap.sh
        ./b2 install --with-{headers,context,system,fiber,atomic,filesystem} link=static
        cd ..
        rm -rf boost_1_88_0 boost_1_88_0.tar.bz2
    fi
fi

# Install Clang
if ([ "$BUILD_USE_CLANG" = 1 ] && ! clang-19 --version); then
    cd /tmp
    wget https://apt.llvm.org/llvm.sh
    chmod +x llvm.sh
    ./llvm.sh 19
    rm llvm.sh
fi

# Mount Torzu sources with temporary overlay
cd /tmp
mkdir torzu-src-upper torzu-src-work torzu-src
mount -t overlay overlay -olowerdir=torzu-src-ro,upperdir=torzu-src-upper,workdir=torzu-src-work torzu-src

# Get extra configuration/compilation options
EXTRA_COMPILE_FLAGS=""
EXTRA_CMAKE_FLAGS=""
if [ "$BUILD_USE_CLANG" = 1 ]; then
    export CC=clang-19 CXX=clang++-19
    EXTRA_CMAKE_FLAGS="-DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX"
    EXTRA_COMPILE_FLAGS="-fuse-ld=lld-19 -Wno-unused-command-line-argument"
    FATLTO_FLAG="-flto=full"
else
    FATLTO_FLAG="-flto"
fi
if [ "$BUILD_USE_THIN_LTO" = 1 ]; then
    EXTRA_COMPILE_FLAGS="$EXTRA_COMPILE_FLAGS -flto=thin"
fi
if [ "$BUILD_USE_FAT_LTO" = 1 ]; then
    EXTRA_COMPILE_FLAGS="$EXTRA_COMPILE_FLAGS $FATLTO_FLAG"
fi
if [ "$BUILD_USE_CPM" = 1 ]; then
    EXTRA_CMAKE_FLAGS="$EXTRA_CMAKE_FLAGS -DYUZU_USE_CPM=ON"
fi
if [ "$BUILD_QT" = 1 ]; then
    EXTRA_CMAKE_FLAGS="$EXTRA_CMAKE_FLAGS -DYUZU_BUILD_QT6=ON"
    if [ "$BUILD_PREFER_STATIC" = 1 ]; then
        EXTRA_CMAKE_FLAGS="$EXTRA_CMAKE_FLAGS -DYUZU_BUILD_QT6_STATIC=ON"
    fi
fi
if [ "$BUILD_PREFER_STATIC" = 1 ]; then
    EXTRA_CMAKE_FLAGS="$EXTRA_CMAKE_FLAGS -DBUILD_SHARED_LIBS=OFF -DCMAKE_FIND_LIBRARY_SUFFIXES=.a;.so"
fi

# Build Torzu
cd /tmp
mkdir torzu-build
cd torzu-build
cmake /tmp/torzu-src -GNinja -DCMAKE_BUILD_TYPE=Release -DYUZU_TESTS=OFF -DENABLE_QT_TRANSLATION=OFF -DSPIRV_WERROR=OFF -DSPIRV-Headers_SOURCE_DIR=/tmp/torzu-src/externals/SPIRV-Headers -DCMAKE_{C,CXX}_FLAGS="$EXTRA_COMPILE_FLAGS -fdata-sections -ffunction-sections" -DCMAKE_{EXE,SHARED}_LINKER_FLAGS="-Wl,--gc-sections" $EXTRA_CMAKE_FLAGS
ninja || (
    echo "Compilation has failed. Dropping you into a shell so you can inspect the situation. Run 'ninja' to retry and exit shell once compilation has finished successfully."
    echo "Note that any changes made here will not be reflected to the host environment."
    bash
)

# Generate AppImage
cp -rv /tmp/torzu-src/AppImageBuilder /tmp/AppImageBuilder
cd /tmp/AppImageBuilder
./build.sh /tmp/torzu-build /tmp/torzu.AppImage || echo "This error is known. Using workaround..."
cp /lib/$(uname -m)-linux-gnu/libICE.so.6 build/
mv build /tmp/hosttmp/torzu-debian-appimage-rootfs
