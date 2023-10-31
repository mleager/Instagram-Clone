resource "aws_launch_template" "frontend_template" {
  name_prefix            = "frontend-"
  image_id               = local.amazonlinux2023_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.frontend_sg.security_group_id]

  update_default_version = true

  instance_initiated_shutdown_behavior = "terminate"

  user_data = base64encode(<<-EOF
#!/bin/bash

##################
##   FRONTEND   ##
##################

# Update the Package Manager
sudo yum update -y

# Install Necessary Packages
sudo yum install -y nginx npm

# Create Directories
sudo mkdir -p /usr/share/nginx/

# Download and Unzip the Frontend Source Code
wget https://github.com/mleager/instagram-mern/archive/main.zip -O /tmp/frontend.zip
sudo unzip -q /tmp/frontend.zip -d /usr/share/nginx/
sudo mv /usr/share/nginx/instagram-mern-main/* /usr/share/nginx/
sudo rm -rf /usr/share/nginx/instagram-mern-main
sudo rm -f /tmp/frontend.zip

# Create Nginx Reverse Proxy file
cat << 'EOFF' | sudo tee /etc/nginx/conf.d/react-app.conf
server {
    listen 80;
    server_name ${var.dns_server_name}; # Replace with your domain/server name/Public ALB DNS Name/Public EC2 Instance IP
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
EOFF

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
EOF
  )

  iam_instance_profile {
    arn = module.frontend_asg.iam_instance_profile_arn
  }
}

resource "aws_launch_template" "backend_template" {
  name_prefix            = "backend-"
  image_id               = local.amazonlinux2023_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.backend_sg.security_group_id]

  update_default_version = true

  instance_initiated_shutdown_behavior = "terminate"

  user_data = base64encode(<<-EOF
#!/bin/bash

#################
##   BACKEND   ##
#################

# Update the Package Manager
sudo yum update -y

# Install Necessary Packages
sudo yum install -y npm

# Install PM2 globally using NPM
#sudo npm install -g pm2

# Create Directories
sudo mkdir -p /usr/share/nginx/

# Download and Unzip the same GitHub Repo as the Frontend
wget https://github.com/mleager/instagram-mern/archive/main.zip -O /tmp/backend.zip
sudo unzip -q /tmp/backend.zip -d /usr/share/nginx/
sudo mv /usr/share/nginx/instagram-mern-main/* /usr/share/nginx/
sudo rm -rf /usr/share/nginx/instagram-mern-main
sudo rm -f /tmp/backend.zip

# Replace '/backend/config/config.env.example' with '/backend/config/config.env'
sudo rm /usr/share/nginx/backend/config/config.env.example
cat << EOFF | sudo tee /usr/share/nginx/backend/config/config.env
PORT=4000
MONGO_URI=<mongo_URI>/?retryWrites=true&w=majority

JWT_SECRET=U3YU23wef32BFE48t48br4tGERbvrtbrtb45n4ty848t4nerS
JWT_EXPIRE=7d
COOKIE_EXPIRE=5

POSTMARK_API_KEY=${var.postmark_api}
POSTMARK_MAIL=${var.user_email}
POSTMARK_RESET_TEMPLATEID=33498305

AWS_BUCKET_NAME=${var.bucket_name}
AWS_BUCKET_REGION=${var.bucket_region}
AWS_IAM_USER_KEY=${var.iam_user_key}
AWS_IAM_USER_SECRET=${var.iam_user_secret_key}

NODE_ENV=development
EOFF

# CD into Backend and Install NPM Packages
cd /usr/share/nginx/backend
sudo npm install

#############
## NOT RUN ##
#############
# Start the Node/Express App using PM2
#sudo npm start
#sudo pm2 start server.js --name "mern-app"

# Save the PM2 Process List and Config to Automatically Start on Server Reboot
#sudo pm2 save
#sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ec2-user --hp /home/ec2-user

# Clean Up (optional)
sudo rm -f /etc/yum.repos.d/nodesource*
EOF
  )

  iam_instance_profile {
    arn = module.frontend_asg.iam_instance_profile_arn
  }
}

resource "aws_launch_template" "frontend_template_ubuntu" {
  name_prefix            = "frontend-"
  image_id               = local.ubuntu_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.frontend_sg.security_group_id]

  update_default_version = true

  instance_initiated_shutdown_behavior = "terminate"

  user_data = base64encode(<<-EOF
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
sudo tee /etc/nginx/conf.d/react-app.conf << 'EOFF'
server {
    listen 80;
    server_name ${var.dns_server_name}; # Replace with your domain/server name/Public ALB DNS Name/Public EC2 Instance IP
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
EOFF

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
EOF  
  )

  iam_instance_profile {
    arn = module.frontend_asg.iam_instance_profile_arn
  }
}

resource "aws_launch_template" "backend_template_ubuntu" {
  name_prefix            = "backend-"
  image_id               = local.ubuntu_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.backend_sg.security_group_id]

  update_default_version = true

  instance_initiated_shutdown_behavior = "terminate"

  user_data = base64encode(<<-EOF
#!/bin/bash

########################
##  BACKEND - UBUNTU  ##
########################

# Update the Package Manager
sudo apt update -y

# Install Necessary Packages
sudo apt install -y npm unzip wget

# Install PM2 globally using NPM
#sudo npm install -g pm2

# Create Directories
sudo mkdir -p /usr/share/nginx/

# Download and Unzip the same GitHub Repo as the Frontend
wget https://github.com/mleager/instagram-mern/archive/main.zip -O /tmp/backend.zip
sudo unzip -q /tmp/backend.zip -d /usr/share/nginx/
sudo mv /usr/share/nginx/instagram-mern-main/* /usr/share/nginx/
sudo rm -rf /usr/share/nginx/instagram-mern-main
sudo rm -f /tmp/backend.zip

# Replace '/backend/config/config.env.example' with '/backend/config/config.env'
sudo rm /usr/share/nginx/backend/config/config.env.example
sudo tee /usr/share/nginx/backend/config/config.env << EOFF
PORT=4000
MONGO_URI=<mongo_URI>/?retryWrites=true&w=majority

JWT_SECRET=U3YU23wef32BFE48t48br4tGERbvrtbrtb45n4ty848t4nerS
JWT_EXPIRE=7d
COOKIE_EXPIRE=5

POSTMARK_API_KEY=${var.postmark_api}
POSTMARK_MAIL=${var.user_email}
POSTMARK_RESET_TEMPLATEID=33498305

AWS_BUCKET_NAME=${var.bucket_name}
AWS_BUCKET_REGION=${var.bucket_region}
AWS_IAM_USER_KEY=${var.iam_user_key}
AWS_IAM_USER_SECRET=${var.iam_user_secret_key}

NODE_ENV=development
EOFF

# CD into Backend and Install NPM Packages
cd /usr/share/nginx/backend
sudo npm install

#############
## NOT RUN ##
#############
# Start the Node/Express App using PM2
#sudo npm start
#sudo pm2 start server.js --name "mern-app"

# Save the PM2 Process List and Config to Automatically Start on Server Reboot
#sudo pm2 save
#sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ec2-user --hp /home/ec2-user

# Clean Up (optional)
sudo rm -f /etc/apt.repos.d/nodesource*
EOF
  )

  iam_instance_profile {
    arn = module.frontend_asg.iam_instance_profile_arn
  }
}
