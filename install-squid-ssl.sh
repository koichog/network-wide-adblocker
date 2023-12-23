echo "Installing necessary packages"
sudo apt-get remove --purge squid -y
sudo apt-get autoremove -y
sudo apt-get update
sudo apt-get install -y build-essential libssl-dev openssl libnetfilter-conntrack-dev
SQUID_VERSION=4.13

echo "Retrieving squid m squid-cache.org"
sudo wget http://www.squid-cache.org/Versions/v4/squid-${SQUID_VERSION}.tar.gz
sudo tar xzf squid-${SQUID_VERSION}.tar.gz
cd squid-${SQUID_VERSION}

echo "Configuring Squid"
./configure --enable-ssl --with-openssl --enable-ssl-crtd

echo "Installing it - this will take time so take a deep breath and come back in ~10mins :)"
sleep 5
sudo make
sudo make install
sudo bash -c "cat > /etc/systemd/system/squid.service << EOL
[Unit]
Description=Squid Web Proxy Server
After=network.target

[Service]
Type=forking
ExecStart=/usr/sbin/squid -sYC
ExecReload=/usr/sbin/squid -k reconfigure
PIDFile=/var/run/squid.pid

[Install]
WantedBy=multi-user.target
EOL"

sudo ln -s /usr/local/squid/sbin/squid /usr/sbin/squid
sudo chown -R 777 /usr/local/squid
sudo chmod -R 777 /usr/local/squid

# Reload systemd and enable Squid service
sudo systemctl daemon-reload
sudo systemctl enable squid
echo "Squid installation complete."
