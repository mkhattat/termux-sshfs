#!/data/data/com.termux/files/usr/bin/sh
echo start
export HOME=/data/data/com.termux/files/home
export PATH=/data/data/com.termux/files/usr/bin/:$PATH
SSHFS_VERSION_LINK=$(curl -s https://github.com/libfuse/sshfs/releases/latest | cut -d'"' -f2 | cut -d'"' -f1)
export SSHFS_VERSION=${SSHFS_VERSION_LINK##*/}
export SSHFS_VERSION_LITE=${SSHFS_VERSION##*-}
#set the link to the lastest .tar.xz tarball at https://github.com/libfuse/sshfs/releases
export SSHFS_LINK="https://github.com/libfuse/sshfs/releases/download/$SSHFS_VERSION/$SSHFS_VERSION.tar.xz"
if [ -e /data/data/com.termux/files/usr/bin/sshfs ];
then
if [ -d /data/data/com.termux/files/usr/bin/sshfs ] || ! [ -x /data/data/com.termux/files/usr/bin/sshfs ];
then
rm -r --force /data/data/com.termux/files/usr/bin/sshfs
echo oui
else
SSHFS_SYSTEM_VERSION_FULL=$(/data/data/com.termux/files/usr/bin/sshfs -V)
SSHFS_SYSTEM_VERSION_LITE=${SSHFS_SYSTEM_VERSION_FULL#*"SSHFS version "}
SSHFS_SYSTEM_VERSION=${SSHFS_SYSTEM_VERSION_LITE%%F*}
if [ $SSHFS_SYSTEM_VERSION = $SSHFS_VERSION_LITE ];
then
while true; do
read -p "Sshfs is already the newest version ($SSHFS_VERSION_LITE), do you want to reinstall it ? [Y/n] " yn
case $yn in
[Yy]* ) rm -r --force /data/data/com.termux/files/usr/bin/sshfs; break;;
[Nn]* ) echo OK; exit;;
* ) echo 'Please type correctly [Y] or [n]';;
esac
done
else
echo ancienne
fi
fi
fi
pkg update -y
pkg upgrade -y
pkg install root-repo -y
pkg install openssh python glib libfuse3 ninja wget coreutils tar sed -y
python -m pip install --upgrade pip
pip install meson
pip install docutils
cd $HOME
rm -r $HOME/sshfs*
wget -P $HOME $SSHFS_LINK
tar -xf $HOME/$SSHFS_VERSION.tar.xz
rm $HOME/$SSHFS_VERSION.tar.xz
cd $HOME/$SSHFS_VERSION
mkdir ./build/
cd ./build/
meson ..
if ! grep -q '#define LINE_MAX' ../sshfs.c;
then
sed -i '1s/^/#define LINE_MAX 4096\n\n/' ../sshfs.c
fi
ninja
cp ./sshfs $HOME/sshfs
cd $HOME
rm -r $HOME/$SSHFS_VERSION
if [ -x $HOME/sshfs ]; then
while true; do
read -p "Do you want to move sshfs to /data/data/com.termux/files/usr/bin/sshfs ? [Y/n] " yn
case $yn in
[Yy]* ) mv $HOME/sshfs /data/data/com.termux/files/usr/bin/sshfs; echo "sshfs moved to /data/data/com.termux/files/usr/bin/sshfs !"; break;;
[Nn]* ) echo 'sshfs let at $HOME'; break;;
* ) echo 'Please type correctly [Y] or [n]';;
esac
done
fi
echo Done.
