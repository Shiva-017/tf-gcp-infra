provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = var.cred_file
}

resource "google_compute_network" "vpc" {
  provider                        = google
  project = var.project_id
  name                            = var.vpc_name
  auto_create_subnetworks         = false
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = true

}

resource "google_compute_subnetwork" "webapp_subnet" {
  provider      = google
  name          = "${var.webapp_subnet_name}-${var.vpc_name}"
  project = google_compute_network.vpc.project
  region        = var.region
  network       = google_compute_network.vpc.self_link
  ip_cidr_range = var.cidr_webapp
  private_ip_google_access = true

}

resource "google_compute_route" "webapp_route" {
  name             = "${var.route_name}-${var.vpc_name}"
  network          = google_compute_network.vpc.self_link
  next_hop_gateway = var.next_hop_gateway
  priority         = var.route_priority
  dest_range       = var.route_dest

}

# Random password generation for the Cloud SQL user
resource "random_password" "password" {
  length           = 16
  special          = false
}

resource "google_service_account" "webapp_service_account" {
  account_id   = var.monitoring_account_id
  display_name = "WebApp Monitoring Service Account"
}

resource "google_project_iam_binding" "monitoring_logs_binding" {
  project = var.project_id
  role    = var.monitoring_logs_binding

  members = [
    "serviceAccount:${google_service_account.webapp_service_account.email}"]
}

resource "google_project_iam_member" "webapp_service_account_logging_admin" {
  project = var.project_id
  role    = var.loggingAdmin
  member  = "serviceAccount:${google_service_account.webapp_service_account.email}"
}

resource "google_project_iam_member" "webapp_service_account_monitoring_metric_writer" {
  project = var.project_id
  role    = var.metricsWriter
  member  = "serviceAccount:${google_service_account.webapp_service_account.email}"
}

resource "google_compute_instance" "webapp-instance" {
  name         = "${var.instance_name}-${var.vpc_name}"
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
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.webapp_subnet.name
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }

  }
  allow_stopping_for_update = true
  service_account {
    email  = google_service_account.webapp_service_account.email
    scopes = [var.scopes]
  }
   metadata_startup_script = templatefile("startup.tpl", {
    db_name     = var.db_name,
    db_user     = var.db_user,
    db_password = random_password.password.result,
    db_host     = google_sql_database_instance.default.private_ip_address,
    db_port     = var.db_port
  })

  tags = [var.firewall_allow_tag, var.firewall_deny_tag]
  depends_on = [ random_password.password, google_sql_database.webapp, google_compute_address.static_ip ]
}

resource "google_compute_firewall" "allow-app-port" {
  name     = "${var.firewall_allow}-${var.vpc_name}"
  network  = google_compute_network.vpc.self_link

  allow {
    protocol = var.protocol
    ports    = [var.app_port]
  }

  source_ranges = [var.route_dest]
  target_tags = [var.firewall_allow_tag]
}



resource "google_compute_firewall" "deny-ssh" {
  name     = "${var.firewall_deny}-${var.vpc_name}"
  network  = google_compute_network.vpc.self_link

  deny {
    protocol = var.protocol
    ports    = [var.ssh_port]
  }

  source_ranges = [var.route_dest]
  target_tags = [var.firewall_deny_tag]
}

resource "google_compute_global_address" "default" {
  provider     = google
  project      = var.project_id
  name         = "global-psconnect-ip-${var.vpc_name}"
  address_type = var.address_type
  purpose      = var.purpose
  network      = google_compute_network.vpc.self_link
  prefix_length = var.prefix_length
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google
  network                 = google_compute_network.vpc.self_link
  service                 = var.service
  reserved_peering_ranges = [google_compute_global_address.default.name]
  deletion_policy         = var.deletion_policy
}



# Cloud SQL instance
resource "google_sql_database_instance" "default" {
  name             = "${var.vpc_name}-cloudsql-instance"
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
      private_network = google_compute_network.vpc.self_link
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
  name     = var.db_user
  instance = google_sql_database_instance.default.name
  password = random_password.password.result
}
 
# Database within the Cloud SQL instance
resource "google_sql_database" "webapp" {
  name     = var.db_name
  instance = google_sql_database_instance.default.name
}

# Static external IP for instance
resource "google_compute_address" "static_ip" {
  name   = var.static_ip_name
  region = var.region
}

# A name
resource "google_dns_record_set" "a_record" {
  name = var.domain
  type = var.recordType
  ttl  = var.ttl
  managed_zone = var.managed_zone
  rrdatas = [google_compute_instance.webapp-instance.network_interface[0].access_config[0].nat_ip]
  depends_on = [ google_compute_instance.webapp-instance ]
}

# MX record for the domain
resource "google_dns_record_set" "mx_record" {
  name         = var.domain
  type         = "MX"
  ttl          = var.ttl
  managed_zone = var.managed_zone
  rrdatas      = var.MX_values
}

resource "google_dns_record_set" "txt_record1" {
  name         = var.domain
  type         = "TXT"
  ttl          = var.ttl 
  managed_zone = var.managed_zone
  rrdatas      = var.TXT1
}

resource "google_dns_record_set" "txt_record2" {
  name         = var.TXT2_Domain
  type         = "TXT"
  ttl          = var.ttl
  managed_zone = var.managed_zone
  rrdatas      = var.TXT2
}

resource "google_dns_record_set" "cname_record" {
  name         = "email.${var.domain}" 
  type         = "CNAME"
  ttl          = var.ttl
  managed_zone = var.managed_zone
  rrdatas      = var.CNAME_value
}


# pub/sub topic
resource "google_pubsub_topic" "verify_email_topic" {
  name = var.pub_sub_topic
}

# pub/sub subscription
resource "google_pubsub_subscription" "verify_email_subscription" {
  name  = var.pub_sub_sub
  topic = google_pubsub_topic.verify_email_topic.name

  ack_deadline_seconds = 20
}

# service account: cloud function
resource "google_service_account" "cloud_function_sa" {
  account_id   = var.cloud_fn_acc_id
  display_name = "Cloud Function Mailgun Service Account"
}

# role: pub/sub subscriber
resource "google_project_iam_member" "pubsub_subscriber" {
  project = var.project_id
  role    = var.pub_sub_subscriber
  member  = "serviceAccount:${google_service_account.cloud_function_sa.email}"
}

# role: pub/sub publisher
resource "google_project_iam_member" "pubsub_publisher" {
  project = var.project_id
  role    = var.pub_sub_publisher
  member  = "serviceAccount:${google_service_account.webapp_service_account.email}"
}

# role: secret accessor
resource "google_project_iam_member" "secret_accessor" {
  project = var.project_id
  role    = var.secret_accessor
  member  = "serviceAccount:${google_service_account.cloud_function_sa.email}"
}

# role: function invoker
resource "google_project_iam_member" "function_invoker" {
  project = var.project_id
  role    = var.function_invoker
  member  = "serviceAccount:${google_service_account.cloud_function_sa.email}"
}

# role: function invoker
resource "google_project_iam_member" "sql_client" {
  project = var.project_id
  role    = var.sql_client
  member  = "serviceAccount:${google_service_account.cloud_function_sa.email}"
}

# role: service account token creator
resource "google_project_iam_member" "service_account_token_creator" {
  project = var.project_id
  role    = var.sa_creator
  member  = "serviceAccount:${google_service_account.cloud_function_sa.email}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 2
}
resource "google_storage_bucket" "function_source_bucket" {
  name     = "${var.storage_bucket_name}-${random_id.bucket_suffix.hex}"
  location = "US"
}

resource "google_storage_bucket_object" "function_source_zip" {
  name   = var.storage_object_name
  bucket = google_storage_bucket.function_source_bucket.name
  source = "./cloudFn.zip"
}

# cloud function
resource "google_cloudfunctions_function" "verify_email_function" {
  name        = var.cloud_fn_name
  description = "Function to verify email addresses"
  runtime     =  var.cloud_fn_runtime

  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.function_source_bucket.name
  source_archive_object = google_storage_bucket_object.function_source_zip.name

  event_trigger {
    event_type = var.cloud_fn_trigger
    resource = google_pubsub_topic.verify_email_topic.id
  }
  vpc_connector = google_vpc_access_connector.default.id

  entry_point = var.cloudfn_entry

  service_account_email = google_service_account.cloud_function_sa.email

  environment_variables  = {
    DB_HOST                 = google_sql_database_instance.default.private_ip_address
    DB_NAME                 = var.db_name,
    DB_PASS                 = random_password.password.result,
    DB_USER                 = var.db_user,
    INSTANCE_CONNECTION_NAME = var.instance_connection_name,
    MAILGUN_API_KEY        = var.mailgun_api,
    MAILGUN_DOMAIN         = var.domain,
    SOCKET_PATH            = var.socket_path
  }

  project = var.project_id
  region  = var.region
}

# Serverless VPC Access connector
resource "google_vpc_access_connector" "default" {
  name          = var.connector_name
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = var.connector_cidr
}

