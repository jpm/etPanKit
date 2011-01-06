#!/bin/sh

version='2.7.8'
url="ftp://xmlsoft.org/libxml2/libxml2-$version.tar.gz"
package_filename="libxml2-$version.tar.gz"

arch="ppc i386 x86_64"

arch_flags=""
for current_arch in $arch ; do
	arch_flags="$arch_flags -arch $current_arch"
done

builddir="$HOME/EtPanKit-Builds/dependencies"
BUILD_TIMESTAMP=`date +'%Y%m%d%H%M%S'`
tempbuilddir="$builddir/workdir/$BUILD_TIMESTAMP"
mkdir -p "$tempbuilddir"
srcdir="$tempbuilddir/src"
logdir="$tempbuilddir/log"
resultdir="$builddir/builds"
tmpdir="$tempbuilddir/tmp"

mkdir -p "$resultdir"
mkdir -p "$logdir"
mkdir -p "$tmpdir"
mkdir -p "$srcdir"

echo get libxml2
cd "$srcdir"
if test -f "$builddir/downloads/$package_filename" ; then
	cp "$builddir/downloads/$package_filename" .
else
	curl -O "$url"
	if test x$? != x0 ; then
		echo fetch of libxml2 failed
		exit 1
	fi
	mkdir -p "$builddir/downloads"
	cp "$package_filename" "$builddir/downloads"
fi

tar xf "$package_filename"

echo building libxml2
cd "$srcdir/libxml2-$version"
export CFLAGS="$arch_flags -isysroot /Developer/SDKs/MacOSX10.5.sdk -mfix-and-continue -mmacosx-version-min=10.5"
export CXXFLAGS="$arch_flags -isysroot /Developer/SDKs/MacOSX10.5.sdk -mfix-and-continue -mmacosx-version-min=10.5"
export LDLAGS="$arch_flags -isysroot /Developer/SDKs/MacOSX10.5.sdk -mfix-and-continue -mmacosx-version-min=10.5"
./configure --disable-shared --disable-dependency-tracking >> "$logdir/libxml2-build.log"
make libxml2.la >> "$logdir/libxml2-build.log"
make install-libLTLIBRARIES "prefix=$tmpdir/bin/libxml2" >> "$logdir/libxml2-build.log"
if test x$? != x0 ; then
	echo build of libxml2 failed
	exit 1
fi

cd include/libxml
make install-xmlincHEADERS "prefix=$tmpdir/bin/libxml2" >> "$logdir/libxml2-build.log"
if test x$? != x0 ; then
	echo build of libxml2 failed
	exit 1
fi

cd "$tmpdir/bin"
mkdir -p "libxml2-$version"
mv libxml2 "libxml2-$version"
zip -qry "$resultdir/libxml2-$version.zip" "libxml2-$version"
rm -f "$resultdir/libxml2-latest.zip"
cd "$resultdir"
ln -s "libxml2-$version.zip" "libxml2-latest.zip"

echo build of libxml2-$version done

echo sync
rsync -azv $HOME/EtPanKit-Builds/dependencies/builds/ download.etpan.org:/opt/EtPanKit/builds/etpankit-dependencies/

echo cleaning
rm -rf "$tempbuilddir"
