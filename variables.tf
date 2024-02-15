variable "project_id" {
  description = "Google Cloud Project ID"
}

variable "region" {
  description = "Google Cloud region"
}

variable "vpc_names" {
  description = "Names of VPCs"
  type    = list(string)
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
