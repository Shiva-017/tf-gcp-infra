provider "google" {
  project = var.project_id
  region  = var.region
  credentials = file(var.cred_file)
}

resource "google_compute_network" "vpc" {
  for_each                        = { for idx, name in var.vpc_names : name => idx }
  name                            = each.key
  auto_create_subnetworks         = false
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = true

}

resource "google_compute_subnetwork" "webapp_subnet" {
  for_each      = google_compute_network.vpc
  name          = "${var.webapp_subnet_name}-${each.key}"
  region        = var.region
  network       = each.value.self_link
  ip_cidr_range = var.cidr_webapp

}

resource "google_compute_subnetwork" "db_subnet" {
  for_each      = google_compute_network.vpc
  name          = "${var.db_subnet_name}-${each.key}"
  region        = var.region
  network       = each.value.self_link
  ip_cidr_range = var.cidr_db

}

resource "google_compute_route" "webapp_route" {
  for_each         = google_compute_network.vpc
  name             = "${var.route_name}-${each.key}"
  network          = each.value.self_link
  next_hop_gateway = var.next_hop_gateway
  priority         = 1000
  dest_range       = var.route_dest

}

resource "google_compute_instance" "webapp-instance" {
  for_each = { for idx, name in var.vpc_names : name => idx }
  name = "webapp-instance-${each.key}"
  machine_type = "e2-micro"
  zone = "us-east1-b"
  boot_disk {
    initialize_params {
      image = "webapp-image"
      size = 100
      type = "pd-balanced"
    }
  }

  network_interface {
    network    = google_compute_network.vpc[each.key].self_link
    subnetwork = google_compute_subnetwork.webapp_subnet[each.key].self_link
  }

}

resource "google_compute_firewall" "allow-app-port" {
  for_each = { for idx, name in var.vpc_names : name => idx }
  name        = "allow-app-port-${each.key}"
  description = "Allow traffic from the internet to the application port"
  network     = google_compute_network.vpc[each.key].self_link
  direction   = "INGRESS"
  priority    = 1001

  allow {
    protocol = "tcp"
    ports    = ["3000"]  
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "deny-ssh" {
  for_each = { for idx, name in var.vpc_names : name => idx }
  name        = "deny-ssh-${each.key}"
  description = "Deny SSH traffic from the internet"
  network     = google_compute_network.vpc[each.key].self_link
  direction   = "EGRESS"  
  priority    = 1000

  deny {
    protocol = "tcp"
    ports    = ["22"] 
  }

  source_ranges = ["0.0.0.0/0"]
}