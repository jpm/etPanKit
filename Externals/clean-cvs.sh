#!/bin/sh
find . -name 'CVS' -print0 | xargs -0 rm -rf
find . -name '.cvsignore' -print0 | xargs -0 rm
