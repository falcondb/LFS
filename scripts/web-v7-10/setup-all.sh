#!/bin/bash

[[  -z $LFS &&  exit ]]

mkdir -vp $LFS/sources
wget --input-file=wget-list --continue --directory-prefix=$LFS/sources

pushd $LFS/sources
md5sum -c md5sums
popd
