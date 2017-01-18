#!/bin/bash
LVersion=2.6.32

wget http://www.kernel.org/pub/linux/kernel/v2.6/linux-${LVersion}.tar.bz2
tar -xjvf  linux-${LVersion}.tar.bz2 -C /usr/src/