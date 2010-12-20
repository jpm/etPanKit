#!/bin/sh

rootdir=`pwd`/..
srcdir="$rootdir"

libxml2_version='2.7.8'
libxml2url="ftp://xmlsoft.org/libxml2/libxml2-$libxml2_version.tar.gz"

arch_flags="-arch ppc -arch i386 -arch x86_64"
arch="ppc i386 x86_64"

external="$srcdir/Externals"
tmpdir="$srcdir/tmp"
logdir="$srcdir/log"

rm -rf "$logdir"
mkdir -p "$logdir"
rm -rf "$tmpdir"
mkdir -p "$tmpdir"

update_libetpan=1
if $1 == build ; then
	update_libetpan=0
fi

cd "$external"
mkdir -p Externals
cd Externals
echo press [ENTER] when the password is asked.
cvs -d:pserver:anonymous@libetpan.cvs.sourceforge.net:/cvsroot/libetpan login
cvs -z3 -d:pserver:anonymous@libetpan.cvs.sourceforge.net:/cvsroot/libetpan co -P -d libetpan-cvs libetpan
cd libetpan-cvs
#cd ..
cd build-mac
./update.sh
cd ..
find . -name 'CVS' -print0 | xargs -0 rm -rf
find . -name '.cvsignore' -print0 | xargs -0 rm
cd ..
cp -R libetpan-cvs/ libetpan/
rm -rf libetpan-cvs


libxml2_enabled=1
if test -d "$external/libxml2" ; then
	libxml2_enabled=0
fi

# libxml2
if test "$libxml2_enabled" = 1 ; then
	echo get libxml2
	cd "$tmpdir"
	curl -O "$libxml2url"
	targz="libxml2-$libxml2_version.tar.gz"
	tar xf "$targz"
fi

if test "$libxml2_enabled" = 1 ; then
	echo building libxml2
	cd "$tmpdir/libxml2-$libxml2_version"
	export CFLAGS="$arch_flags -isysroot /Developer/SDKs/MacOSX10.5.sdk -mfix-and-continue -mmacosx-version-min=10.5"
	export CXXFLAGS="$arch_flags -isysroot /Developer/SDKs/MacOSX10.5.sdk -mfix-and-continue -mmacosx-version-min=10.5"
	export LDLAGS="$arch_flags -isysroot /Developer/SDKs/MacOSX10.5.sdk -mfix-and-continue -mmacosx-version-min=10.5"
	./configure --disable-shared --disable-dependency-tracking >> "$logdir/libxml2-build.log"
	make libxml2.la >> "$logdir/libxml2-build.log"
	rm -rf "$external/libxml2"
	make install-libLTLIBRARIES "prefix=$external/libxml2" >> "$logdir/libxml2-build.log"
	cd include/libxml
	make install-xmlincHEADERS "prefix=$external/libxml2" >> "$logdir/libxml2-build.log"
fi
