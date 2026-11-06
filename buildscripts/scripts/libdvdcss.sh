#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

build=_build$ndk_suffix

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf $build
	exit 0
else
	exit 255
fi

mkdir -p $build
cd $build

../configure \
	--host=$ndk_triple --with-pic \
	--enable-static --disable-shared \
	--disable-doc

make -j$cores
make DESTDIR="$prefix_dir" install

# libtool's .la files record /usr/local/lib paths that don't exist with DESTDIR
# installs and break later libtool links. The static .a files and pkg-config
# are all that's needed, so drop them.
rm -f "$prefix_dir"/lib/libdvdcss.la
