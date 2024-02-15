provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc" {
  for_each                        = { for idx, name in var.vpc_names : name => idx }
  name                            = each.key
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
  delete_default_routes_on_create = true

}

resource "google_compute_subnetwork" "webapp_subnet" {
  for_each      = google_compute_network.vpc
  name          = "webapp-${each.key}"
  region        = var.region
  network       = each.value.self_link
  ip_cidr_range = var.cidr_webapp

}

resource "google_compute_subnetwork" "db_subnet" {
  for_each      = google_compute_network.vpc
  name          = "db-${each.key}"
  region        = var.region
  network       = each.value.self_link
  ip_cidr_range = var.cidr_db

}

resource "google_compute_route" "webapp_route" {
  for_each         = google_compute_network.vpc
  name             = "webapp-route-${each.key}"
  network          = each.value.self_link
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
  dest_range       = "0.0.0.0/0"

}
