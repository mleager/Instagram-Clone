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
sudo tee /usr/share/nginx/backend/config/config.env << 'EOF'
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
EOF

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
