# PROJECT
resource "mongodbatlas_project" "project" {
  name   = var.db_project_name
  org_id = var.org_id
}
output "project_name" {
  value = mongodbatlas_project.project.name
}

# DB CLUSTER
resource "mongodbatlas_cluster" "cluster" {
  project_id             = mongodbatlas_project.project.id
  name                   = var.cluster_name
  mongo_db_major_version = var.mongodbversion
  cluster_type           = "REPLICASET"

  replication_specs {
    num_shards = 1
    regions_config {
      region_name     = var.db_region
      electable_nodes = 3
      priority        = 7
      read_only_nodes = 0
    }
  }

  # Provider Settings
  cloud_backup                 = false
  auto_scaling_disk_gb_enabled = false
  provider_name                = "TENANT"
  backing_provider_name        = var.cloud_provider
  provider_region_name         = var.db_region
  provider_instance_size_name  = "M0"
}
output "connection_string" {
  value = mongodbatlas_cluster.cluster.connection_strings[0].standard_srv
}

# DATABASE USER
resource "mongodbatlas_database_user" "user" {
  username           = var.dbuser
  password           = var.dbuser_password
  project_id         = mongodbatlas_project.project.id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "test"
  }
}
output "user1" {
  value = mongodbatlas_database_user.user.username
}

# IP ACCESS LIST - All Access
resource "mongodbatlas_project_ip_access_list" "full_access" {
  project_id = mongodbatlas_project.project.id
  #ip_address = var.access_list_ip
  cidr_block = var.access_list_cidr
  comment    = "CIDR Block for accessing the cluster"
}
output "ipaccesslist_full_access" {
  value = mongodbatlas_project_ip_access_list.full_access.cidr_block
}
