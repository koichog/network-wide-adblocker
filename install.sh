#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

echo "Cloning the github repository"
git clone https://github.com/koichog/network-wide-adblocker

echo "Navigating to the cloned repository directory"
cd network-wide-adblocker

# Set execution permissions for the Python scripts and create folders for the flask logs + lists
sudo chmod +x websocket_server.py flask_server.py install-squid-ssl.sh enable-tproxy.sh
sudo mkdir /var/www/html/blocklists
sudo touch /var/www/html/blocklists/custom_blocklist.txt
sudo touch /var/www/html/blocklists/main_blocklist.txt
sudo touch /var/www/html/blocklists/flask_server.log


if ! (grep -q '^CONFIG_NETFILTER_XT_TARGET_TPROXY=' /boot/config-"$(uname -r)" || zgrep -q '^CONFIG_NETFILTER_XT_TARGET_TPROXY=' /proc/config.gz); then
    echo "TPROXY is not supported by your kernel. Please enable it and recompile the kernel. You can do that by running enable-tproxy.sh"
    exit 1
fi

echo "Update package lists and install required packages"
sudo apt-get update && sudo apt-get install -y \
    nginx \
    python3 \
    python3-pip \
    openssl \
    apache2-utils\
    iptables-persistent

echo "Configuring the firewall"
sudo iptables -A INPUT -s 192.168.1.0/24 -p tcp --dport 3128 -j ACCEPT
sudo iptables -A INPUT -s 192.168.1.0/24 -p tcp --dport 443 -j ACCEPT
sudo iptables -A INPUT -s 192.168.1.0/24 -p tcp --dport 8080 -j ACCEPT
sudo iptables -A INPUT -s 192.168.1.0/24 -p tcp --dport 8081 -j ACCEPT
sudo mkdir -p /etc/iptables
sudo iptables-save > /etc/iptables/rules.v4


sudo bash install-squid-ssl.sh

# Install Python libraries required for Flask and WebSocket server
sudo pip3 install flask websockets

# Copy necessary files and directories to their appropriate locations
sudo cp -r html /var/www/
sudo cp squid.conf /usr/local/squid/squid.conf



# Set up password protection for the dashboard and configuration pages
echo "Enter a username for accessing the dashboard and configuration pages:"
read username
sudo htpasswd -c /etc/nginx/.htpasswd $username

# Generate SSL certificate and key
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -subj "/C=UK/ST=Hampshire/L=Portsmouth/O=MyOrgOU=Me/CN=squdblocker.com" \
    -keyout /usr/local/squid/key.pem \
    -out /usr/local/squid/cert.pem

# Configure Nginx for HTTPS
echo 'server {
    listen 443 ssl;
    server_name localhost;

    ssl_certificate /usr/local/squid//cert.pem;
    ssl_certificate_key /usr/local/squid/key.pem;

    root /var/www/html;
    index index.html;

    location / {
        auth_basic "Restricted Access";
        auth_basic_user_file /etc/nginx/.htpasswd;
        try_files $uri $uri/ =404;
    }
}' > /etc/nginx/sites-available/default-ssl

# Create a symbolic link for the new Nginx HTTPS configuration
ln -s /etc/nginx/sites-available/default-ssl /etc/nginx/sites-enabled/


# Create start_services.sh script
sudo bash -c "cat > start_services.sh << EOL
#!/bin/bash
sudo squid
systemctl start nginx
python3 websocket_server.py &
python3 flask_server.py &
EOL"
sudo chmod +x start_services.sh

# Create stop_services.sh script
sudo bash -c "cat > stop_services.sh << EOL
#!/bin/bash
systemctl stop nging
sudo squid stop
pkill -f websocket_server.py
pkill -f flask_server.py
EOL"
sudo chmod +x stop_services.sh

# Create uninstall.sh script
sudo bash -c "cat > uninstall.sh << EOL
#!/bin/bash
sudo systemctl stop nginx
sudo squid stop
sudo apt-get remove -y nginx python3 python3-pip squid openssl apache2-utils iptables-persistent
sudo rm -r * /var/www/html /etc/nginx/.htpasswd /etc/squid/squid
# Remove firewall rules for the services
sudo iptables -D INPUT -s 192.168.1.0/24 -p tcp --dport 3128 -j ACCEPT
sudo iptables -D INPUT -s 192.168.1.0/24 -p tcp --dport 443 -j ACCEPT
sudo iptables -D INPUT -s 192.168.1.0/24 -p tcp --dport 8080 -j ACCEPT
sudo iptables -D INPUT -s 192.168.1.0/24 -p tcp --dport 8081 -j ACCEPT

# Save the updated firewall configuration
iptables-save > /etc/iptables/rules.v4"

sudo bash start_services.sh
