resource "google_compute_firewall" "master_firewall" {
  name    = "master-firewall"
  network = google_compute_network.kube-network.name

  allow {
    protocol = "tcp"
    ports    = ["6443", "2379-2380", "10250", "10251", "10252"]
  }

  target_tags = ["master"]
}

resource "google_compute_firewall" "node_firewall" {
  name    = "node-firewall"
  network = google_compute_network.kube-network.name

  allow {
    protocol = "tcp"
    ports    = ["10250", "30000-32767"]
  }

  target_tags = ["node"]
}

resource "google_compute_firewall" "default" {
  name    = "default-firewall"
  network = google_compute_network.kube-network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
