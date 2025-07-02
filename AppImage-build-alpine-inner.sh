sudo bwrap --bind . / --ro-bind / /host --dev-bind /run /run --dev-bind /dev /dev --proc /proc --dev-bind /sys /sys --ro-bind /etc/resolv.conf /etc/resolv.conf --setenv PATH '/sbin:/bin:/usr/sbin:/usr/bin' --setenv HOME /root /bin/ash

apk add git gcc g++ yasm glslang cmake samurai make patch openssl-dev autoconf automake libtool libudev-zero-dev qt5-qtbase-dev qt5-qtmultimedia-dev glslang glslang-static libintl pulseaudio-dev alsa-lib-dev sndio-dev libxkbcommon-dev libunwind-dev ffmpeg-dev

ln -s /usr/lib /usr/lib64

cmake .. -DCMAKE_BUILD_TYPE=Release -DYUZU_USE_CPM=ON -DYUZU_TESTS=OFF -DENABLE_QT_TRANSLATION=OFF -DTZ_LINK_INTL=ON -GNinja




apk add linux-headers git gcc g++ cmake meson samurai make patch autoconf automake libtool pkgconf python3 gettext bison flex xrandr-dev xtrans util-macros gperf gettext-dev elfutils-dev

mkdir /static
mkdir /static/lib
ln -s /static/lib /static/lib64
mkdir /static/share
mkdir /static/lib/pkgconfig
ln -s /static/lib/pkgconfig /static/share/pkgconfig

python3 -m venv venv
. venv/bin/activate
pip install mako packaging PyYAML

export PREFIX=/static
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export PATH="$PREFIX/bin:$PATH"

git clone https://git.tukaani.org/xz.git --depth 1 --recursive
cd xz
./autogen.sh
./configure --prefix="$PREFIX" --enable-shared=no --enable-static=yes
make -j$(nproc)
make install
cd ..

git clone https://github.com/madler/zlib.git -b v1.3.1
cd zlib
prefix="$PREFIX" ./configure
make -j$(nproc)
make install
cd ..

git clone https://github.com/facebook/zstd.git --depth 1 --recursive -b v1.5.7
cd zstd
mkdir cmakebuild
cd cmakebuild
cmake ../build/cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" -DBUILD_SHARED_LIBS=OFF -DZSTD_BUILD_STATIC=ON -DZSTD_BUILD_TESTS=OFF -G Ninja
ninja install
cd ..
cd ..

git clone https://github.com/openssl/openssl.git --depth 1 --recursive -b openssl-3.5.0
cd openssl
./Configure --prefix="$PREFIX" --openssldir="$PREFIX/ssl" --static -static
make -j$(nproc)
make install
cd ..

git clone https://github.com/illiliti/libudev-zero.git --depth 1 --recursive -b 1.0.3
cd libudev-zero
make -j$(nproc) PREFIX="$PREFIX" install
cd ..

git clone https://github.com/llvm/llvm-project.git --depth 1 --recursive -b llvmorg-20.1.7
cd llvm-project
mkdir build
cd build
cmake ../llvm -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" -DBUILD_SHARED_LIBS=OFF -DLLVM_ENABLE_PROJECTS="clang;lld;libclc" -DLLVM_TARGETS_TO_BUILD=all -DLLVM_ENABLE_RUNTIMES="" -DLLVM_ENABLE_BINDINGS=OFF -DLLVM_INCLUDE_TESTS=OFF -DLLVM_INCLUDE_EXAMPLES=OFF -DLLVM_INCLUDE_BENCHMARKS=OFF -DLLVM_OPTIMIZED_TABLEGEN=ON -DBUILD_SHARED_LIBS=OFF -DCLANG_ENABLE_HLSL=ON -DCLANG_ENABLE_ARCMT=OFF -DCLANG_ENABLE_STATIC_ANALYZER=OFF -G Ninja
ninja install
cd ../..

git clone https://gitlab.freedesktop.org/xorg/lib/libpciaccess.git --depth 1 --recursive -b libpciaccess-0.18.1
cd libpciaccess
meson setup build --prefix "$PREFIX" -Ddefault_library=static
cd build
ninja install
cd ../..

git clone https://gitlab.freedesktop.org/mesa/libdrm.git --depth 1 --recursive -b libdrm-2.4.125
cd libdrm
meson setup build --prefix "$PREFIX" -Ddefault_library=static
cd build
ninja install
cd ../..

git clone https://github.com/KhronosGroup/SPIRV-Headers.git --depth 1 --recursive -b vulkan-sdk-1.4.313.0
cd SPIRV-Headers
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" -DBUILD_SHARED_LIBS=OFF -DSPIRV_HEADERS_ENABLE_TESTS=OFF -DSPIRV_HEADERS_ENABLE_INSTALL=ON -G Ninja
ninja install
cd ../..

git clone https://github.com/KhronosGroup/SPIRV-LLVM-Translator.git --depth 1 --recursive -b v20.1.3
cd SPIRV-LLVM-Translator
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" -DBUILD_SHARED_LIBS=OFF -DLLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR=$PREFIX/include/spirv/ -G Ninja
ninja install
cd ../..

git clone https://github.com/KhronosGroup/SPIRV-Tools.git --depth 1 --recursive -b v2025.1
cd SPIRV-Tools
ln -s /root/SPIRV-Headers external/spirv-headers
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" -DBUILD_SHARED_LIBS=OFF -DENABLE_SPIRV_TOOLS_INSTALL=ON -G Ninja
ninja install
cd ../..

wget https://xorg.freedesktop.org/archive/individual/proto/xcb-proto-1.17.0.tar.gz
tar xfv xcb-proto-*.tar.gz
cd xcb-proto-*/
./configure --prefix="$PREFIX"
make install
cd ..

git clone https://gitlab.freedesktop.org/xorg/util/macros.git --depth 1 --recursive -b util-macros-1.20.2
cd macros
./autogen.sh
./configure --prefix="$PREFIX"
make install
cd ..

wget https://xorg.freedesktop.org/archive/individual/proto/xorgproto-2024.1.tar.xz
tar xfv xorgproto-*.tar.xz
cd xorgproto-*/
./configure --prefix="$PREFIX"
make install
cd ..

wget https://www.x.org/pub/individual/lib/libXau-1.0.12.tar.xz
tar xfv libXau-*.tar.xz
cd libXau-*/
./configure --prefix="$PREFIX" --enable-shared=no --enable-static=yes
make -j$(nproc)
make install
cd ..

wget https://xorg.freedesktop.org/archive/individual/lib/libxcb-1.17.0.tar.gz
tar xfv libxcb-*.tar.gz
cd libxcb-*/
./configure --prefix="$PREFIX" --enable-shared=no --enable-static=yes --enable-dri3
make $(nproc)
make install
cd ..

git clone https://gitlab.freedesktop.org/xorg/lib/libx11.git --depth 1 --recursive -b libX11-1.8.12
cd libx11
./autogen.sh
./configure --prefix="$PREFIX" --enable-shared=no --enable-static=yes
make -j$(nproc)
make install
cd ..

git clone https://gitlab.freedesktop.org/xorg/lib/libxrender.git --depth 1 --recursive -b libXrender-0.9.12
cd libxrender
./autogen.sh
./configure --prefix="$PREFIX" --enable-shared=no --enable-static=yes
make -j$(nproc)
make install
cd ..

git clone https://gitlab.freedesktop.org/xorg/lib/libxcb-util.git --depth 1 --recursive -b xcb-util-0.4.1-gitlab
cd libxcb-util
./autogen.sh
./configure --prefix="$PREFIX" --enable-shared=no --enable-static=yes
make -j$(nproc)
make install
cd ..

git clone https://gitlab.freedesktop.org/xorg/lib/libxcb-keysyms.git --depth 1 --recursive -b xcb-util-keysyms-0.4.1
cd libxcb-keysyms
./autogen.sh
./configure --prefix="$PREFIX" --enable-shared=no --enable-static=yes
make -j$(nproc)
make install
cd ..

git clone https://gitlab.freedesktop.org/xorg/lib/libxcb-image.git --depth 1 --recursive -b xcb-util-image-0.4.1-gitlab
cd libxcb-image
./autogen.sh
./configure --prefix="$PREFIX" --enable-shared=no --enable-static=yes
make -j$(nproc)
make install
cd ..

git clone https://gitlab.freedesktop.org/alanc/libxcb-render-util.git --depth 1 --recursive -b xcb-util-renderutil-0.3.10
cd libxcb-render-util
./autogen.sh
./configure --prefix="$PREFIX" --enable-shared=no --enable-static=yes
make -j$(nproc)
make install
cd ..

git clone https://gitlab.freedesktop.org/xorg/lib/libxext.git --depth 1 --recursive -b libXext-1.3.6
cd libxext
./autogen.sh
./configure --prefix="$PREFIX" --enable-shared=no --enable-static=yes
make -j$(nproc)
make install
cd ..

git clone https://gitlab.freedesktop.org/xorg/lib/libxfixes.git --depth 1 --recursive -b libXfixes-6.0.1
cd libxfixes
./autogen.sh
./configure --prefix="$PREFIX" --enable-shared=no --enable-static=yes
make -j$(nproc)
make install
cd ..

git clone https://gitlab.freedesktop.org/xorg/lib/libxshmfence.git --depth 1 --recursive -b libxshmfence-1.3.3
cd libxshmfence
./autogen.sh
./configure --prefix="$PREFIX" --enable-shared=no --enable-static=yes
make -j$(nproc)
make install
cd ..

git clone https://gitlab.freedesktop.org/xorg/lib/libxrandr.git --depth 1 --recursive -b libXrandr-1.5.4
cd libxrandr
./autogen.sh
./configure --prefix="$PREFIX" --enable-shared=no --enable-static=yes
make -j$(nproc)
make install
cd ..

git clone https://gitlab.freedesktop.org/xorg/lib/libxxf86vm.git --depth 1 --recursive -b libXxf86vm-1.1.6
cd libxxf86vm
./autogen.sh
./configure --prefix="$PREFIX" --enable-shared=no --enable-static=yes
make -j$(nproc)
make install
cd ..

git clone https://gitlab.freedesktop.org/xorg/lib/libxcb-wm.git --depth 1 --recursive -b xcb-util-wm-0.4.2
cd libxcb-wm
./autogen.sh
./configure --prefix="$PREFIX" --enable-shared=no --enable-static=yes
make -j$(nproc)
make install
cd ..

git clone https://gitlab.freedesktop.org/freetype/freetype.git --depth 1 --recursive -b VER-2-13-3
cd freetype
./autogen.sh
./configure --prefix="$PREFIX" --enable-shared=no --enable-static=yes
make -j$(nproc)
make install
cd ..

git clone https://gitlab.freedesktop.org/xorg/lib/libice.git --depth 1 --recursive -b libICE-1.1.2
cd libice
./autogen.sh
./configure --prefix="$PREFIX" --enable-shared=no --enable-static=yes
make -j$(nproc)
make install
cd ..

git clone https://gitlab.freedesktop.org/xorg/lib/libsm.git --depth 1 --recursive -b libSM-1.2.6
cd libsm
./autogen.sh
./configure --prefix="$PREFIX" --enable-shared=no --enable-static=yes
make -j$(nproc)
make install
cd ..

git clone https://gitlab.freedesktop.org/fontconfig/fontconfig.git --depth 1 --recursive -b 2.16.2
cd fontconfig
./autogen.sh
./configure --prefix="$PREFIX" --enable-shared=no --enable-static=yes
make -j$(nproc)
make install
cd ..

git clone https://github.com/xkbcommon/libxkbcommon.git --depth 1 --recursive -b xkbcommon-1.10.0
cd libxkbcommon
meson setup build --prefix "$PREFIX" -Ddefault_library=static -Denable-xkbregistry=false -Denable-wayland=false -Denable-tools=false -Dc_link_args="$PREFIX/lib/libXau.a"
cd build
ninja install
cd ../..

git clone https://gitlab.freedesktop.org/mesa/mesa.git --depth 1 --recursive -b mesa-25.1.3
cd mesa
meson setup build -Dvulkan-drivers= -Dgallium-drivers=nouveau,r300,r600,radeonsi,zink -Dplatforms=x11 -Degl-native-platform=x11 -Dstatic-libclc=all -Dcpp_rtti=false
cd build
ninja install
cd ../..

git clone https://git.ffmpeg.org/ffmpeg.git --depth 1 --recursive -b n7.1.1
cd ffmpeg
./configure --prefix="$PREFIX" --enable-gpl --disable-programs --disable-htmlpages --disable-manpages --disable-podpages --disable-txtpages
make -j$(nproc)
make install
cd ..

git clone https://github.com/libusb/libusb.git --depth 1 --recursive
cd libusb
./autogen.sh
./configure --prefix="$PREFIX" --enable-shared=no --enable-static=yes
make -j$(nproc)
make install
cd ..

wget https://download.qt.io/official_releases/qt/5.15/5.15.2/single/qt-everywhere-src-5.15.2.tar.xz
tar xfv qt-everywhere-src-*.tar.xz
cd qt-everywhere-src-*/
./configure -prefix "$PREFIX" -static -release -opensource -confirm-license -qt-zlib -qt-libpng -qt-webp -qt-libjpeg -qt-freetype -skip qt3d -skip qtactiveqt -skip qtandroidextras -skip qtcharts -skip qtconnectivity -skip qtdatavis3d -skip qtdeclarative -skip qtdoc -skip qtgamepad -skip qtlocation -skip qtlottie -skip qtmacextras -skip qtnetworkauth -skip qtpurchasing -skip qtquick3d -skip qtquickcontrols -skip qtquickcontrols2 -skip qtquicktimeline -skip qtremoteobjects -skip qtscript -skip qtsensors -skip qtspeech -skip qtwayland -skip qtwebglplugin -skip qtwebview -skip webengine -make libs -nomake examples -nomake tests
make -j$(nproc)
make install
cd ..

find /static -name \*.so -exec rm -vf {} \;

cd torzu
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DYUZU_USE_CPM=ON -DYUZU_TESTS=OFF -DENABLE_QT=OFF -DTZ_LINK_INTL=ON -G Ninja
ninja yuzu
cd ../..

# /root/llvm-project/llvm/tools/llvm-config/llvm-config.cpp
#    : replace all LinkMode = LinkModeShared with LinkMode = LinkModeStatic

# /root/qt-everywhere-src-5.15.2/qtbase/include/QtCore/../../src/corelib/global/qfloat16.h
# /root/qt-everywhere-src-5.15.2/qtbase/src/corelib/text/qbytearraymatcher.h
#    : add <limits> #include
