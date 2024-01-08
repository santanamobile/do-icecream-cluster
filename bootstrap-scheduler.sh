#!/bin/sh
#
# bootstrap-scheduler.sh
#
echo -n "Start: " > /root/STATUS
date >> /root/STATUS

echo "apt update/upgrade" >> /root/STATUS
apt update
#apt upgrade -y

echo "Installing packages" >> /root/STATUS

# Required packages
apt install -y --no-install-recommends gawk wget git diffstat unzip texinfo gcc-multilib \
	build-essential chrpath socat cpio python3 python3-pip python3-pexpect \
	xz-utils debianutils iputils-ping libsdl1.2-dev xterm libyaml-dev libssl-dev

apt install -y --no-install-recommends autoconf libtool libglib2.0-dev libarchive-dev \
	sed cvs subversion coreutils texi2html docbook-utils \
	help2man make gcc g++ desktop-file-utils libgl1-mesa-dev libglu1-mesa-dev \
	automake groff curl lzop asciidoc u-boot-tools dos2unix mtd-utils pv \
	libncurses5 libncurses5-dev libncursesw5-dev libelf-dev zlib1g-dev bc rename \
	zstd libgnutls28-dev

apt install -y --no-install-recommends python3-git zstd liblz4-tool \
	python python-pysqlite2

apt install -y --no-install-recommends icecc clang icecream-sundae crossbuild-essential-arm64 \
	nfs-kernel-server nfs-common python-is-python3

apt autoremove -y

echo "Configuring nfs" >> /root/STATUS

mkdir -p /mnt/yocto/downloads
mkdir -p /mnt/yocto/sources
mkdir -p /mnt/yocto/sstate-cache
mkdir -p /mnt/icecc-cache

cat > /etc/exports << EOF
/mnt/yocto/downloads 172.16.10.0/24(rw,sync,no_root_squash,no_subtree_check)
/mnt/yocto/sources 172.16.10.0/24(rw,sync,no_root_squash,no_subtree_check)
/mnt/yocto/sstate-cache 172.16.10.0/24(rw,sync,no_root_squash,no_subtree_check)
/mnt/icecc-cache 172.16.10.0/24(rw,sync,no_root_squash,no_subtree_check)
EOF

echo "Configuring icecream" >> /root/STATUS

systemctl stop iceccd.service
systemctl stop icecc-scheduler.service
systemctl disable iceccd.service

cat > /etc/icecc/icecc.conf << EOF
ICECC_ALLOW_REMOTE="yes"
ICECC_NICE_LEVEL="5"
ICECC_LOG_FILE="/var/log/iceccd.log"
#ICECC_NETNAME="ICECREAM"
ICECC_MAX_JOBS="2"
#ICECC_MAX_JOBS="8"
ICECC_BASEDIR="/mnt/icecc-cache"
ICECC_SCHEDULER_LOG_FILE="/var/log/icecc_scheduler.log"
ICECC_SCHEDULER_HOST="172.16.10.2"
ICECC_CACHE_LIMIT=""
EOF

sleep 2

#systemctl start iceccd.service
iceccd -d -i eth1 -s 172.16.10.2
#icecc-scheduler -d -i eth1
systemctl restart icecc-scheduler.service

#git config --global user.name "User Name"
#git config --global user.email "user@email.com"
#git config --global color.ui false
#mkdir -p ~/bin
#curl https://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
#chmod a+x ~/bin/repo
#export PATH=~/bin:$PATH
echo "Installing repo" >> /root/STATUS

curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
chmod a+x /usr/local/bin/repo

########## CREATE NON-ROOT USER ##########
echo "Creating non-root user" >> /root/STATUS
groupadd builder --gid 5740
adduser --shell /bin/bash --gecos "Embedded Builder Profile" --uid 5740 --gid 5740 --disabled-password builder
echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder
chmod 0440 /etc/sudoers.d/builder
chown builder: -R /mnt/yocto

########## NON-ROOT USER SETUP ##########
echo "User setup" >> /root/STATUS
sudo -u builder -H echo "[user]
	email = usuario@email.com.br
	name = Git Username
[init]
	defaultBranch = master
[alias]
	hist = log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short
[color]
	ui = auto
" > /home/builder/.gitconfig

sudo -u builder -H echo "export CCACHE_PREFIX=icecc" >> ~/.bashrc

echo "Repo download" >> /root/STATUS
# Download sources repositories
sudo -u builder -- sh -c "mkdir -p /home/builder/docker-yocto-build ; \
	cd /home/builder/docker-yocto-build ; \
	repo init -u https://github.com/varigit/variscite-bsp-platform.git -b dunfell -m default.xml ; \
	repo sync -j$(nproc)"

#
# conf/local.conf
#
# DL_DIR ?= "/mnt/yocto/downloads"
# SSTATE_DIR ?= "mkdir /mnt/yocto/sstate-cache"
# TMPDIR = "${TOPDIR}/tmp"

systemctl restart nfs-server.service

########## END ##########
echo -n "Stop: " >> /root/STATUS
date >> /root/STATUS
echo "\nDONE" >> /root/STATUS

exit 0
