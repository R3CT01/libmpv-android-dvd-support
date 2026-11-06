# custom build of libmpv with DVD support

Based on [mpv-android](https://github.com/mpv-android/mpv-android)

## Building from source

Take a look at [README.md](buildscripts/README.md) inside the `buildscripts` directory.

## DVD support

This build adds `libdvdcss`, `libdvdread` and `libdvdnav` and enables mpv's `dvdnav` option, so mpv can open `dvd://` sources (DVD menus, chapters, `VIDEO_TS` folders and `.iso` images). It also includes `libdvdcss`, so CSS-encrypted discs can be read. Check that using it is legal where you live; the library is GPL-licensed.
