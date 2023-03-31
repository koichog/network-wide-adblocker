#!/bin/bash

# Remove existing Squid-related packages
sudo apt-get remove -y squid squid-common squid-langpack

# Install necessary build dependencies
sudo apt-get install build-essential devscripts debhelper dh-autoreconf libssl-dev

# Get the source package for Squid
sudo apt-get source squid

# Find the squid source directory
squid_src_dir=$(find . -type d -iname "squid-*" -print -quit)

# Go to the Squid source directory
cd "$squid_src_dir"

# Edit the debian/rules file to add the required flags
sudo sed -i '/DEB_CONFIGURE_EXTRA_FLAGS/ s/$/ --enable-ssl --with-openssl --enable-ssl-crtd/' debian/rules

# Build the Squid package
sudo dpkg-buildpackage -us -uc -b

# Go back to the parent directory
cd ..

# Find the built Squid package
squid_pkg=$(find . -type f -iname "squid_*.deb" -print -quit)

# Install the newly built Squid package
sudo dpkg -i "$squid_pkg"

# Restart Squid
sudo service squid restart

echo "Squid has been rebuilt and installed with the required flags."
