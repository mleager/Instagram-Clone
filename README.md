# Instagram Clone - MERN Stack

Create AWS infrastructure and deploy React frontend & Node/Express backend using Terraform.

Source Code Repo for this Project: https://github.com/mleager/instagram-mern

**ORIGINAL PROJECT BY: [Jigar Sable](https://github.com/jigar-sable/instagram-mern)**

- Project was modified to use Postmark instead of SendGrid.

## Project Resources:
<b>VPC</b>
  - and accompanying IGW, NAT, Routing Tables, etc.

<b>2 Application Load Balancers</b>
  - 1 Internet-Facing ALB for Frontend, 1 Internal ALB for Backend

<b>2 Autoscaling Groups</b>
  - 1 for each of the Frontend & Backend

<b>MongoDB</b>
  - MongoDB resources for storing site data

<b>DNS</b>
  - ACM and Route53 records for DNS

<b>Security Groups</b>
  - Security Groups for AWS resources

## Instructions:

<b>Apply Terraform config files</b>

  ***NOTE:*** <br>
    * MongoDB Provider requires Public and Private Access Keys. <br>
    * The `0-provider.tf` file shows 2 options for using the Keys:
      
      Set Keys as ENV Varibles using your Local Terminal
        - MONGODB_ATLAS_PUBLIC_KEY=xxxxxxxx
        - MONGODB_ATLAS_PRIVATE_KEY=xxxxxxxxxxxxxxxxxxxx
          
      Set Keys are Terraform variables in `terraform.tfvars`
        - Make sure this file is not commited to Public Repos and stored properly

<b>Start the Backend Server</b>
1. SSM into instance (allowed by IAM Instance Profile)
2. cd /usr/share/nginx/backend
3. Add MongoDB Connection String to '/backend/config/config.env'
  
  ```
    * Must append "/?retryWrites=true&w=majority" to connect MongoDB with Node.js Backend *
  
  MONGO_URI=mongodb+srv://<username>:<password>@mongo-cluster.abcdefg.mongodb.net/?retryWrites=true&w=majority

                    <mongo_connection_string>/?retryWrites=true&w=majority
  ```
4. `$ sudo npm start`

<b>Start Frontend Server</b>
1. SSM into instance (allowed by IAM Instance Profile)
2. confirm Nginx is running<br>
  `sudo systemctl status nginx`
3. cd /usr/share/nginx/frontend
4. `$ sudo npm start`
