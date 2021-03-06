#!/bin/bash -e

MXE_PREFIX=/opt/mxe
JOBS=`nproc 2>/dev/null`
STAGE="`pwd`/stage"
BUILD_TYPE="Release"
if [ "$1" == "debug" ]; then
	BUILD_TYPE="RelWithDebInfo"
	echo "Building with debug symbols"
	shift
fi

mkdir -p build
cd build

cmake ../../.. \
	-DMXE_HACK=ON \
	-DPKG_CONFIG_EXECUTABLE="$MXE_PREFIX/usr/bin/i686-pc-mingw32-pkg-config" \
	-DCMAKE_TOOLCHAIN_FILE="$MXE_PREFIX/usr/i686-pc-mingw32/share/cmake/mxe-conf.cmake" \
	-DBoost_THREAD_LIBRARY_RELEASE="$MXE_PREFIX/usr/i686-pc-mingw32/lib/libboost_thread_win32-mt.a" \
	-DCMAKE_BUILD_TYPE=$BUILD_TYPE \
	-DCMAKE_INSTALL_PREFIX="$STAGE" \
	-DENABLE_WEBCAM=OFF \
	-DENABLE_TOOLS=ON

if [ "$1" != "config" ]; then
	make -j $JOBS
	make install
	python ../copydlls.py "$MXE_PREFIX/usr/i686-pc-mingw32/bin" "$STAGE"

	if [ "$BUILD_TYPE" == "Release" ]; then
		echo "Stripping EXEs as this is a release build..."
		strip "$STAGE/"*.exe "$STAGE/tools/"*.exe
	fi
fi

echo "Done"

