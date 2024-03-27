variable "project_id" {
  description = "Google Cloud Project ID"
}

variable "region" {
  description = "Google Cloud region"
}

variable "vpc_name" {
  description = "Name of VPC"
  type    = string
}
variable "webapp_subnet_name" {
  description = "Name of the webapp subnet"
}

variable "db_subnet_name" {
  description = "Name of the db subnet"
}

variable "route_name" {
  description = "Name of the route"
}

variable "cidr_db" {
  description = "DB CIDR"
}

variable "cidr_webapp" {
  description = "Webapp CIDR"
}

variable "route_dest" {
  description = "route destination"
}

variable "next_hop_gateway" {
  description = "next hop gateway"
}

variable "cred_file" {
  description = "gcp service admin credentials"
  type = string
}

variable "routing_mode" {
  description = "routing mode"
  type = string
}

variable "machine_type" {
  description = "machine type"
  type = string
}

variable "instance_zone" {
  description = "instance zone"
  type = string
}

variable "disk_type" {
  type = string
}

variable "image_name" {
  type = string
}

variable "app_port" {
  type = string
}

variable "ssh_port" {
  type = string
}

variable "protocol" {
  type = string
}

variable "deny_dir" {
  type = string
}

variable "allow_dir" {
  type = string
}
variable "size" {
  type = number
}
variable "instance_name" {
  type = string
}

variable "firewall_allow" {
  type = string
}

variable "firewall_deny" {
  type = string
}

variable "firewall_allow_tag" {
  type = string
}

variable "firewall_deny_tag" {
  type = string
}

variable "route_priority" {
  type = number
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_port" {
  type = string
}
variable "address_type" {
  type = string  
}

variable "purpose" {
  type = string
}

variable "prefix_length" {
  type = number
}

variable "service" {
  type = string
}

variable "database_version" {
  type = string
}

variable "db_tier" {
  type = string
}
variable "db_disk_type" {
  type = string
}
variable "db_availability" {
  type = string
}
variable "start_time" {
  type = string
}
variable "tlr_days" {
  type = string
}
variable "deletion_policy" {
  type = string
}

variable "scopes" {
  type = string
}

variable "domain" {
  type = string
}

variable "recordType" {
  type = string
}

variable "ttl" {
  type = number
}

variable "managed_zone" {
  type = string
}

variable "static_ip_name" {
  type = string
}

variable "loggingAdmin" {
  type = string
}

variable "metricsWriter" {
  type = string
}

variable "monitoring_account_id" {
  type = string
}

variable "monitoring_logs_binding" {
  type = string
}

variable "MX_values" {
  type = list(string)
}

variable "TXT1" {
  type = list(string)
}

variable "TXT2" {
  type = list(string)
}

variable "TXT2_Domain" {
  type = string
}

variable "CNAME_value" {
  type = list(string)
}

variable "pub_sub_topic" {
  type = string
}
variable "pub_sub_sub" {
  type = string
}

variable "cloud_fn_acc_id" {
  type = string
}

variable "pub_sub_subscriber" {
  type = string
}

variable "pub_sub_publisher" {
  type = string
}

variable "secret_accessor" {
  type = string
}

variable "function_invoker" {
  type = string
}

variable "sql_client" {
  type = string
}

variable "sa_creator" {
  type = string
}

variable "storage_bucket_name" {
  type = string
}

variable "storage_object_name" {
  type = string
}

variable "cloud_fn_name" {
  type = string
}

variable "cloud_fn_runtime" {
  type = string
}

variable "cloud_fn_trigger" {
  type = string
}

variable "cloudfn_entry" {
  type = string
}

variable "instance_connection_name" {
  type = string
}

variable "mailgun_api" {
  type = string
}

variable "socket_path" {
  type = string
}

variable "connector_name" {
  type = string
}

variable "connector_cidr" {
  type = string
}