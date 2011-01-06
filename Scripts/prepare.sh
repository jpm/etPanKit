#!/bin/sh

rootdir=`pwd`/..

libxml2url="http://download.etpan.org/etpankit-dependencies/libxml2-latest.zip"

command="$1"

if test x$command = xrebuild ; then
	for script in dependencies/prepare-*.sh ; do
		echo sh "$script" rebuild
		sh "$script" rebuild
	done
fi

builddir="$HOME/EtPanKit-Builds/dependencies"
bindir="$builddir/builds"

srcdir="$rootdir"
tmpdir="$srcdir/tmp"
external="$srcdir/Externals"

rm -rf "$tmpdir"
mkdir -p "$tmpdir"
#rm -rf "$external"
#mkdir -p "$external"
rm -rf "$external/libxml2"

cd "$tmpdir"

echo libxml2
curl -O "$libxml2url"
unzip -qo "libxml2-latest.zip"
cp -R "$tmpdir"/libxml2-*/libxml2 "$external/"

echo cleaning
#rm -rf "$tmpdir"
