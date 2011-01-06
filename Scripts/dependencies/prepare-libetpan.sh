#!/bin/sh

rootdir=`pwd`/..
srcdir="$rootdir"

external="$srcdir/Externals"
tmpdir="$srcdir/tmp"
logdir="$srcdir/log"

rm -rf "$logdir"
mkdir -p "$logdir"
rm -rf "$tmpdir"
mkdir -p "$tmpdir"

update_libetpan=0
if test x$1 = xrebuild ; then
	update_libetpan=1
fi

if test x$update_libetpan = x1 ; then
	mkdir -p "$external"
	cd "$external"
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
fi
