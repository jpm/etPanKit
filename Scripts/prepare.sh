#!/bin/sh
cd ..
mkdir -p Externals
cd Externals
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
