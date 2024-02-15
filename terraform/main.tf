provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "webapp_subnet" {
  name          = var.webapp_subnet_name
  region        = var.region
  network       = google_compute_network.vpc.self_link
  ip_cidr_range = "10.0.1.0/24"
}

resource "google_compute_subnetwork" "db_subnet" {
  name          = var.db_subnet_name
  region        = var.region
  network       = google_compute_network.vpc.self_link
  ip_cidr_range = "10.0.2.0/24"
}

resource "google_compute_route" "webapp_route" {
  name         = "webapp-route"
  network      = google_compute_network.vpc.self_link
  next_hop_gateway = "default-internet-gateway"
  # Apply the route only to the webapp subnet
  priority     = 1000
  dest_range   = "0.0.0.0/0"
  depends_on   = [google_compute_subnetwork.webapp_subnet]
}

