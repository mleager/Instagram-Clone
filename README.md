# Instagram Clone - MERN Stack

Create AWS infrastructure and deploy React frontend & Node/Express backend using Terraform.

Source Code Repo for this Project: https://github.com/mleager/instagram-mern

**ORIGINAL PROJECT BY: [Jigar Sable](https://github.com/jigar-sable/instagram-mern)**

- Project was modified to use Postmark instead of SendGrid.

## Project Resources:
- `VPC`
  - and accompanying IGW, NAT, Routing Tables, etc.

- `2 Application Load Balancers`
  - 1 Internet-Facing ALB for Frontend, 1 Internal ALB for Backend

- `2 Autoscaling Groups`
  - 1 for each of the Frontend & Backend

- `MongoDB`
  - MongoDB resources for storing site data

- `DNS`
  - ACM and Route53 records for DNS

- `Security Groups`
  - Security Groups for AWS resources

## Instructions:

1. Apply Terraform config files

2. Start the Backend Server
- SSM into instance (allowed by IAM Instance Profile)
- cd /usr/share/nginx/backend
- Add MongoDB Connection String to '/backend/config/config.env'
  
  `MONGO_URI=mongodb+srv://<username>:<passowrd>@mongo-cluster.abcdefg.mongodb.net`
- $ sudo npm start

3. Start Frontend Server
- SSM into instance (allowed by IAM Instance Profile)
- confirm Nginx is running
  
  `sudo systemctl status nginx`
- cd /usr/share/nginx/frontend
- $ sudo npm start
