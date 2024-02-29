provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.cred_file)
}

resource "google_compute_network" "vpc" {
  for_each                        = { for idx, name in var.vpc_names : name => idx }
  provider                        = google
  project = var.project_id
  name                            = each.key
  auto_create_subnetworks         = false
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = true

}

resource "google_compute_subnetwork" "webapp_subnet" {
  for_each      = google_compute_network.vpc
  provider      = google
  name          = "${var.webapp_subnet_name}-${each.key}"
  project = each.value.project
  region        = var.region
  network       = each.value.self_link
  ip_cidr_range = var.cidr_webapp
  private_ip_google_access = true

}

resource "google_compute_route" "webapp_route" {
  for_each         = google_compute_network.vpc
  name             = "${var.route_name}-${each.key}"
  network          = each.value.self_link
  next_hop_gateway = var.next_hop_gateway
  priority         = var.route_priority
  dest_range       = var.route_dest

}

# Random password generation for the Cloud SQL user
resource "random_password" "password" {
  for_each     = { for idx, name in var.vpc_names : name => idx }
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
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
   metadata_startup_script = templatefile("startup.tpl", {
    db_name     = var.db_name,
    db_user     = var.db_user,
    db_password = random_password.password[each.key].result,
    db_host     = google_sql_database_instance.default[each.key].private_ip_address,
    db_port     = var.db_port
  })

  tags = [var.firewall_allow_tag, var.firewall_deny_tag]
  depends_on = [ random_password.password, google_sql_database.webapp ]
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

resource "google_compute_global_address" "default" {
  for_each     = { for idx, name in var.vpc_names : name => idx }
  provider     = google
  project      = var.project_id
  name         = "global-psconnect-ip-${each.key}"
  address_type = var.address_type
  purpose      = var.purpose
  network      = google_compute_network.vpc[each.key].self_link
  prefix_length = var.prefix_length
}

resource "google_service_networking_connection" "private_vpc_connection" {
  for_each                = { for idx, name in var.vpc_names : name => idx }
  provider                = google
  network                 = google_compute_network.vpc[each.key].self_link
  service                 = var.service
  reserved_peering_ranges = [google_compute_global_address.default[each.key].name]
  deletion_policy         = var.deletion_policy
}



# Cloud SQL instance
resource "google_sql_database_instance" "default" {
  for_each = { for idx, name in var.vpc_names : name => idx }
  name             = "${each.key}-cloudsql-instance"
  region           = var.region
  database_version = var.database_version
  deletion_protection = false
  settings {
    tier = var.db_tier
    disk_size       = var.size
    disk_type       = var.db_disk_type
    availability_type = var.db_availability
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc[each.key].self_link
    }
    backup_configuration {
      enabled                        = true
      binary_log_enabled             = true
      start_time                     = var.start_time
      transaction_log_retention_days = var.tlr_days
    }
  }
  depends_on = [
    google_compute_global_address.default,
    google_service_networking_connection.private_vpc_connection
  ]
}


# Cloud SQL database user with a randomly generated password
resource "google_sql_user" "webapp_user" {
   for_each = { for idx, name in var.vpc_names : name => idx }
  name     = var.db_user
  instance = google_sql_database_instance.default[each.key].name
  password = random_password.password[each.key].result
}
 
# Database within the Cloud SQL instance
resource "google_sql_database" "webapp" {
  for_each = { for idx, name in var.vpc_names : name => idx }
  name     = var.db_name
  instance = google_sql_database_instance.default[each.key].name
}

