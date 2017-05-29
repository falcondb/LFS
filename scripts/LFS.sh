export LFS=/mnt/lfs
mkdir -vp $LFS
mkdir -vp $LFS/usr $LFS/sources $LFS/tools
ln -sv $LFS/tools /

pushd .
cd web-v7-10
./setup-all.sh

popd

groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs

echo -e "LinuxFS\nLinuxFS" passwd lfs
chown -v lfs $LFS/tools
chown -v lfs $LFS/sources

cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > ~/.bashrc << "EOF"
set +h
umask 022
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export LFS LC_ALL LFS_TGT PATH
EOF

