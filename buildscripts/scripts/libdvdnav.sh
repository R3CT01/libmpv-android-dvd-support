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

# libtool's .la files record /usr/local/lib paths that don't exist with DESTDIR
# installs and break later libtool links. The static .a files and pkg-config
# are all that's needed, so drop them.
rm -f "$prefix_dir"/lib/libdvdnav.la

# mpv links libdvdnav as a static archive, so libdvdread has to show up on the
# link line. Make it a public requirement so pkg-config always reports it.
pc="$prefix_dir/lib/pkgconfig/dvdnav.pc"
if [ -f "$pc" ]; then
	sed -i 's/^Requires\.private:/Requires:/' "$pc"
	grep -qE '^Requires:.*dvdread' "$pc" || sed -i 's/^Libs:.*/& -ldvdread/' "$pc"
fi
