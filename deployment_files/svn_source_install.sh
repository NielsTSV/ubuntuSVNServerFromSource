cd /src/svn
./configure --with-lz4=internal --enable-mod-activation
make -j"$(nproc)"
make install
/sbin/ldconfig
cd ../../
rm -r src/svn
apt-get purge -y --auto-remove ca-certificates bzip2 gcc libpcre++-dev
apt-get purge -y --auto-remove libssl-dev make libsqlite3-dev zlib1g-dev
apt-get purge -y --auto-remove libneon27-dev libserf-dev
rm -r /var/lib/apt/lists/*
source /etc/apache2/envvars
apt-get update
apt install sudo

