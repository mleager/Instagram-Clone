#!/bin/bash

#########################
##  FRONTEND - UBUNTU  ##
#########################

# Update the Package Manager
sudo apt update -y

# Install Necessary Packages
sudo apt install -y nginx npm unzip wget

# Create Directories
sudo mkdir -p /usr/share/nginx/

# Download and Unzip the Frontend Source Code
wget https://github.com/mleager/instagram-mern/archive/main.zip -O /tmp/frontend.zip
sudo unzip -q /tmp/frontend.zip -d /usr/share/nginx/
sudo mv /usr/share/nginx/instagram-mern-main/* /usr/share/nginx/
sudo rm -rf /usr/share/nginx/instagram-mern-main
sudo rm -f /tmp/frontend.zip

# Create Nginx Reverse Proxy file
sudo tee /etc/nginx/conf.d/react-app.conf << 'EOF'
server {
    listen 80;
    server_name ${module.public_alb.lb_dns_name}; # Replace with your domain or server name
    root /usr/share/nginx/frontend;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;      
        proxy_set_header X-Forwarded-Host $server_name;
        proxy_redirect default;
    }

    location /api/ {
        proxy_pass http://${module.private_alb.lb_dns_name}:4000; # Internal Load Balancer DNS of your backend ASG
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# Add 'server_names...' attribute to '/etc/nginx/nginx.conf'
sudo sed -i '/^ *types_hash_max_size /a\    server_names_hash_bucket_size 128;' /etc/nginx/nginx.conf

# Replace "Proxy" Field in '/frontend/package.json'
sudo sed -i 's/"proxy": "http:\/\/localhost:4000",/"proxy": "http:\/\/${module.private_alb.lb_dns_name}:4000",/' /usr/share/nginx/frontend/package.json

# Test Nginx config and if Successful, Start & Enable Nginx
sudo nginx -t && sudo systemctl start nginx && sudo systemctl enable nginx || echo "Nginx configuration test failed. Please check your configuration."

# CD into Frontend & Install and Start React Server
cd /usr/share/nginx/frontend
sudo npm install
#sudo npm start
