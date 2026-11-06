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

# libdvdcss (built before this, found through pkg-config) gets linked in
# directly. There is no libdvdcss.so on Android to dlopen() at runtime.
# Point configure straight at the libdvdcss that was just installed, so it
# cannot miss it, and ask for it explicitly (ignored if the option is unknown).
export CPPFLAGS="-I$prefix_dir/include"
export LDFLAGS="-L$prefix_dir/lib"
../configure \
	--host=$ndk_triple --with-pic \
	--enable-static --disable-shared \
	--with-libdvdcss

make -j$cores
make DESTDIR="$prefix_dir" install

# libdvdcss is a static archive, so it has to show up on mpv's link line.
# Make it a public requirement so pkg-config always reports it.
pc="$prefix_dir/lib/pkgconfig/dvdread.pc"
if [ -f "$pc" ]; then
	sed -i 's/^Requires\.private:/Requires:/' "$pc"
	grep -qE '^Requires:.*libdvdcss' "$pc" || sed -i 's/^Libs:.*/& -ldvdcss/' "$pc"
fi

# Fail now, not after a long build, if libdvdread did not pick libdvdcss up.
if ! llvm-nm "$prefix_dir/lib/libdvdread.a" 2>/dev/null | grep -qi dvdcss; then
	echo "libdvdread was built without libdvdcss support" >&2
	echo "--- libdvdcss files that were installed:" >&2
	ls -la "$prefix_dir"/lib/libdvdcss* "$prefix_dir"/lib/pkgconfig/libdvdcss.pc >&2 || true
	echo "--- dvdcss lines from config.log:" >&2
	grep -i dvdcss config.log | head -40 >&2 || true
	echo "--- dvdcss/dlopen symbols in libdvdread.a:" >&2
	llvm-nm "$prefix_dir/lib/libdvdread.a" 2>&1 | grep -i -E "dvdcss|dlopen|dlsym" | head -20 >&2 || true
	exit 1
fi
