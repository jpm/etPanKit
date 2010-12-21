#!/bin/sh

builddir="$HOME/EtPanKit-Builds"
BUILD_TIMESTAMP=`date +'%Y%m%d%H%M%S'`
tempbuilddir="$builddir/workdir/$BUILD_TIMESTAMP"
mkdir -p "$tempbuilddir"
rootdir="$tempbuilddir/src"
srcdir="$rootdir/etPanKit"
logdir="$tempbuilddir/log"
resultdir="$builddir/builds"
tmpdir="$tempbuilddir/tmp"

mkdir -p "$resultdir"
mkdir -p "$logdir"
mkdir -p "$srcdir"

etpankitsvnurl="https://libetpan.svn.sourceforge.net/svnroot/libetpan/etPanKit/trunk"

svn co -q "$etpankitsvnurl" "$srcdir"

cd "$srcdir/Scripts"

./prepare.sh

cd "$srcdir"

buildversion=`svn info | grep Revision | sed 's/Revision: //'`
#echo $rev

echo building etPanKit - $buildversion

version=`defaults read "$srcdir/Info" CFBundleShortVersionString`
defaults write "$srcdir/version" CFBundleVersion $buildversion
defaults write "$srcdir/version" CFBundleShortVersionString $version
defaults write "$srcdir/Info" CFBundleVersion "$buildversion"
plutil -convert xml1 "$srcdir/version.plist"
plutil -convert xml1 "$srcdir/Info.plist"

/Developer/usr/bin/xcodebuild -target etPanKit -configuration Release OBJROOT="$tmpdir/obj" SYMROOT="$tmpdir/sym" RUN_CLANG_STATIC_ANALYZER="NO" >> "$logdir/etpankit-build.log"
if test x$? != x0 ; then
	echo build of etPanKit failed
	exit 1
fi

svn commit -m "build $buildversion" "$srcdir/Info.plist" "$srcdir/version.plist"

cd "$tmpdir/sym/Release"
mkdir -p "EtPanKit-$buildversion"
mv "EtPanKit.framework" "EtPanKit-$buildversion"
mv "EtPanKit.framework.dSYM" "EtPanKit-$buildversion"
zip -qry "$resultdir/EtPanKit-$buildversion.zip" "EtPanKit-$buildversion"
rm -f "$resultdir/EtPanKit-latest.zip"
cd "$resultdir"
ln -s "EtPanKit-$buildversion.zip" "EtPanKit-latest.zip"

echo build of etPanKit-$buildversion done

echo sync
rsync -azv $HOME/EtPanKit-Builds/builds/ download.etpan.org:/opt/EtPanKit/builds/etpankit/

echo cleaning
rm -rf "$tempbuilddir"
