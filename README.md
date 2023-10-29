# Instagram Clone - MERN Stack

Create AWS infrastructure and deploy React frontend & Node/Express backend using Terraform.

<img width="797" alt="MERN_Arch_2" src="https://github.com/mleager/Instagram-Clone/assets/106631893/20d578d1-dce0-4553-9bbb-0df066cbd685">


## Project Resources:
- `VPC`
  - and accompanying IGW, NAT, Routing Tables, etc.

- `2 Application Load Balancers`
  - 1 Internet-facing for frontend, 1 Internal for backend

- `2 Autoscaling Groups`
  - 1 for each of the frontend & backend

- `MongoDB`
  - MongoDB resources for storing site data

- `DNS`
  - ACM and Route53 records for DNS

- `Security Groups`
  - Security Groups for AWS resources

## Instructions:

1. Apply Terraform config files

  ***NOTE:*** <br>
    * MongoDB Provider requires Public and Private Access Keys. <br>
    * The `0-provider.tf` file shows 2 options for using the Keys:
      
      Set Keys as ENV Varibles using your Local Terminal
        - MONGODB_ATLAS_PUBLIC_KEY=xxxxxxxx
        - MONGODB_ATLAS_PRIVATE_KEY=xxxxxxxxxxxxxxxxxxxx
          
      Set Keys are Terraform variables in `terraform.tfvars`
        - Make sure this file is not commited to Public Repos and stored properly

2. Start the Backend Server
- SSM into instance (allowed by IAM Instance Profile)
- cd /usr/share/nginx/backend
- Add MongoDB Connection String to '/backend/config/config.env'
  
  ```
          * Must append "/?retryWrites=true&w=majority" to connect MongoDB with Node.js Backend *
  
  MONGO_URI=mongodb+srv://<username>:<password>@mongo-cluster.abcdefg.mongodb.net/?retryWrites=true&w=majority

                    <mongo_connection_string>/?retryWrites=true&w=majority
  ```
- $ sudo npm start

3. Start Frontend Server
- SSM into instance (allowed by IAM Instance Profile)
- confirm Nginx is running
  
  `sudo systemctl status nginx`
- cd /usr/share/nginx/frontend
- $ sudo npm start
