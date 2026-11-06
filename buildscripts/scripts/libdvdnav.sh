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
	--enable-static --disable-shared

make -j$cores
make DESTDIR="$prefix_dir" install

# mpv links libdvdnav as a static archive, so libdvdread has to show up on the
# link line. Make it a public requirement so pkg-config always reports it.
pc="$prefix_dir/lib/pkgconfig/dvdnav.pc"
if [ -f "$pc" ]; then
	sed -i 's/^Requires\.private:/Requires:/' "$pc"
	grep -qE '^Requires:.*dvdread' "$pc" || sed -i 's/^Libs:.*/& -ldvdread/' "$pc"
fi
