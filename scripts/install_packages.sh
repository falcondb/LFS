#!/bin/bash

function info(){
	echo -e "${GREEN}$1${NC}"
}

function error(){
	echo -e "${RED}$1${NC}"
}

function install_binutils(){

	info "Start to build binutils..."

	pushd .

	cd ${lfssources}
	cd binutils-2.27

	mkdir -v build
	cd build

	../configure --prefix=/tools \
				--with-sysroot=$LFS \
				--with-lib-path=/tools/lib \
				--target=$LFS_TGT \
				--disable-nls \
				--disable-werror

	[[ ! -e ./Makefile ]] && exit 

	make

	case $(uname -m) in 
		x86_64) 
		mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;;
	esac

	make install

	[[ ! -e /tools/bin/*ld ]] && exit

	popd

	rm -rf $LFS/source/binutils-2.27/build

	info "Building binutils is done..."
}

function install_gcc(){
	info "Start to build gcc..."
	
	pushd .

	cd ${lfssources}
	tar -jxvf gcc-6.2.0.tar.bz2

	[[ ! -d gcc-6.2.0 ]] && exit

	cd gcc-6.2.0

	tar -xf ../mpfr-3.1.4.tar.xz
	mv -v mpfr-3.1.4 mpfr
	tar -xf ../gmp-6.1.1.tar.xz
	mv -v gmp-6.1.1 gmp
	tar -xf ../mpc-1.0.3.tar.gz
	mv -v mpc-1.0.3 mpc

	for file in $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
		do
		cp -uv $file{,.orig}
		sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
		-e 's@/usr@/tools@g' $file.orig > $file
		echo '
		#undef STANDARD_STARTFILE_PREFIX_1
		#undef STANDARD_STARTFILE_PREFIX_2
		#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
		#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
		touch $file.orig
	done

	mkdir -v build
	cd build
	
	../configure \
		--target=$LFS_TGT \
		--prefix=/tools \
		--with-glibc-version=2.11 \
		--with-sysroot=$LFS \
		--with-newlib \
		--without-headers \
		--with-local-prefix=/tools \
		--with-native-system-header-dir=/tools/include \
		--disable-nls \
		--disable-shared \
		--disable-multilib \
		--disable-decimal-float \
		--disable-threads \
		--disable-libatomic \
		--disable-libgomp \
		--disable-libmpx \
		--disable-libquadmath \
		--disable-libssp \
		--disable-libvtv \
		--disable-libstdcxx \
		--enable-languages=c,c++

	[[ ! -e ./Makefile ]] && exit 

	make

	make install 

	[[ ! -e /tools/bin/*lfs-linux-gnu-gcc ]] && exit

	popd

	rm -rf $LFS/source/gcc-6.2.0/build

	info "Building gcc is done..."
}

install_linux_API_headers(){
	info "Start to build Linux headers..."

	pushd .

	cd ${lfssources}
	tar xvfJ linux-4.7.2.tar.xz

	local wpath=linux-4.7.2
	cd ${wpath}

	make mrproper

	make INSTALL_HDR_PATH=dest headers_install
	cp -rv dest/include/* /tools/include

	[[ -z 'ls /tools/include/' ]] && exit

	popd

	rm -rf $LFS/source/${wpath}

	info "Building Linux headers is done..."
}

install_glibc(){
		info "Start to build Glibc..."

	pushd .

	cd ${lfssources}
 	tar xvfJ glibc-2.24.tar.xz

 	local wpath=glibc-2.24
	cd ${wpath}

	mkdir -v build
	cd build

	../configure \
		--prefix=/tools \
		--host=$LFS_TGT \
		--build=$(../scripts/config.guess) \
		--enable-kernel=2.6.32 \
		--with-headers=/tools/include \
		libc_cv_forced_unwind=yes \
		libc_cv_c_cleanup=yes

	make

	make install

	echo 'int main(){}' > dummy.c
	$LFS_TGT-gcc dummy.c
	readelf -l a.out | grep ': /tools'

	[[ -z 'readelf -l a.out | grep ": /tools" | grep interpreter' ]] && exit
	
	rm -v dummy.c a.out

	popd

	rm -rf $LFS/source/${wpath}

	info "Building Glibc is done..."
}

set -x -e 

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

[[ -z $LFS ]] && exit

[[ -z $LFS_TGT ]] && exit

lfssources=$LFS/sources/

su lfs

install_binutils
install_gcc
install_linux_API_headers
install_glibc

