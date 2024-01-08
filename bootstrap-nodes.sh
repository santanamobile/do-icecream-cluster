#!/bin/sh
#
# bootstrap-nodes.sh
#
echo -n "Start: " > /root/STATUS
date >> /root/STATUS

apt update

apt install -y --no-install-recommends icecc clang crossbuild-essential-arm64 \
	nfs-common python-is-python3

apt autoremove -y

mkdir -p /mnt/yocto/downloads
mkdir -p /mnt/yocto/sources
mkdir -p /mnt/yocto/sstate-cache
# mkdir -p /mnt/yocto/tmp
sleep 1

systemctl stop iceccd.service
systemctl stop icecc-scheduler.service
systemctl disable iceccd.service
systemctl disable icecc-scheduler.service

cat > /etc/icecc/icecc.conf << EOF
ICECC_ALLOW_REMOTE="yes"
ICECC_NICE_LEVEL="5"
ICECC_LOG_FILE="/var/log/iceccd.log"
#ICECC_NETNAME="ICECREAM"
ICECC_MAX_JOBS="8"
ICECC_BASEDIR="/mnt/icecc-cache"
ICECC_SCHEDULER_LOG_FILE="/var/log/icecc_scheduler.log"
ICECC_SCHEDULER_HOST="172.16.10.2"
ICECC_CACHE_LIMIT=""
EOF

cat > /etc/rc.local << EOF
#!/bin/sh
# rc.local
# Start icecc worker
iceccd -d -i eth1 -s 172.16.10.2

exit 0
EOF

chmod 755 /etc/rc.local

echo -n "Stop: " >> /root/STATUS
date >> /root/STATUS
echo "\nDONE" >> /root/STATUS

sudo cat >> /etc/fstab << EOF
172.16.10.2:/mnt/yocto/downloads    /mnt/yocto/downloads    nfs defaults 0 1
172.16.10.2:/mnt/yocto/sources      /mnt/yocto/sources      nfs defaults 0 1
172.16.10.2:/mnt/yocto/sstate-cache /mnt/yocto/sstate-cache nfs defaults 0 1
EOF

. /etc/rc.local
exit 0
