#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

echo "Cloning the github repository"
git clone https://github.com/yourusername/your-adblocker-repo.git

echo "Navigating to the cloned repository directory"
cd your-adblocker-repo

# Set execution permissions for the Python scripts
sudo chmod +x websocket_server.py flask_server.py reinstall-squid.sh enable-tproxy.sh

if ! (grep -q '^CONFIG_NETFILTER_XT_TARGET_TPROXY=' /boot/config-"$(uname -r)" || zgrep -q '^CONFIG_NETFILTER_XT_TARGET_TPROXY=' /proc/config.gz); then
    echo "TPROXY is not supported by your kernel. Please enable it and recompile the kernel. You can do that by running enable-tproxy.sh"
    exit 1
fi



echo "Configuring the firewall"
iptables -A INPUT -p tcp --dport 3128 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
iptables -A INPUT -p tcp --dport 8081 -j ACCEPT
iptables-save > /etc/iptables/rules.v4


echo "Update package lists and install required packages"
sudo apt-get update && sudo apt-get install -y \
    nginx \
    python3 \
    python3-pip \
    squid \
    openssl \
    apache2-utils

squid_version=$(squid -v)
required_flags=( "enable-ssl" "with-openssl" "enable-ssl-crtd" )

for flag in "${required_flags[@]}"; do
    if ! echo "$squid_version" | grep -q "$flag"; then
        echo "Squid was not installed with the required flag: $flag"
        echo "Please run the script reinstall-squid.sh"
        exit 1
    fi
done

# Install Python libraries required for Flask and WebSocket server
sudo pip3 install flask websockets

# Copy necessary files and directories to their appropriate locations
sudo cp -r html /var/www/
sudo cp squid.conf /etc/squid/



# Set up password protection for the dashboard and configuration pages
echo "Enter a username for accessing the dashboard and configuration pages:"
read username
sudo htpasswd -c /etc/nginx/.htpasswd $username

# Generate SSL certificate and key
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -subj "/C=UK/ST=Hampshire/L=Portsmouth/O=MyOrgOU=Me/CN=squdblocker.com" \
    -keyout /etc/squid/key.pem \
    -out /etc/squid/cert.pem

# Configure Nginx for HTTPS
echo 'server {
    listen 443 ssl;
    server_name localhost;

    ssl_certificate /etc/squid/cert.pem;
    ssl_certificate_key /etc/squid/key.pem;

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
sudo bash -c "cat > /app/start_services.sh << EOL
#!/bin/bash
service nginx restart
service squid start
python3 websocket_server.py &
python3 flask_server.py &
EOL"
sudo chmod +x /app/start_services.sh

# Create stop_services.sh script
sudo bash -c "cat > /app/stop_services.sh << EOL
#!/bin/bash
service nginx stop
service squid stop
pkill -f websocket_server.py
pkill -f flask_server.py
EOL"
sudo chmod +x /app/stop_services.sh

# Create uninstall.sh script
sudo bash -c "cat > /app/uninstall.sh << EOL
#!/bin/bash
sudo service nginx stop
sudo service squid stop
sudo apt-get remove -y nginx python3 python3-pip squid openssl apache2-utils iptables-persistent
sudo rm -r * /var/www/html /etc/nginx/.htpasswd /etc/squid/squid
# Remove firewall rules for the services
iptables -D INPUT -p tcp --dport 3128 -j ACCEPT
iptables -D INPUT -p tcp --dport 80 -j ACCEPT
iptables -D INPUT -p tcp --dport 8080 -j ACCEPT
iptables -D INPUT -p tcp --dport 8081 -j ACCEPT

# Save the updated firewall configuration
iptables-save > /etc/iptables/rules.v4"

sudo /app/start_services.sh
