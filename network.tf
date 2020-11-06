resource "google_compute_network" "kube-network" {
  name = "kube-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "kube-subnetwork" {
  name          = "kube-subnetwork"
  ip_cidr_range = "192.168.0.0/24"
  region        = "europe-west1"
  network       = google_compute_network.kube-network.id
}

resource "google_compute_address" "master01_external_ip" {
  name = "master01-external-ip"
  region = "europe-west1"
}

resource "google_compute_router" "router" {
  name    = "kube-router"
  region  = google_compute_subnetwork.kube-subnetwork.region
  network = google_compute_network.kube-network.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "kube-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
