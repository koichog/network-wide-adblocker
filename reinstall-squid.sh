#!/bin/bash

# Define Squid version
SQUID_VERSION="4.13"

# Uninstall existing Squid package
sudo apt-get remove --purge squid

# Install build dependencies
sudo apt-get install -y build-essential libssl-dev

# Download Squid source code
wget http://www.squid-cache.org/Versions/v4/squid-${SQUID_VERSION}.tar.gz

# Extract the source code
tar xvf squid-${SQUID_VERSION}.tar.gz

# Change to the extracted directory
cd squid-${SQUID_VERSION}

# Configure the Squid installation with the necessary flags
./configure --prefix=/usr --localstatedir=/var --libexecdir=${prefix}/lib/squid --datadir=${prefix}/share/squid --sysconfdir=/etc/squid --with-default-user=pi --with-logdir=/var/log/squid --with-pidfile=/var/run/squid.pid --enable-ssl --with-openssl --enable-ssl-crtd

# Build and install Squid
sudo make -j$(nproc)
sudo make install

# Create required directories and set permissions
sudo mkdir -p /var/log/squid /var/cache/squid
sudo chown -R pi:pi /var/log/squid /var/cache/squid

# Set up Squid to run as a service
sudo bash -c 'cat > /etc/systemd/system/squid.service << EOL
[Unit]
Description=Squid Web Proxy Server
After=network.target

[Service]
Type=forking
ExecStartPre=/usr/lib/squid/squid -z
ExecStart=/usr/lib/squid/squid -sYC
ExecReload=/bin/kill -HUP \$MAINPID
ExecStop=/bin/kill -TERM \$MAINPID
Restart=on-abort
User=pi
Group=pi

[Install]
WantedBy=multi-user.target
EOL'

# Reload the systemd daemon and enable Squid to start on boot
sudo systemctl daemon-reload
sudo systemctl enable squid

# Start the Squid service
sudo systemctl start squid
