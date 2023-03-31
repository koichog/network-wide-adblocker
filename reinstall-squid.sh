echo "Installing necessary packages"
sudo apt-get remove -y squid
sudo apt-get install -y build-essential libssl-dev
SQUID_VERSION=4.13

echo "Retrieving squid fro squid-cache.org"
wget http://www.squid-cache.org/Versions/v4/squid-${SQUID_VERSION}.tar.gz
tar xzf squid-${SQUID_VERSION}.tar.gz
cd squid-${SQUID_VERSION}

echo "Configuring Squid"
./configure --prefix=/usr --localstatedir=/var --libexecdir=${prefix}/lib/squid --datadir=${prefix}/share/squid --sysconfdir=/etc/squid --with-logdir=/var/log/squid --with-pidfile=/var/run/squid.pid --enable-ssl --with-openssl --enable-ssl-crtd

echo "Installing it - this will take time so take a deep breath and come back later :)"
sleep 5
make -j$(nproc)
sudo make install
