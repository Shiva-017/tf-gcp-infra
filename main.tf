provider "google" {
  project     = var.project_id
  region      = var.region
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
  for_each     = { for idx, name in var.vpc_names : name => idx }
  name         = "${var.instance_name}-${each.key}"
  machine_type = var.machine_type
  zone         = var.instance_zone
  boot_disk {
    initialize_params {
      image = var.image_name
      size  = var.size
      type  = var.disk_type
    }
  }

  network_interface {
    network    = google_compute_network.vpc[each.key].name
    subnetwork = google_compute_subnetwork.webapp_subnet[each.key].name
    access_config {
    }

  }
  metadata = {
  }
  tags = [var.firewall_allow_tag, var.firewall_deny_tag]
}

resource "google_compute_firewall" "allow-app-port" {
  for_each = { for idx, name in var.vpc_names : name => idx }
  name     = "${var.firewall_allow}-${each.key}"
  network  = google_compute_network.vpc[each.key].self_link

  allow {
    protocol = var.protocol
    ports    = [var.app_port]
  }

  source_ranges = [var.route_dest]
  target_tags = [var.firewall_allow_tag]
}

resource "google_compute_firewall" "deny-ssh" {
  for_each = { for idx, name in var.vpc_names : name => idx }
  name     = "${var.firewall_deny}-${each.key}"
  network  = google_compute_network.vpc[each.key].self_link

  deny {
    protocol = var.protocol
    ports    = [var.ssh_port]
  }

  source_ranges = [var.route_dest]
  target_tags = [var.firewall_deny_tag]
}
