resource "google_compute_instance" "master01" {
  name        = "master01"
  machine_type= "e2-medium"

  tags = ["master"]

  provisioner "file" {
    source = "files/deploy_master.sh"
    destination = "~/deploy_master.sh"
    connection {
      host = self.network_interface[0].access_config[0].nat_ip
      user = "master"
      type = "ssh"
      private_key = "${file(var.ssh_private)}"
    }
  }

  provisioner "file" {
    source = "files/deploy_node.sh"
    destination = "~/deploy_node.sh"
    connection {
      host = self.network_interface[0].access_config[0].nat_ip
      user = "master"
      type = "ssh"
      private_key = "${file(var.ssh_private)}"
    }
  }

  provisioner "file" {
    source = var.ssh_private
    destination = "~/.ssh/id_rsa"
    connection {
      host = self.network_interface[0].access_config[0].nat_ip
      user = "master"
      type = "ssh"
      private_key = "${file(var.ssh_private)}"
    }
  }

  provisioner "file" {
    source = var.ssh_key
    destination = "~/.ssh/id_rsa.pub"
    connection {
      host = self.network_interface[0].access_config[0].nat_ip
      user = "master"
      type = "ssh"
      private_key = "${file(var.ssh_private)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/deploy_master.sh",
      "chmod +x ~/deploy_node.sh", 
      "cd ~",
      "./deploy_master.sh"
    ]
    
    connection {
      host = self.network_interface[0].access_config[0].nat_ip
      type = "ssh"
      user = "master"
      private_key = "${file(var.ssh_private)}"
    }
  }

  boot_disk {
    initialize_params {
      image   = "ubuntu-2004-focal-v20201014"
    }
  }

  network_interface {
    subnetwork   = google_compute_subnetwork.kube-subnetwork.id
    network_ip = "192.168.0.2"
    access_config {
      nat_ip = google_compute_address.master01_external_ip.address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_key)}"
  }
}

resource "google_compute_instance" "node01" {
  name        = "node01"
  machine_type= "e2-medium"

  tags = ["node"]

  boot_disk {
    initialize_params {
      image   = "ubuntu-2004-focal-v20201014"
    }
  }

  network_interface {
    subnetwork   = google_compute_subnetwork.kube-subnetwork.id
    network_ip = "192.168.0.3"
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_key)}"
  }
}

resource "google_compute_instance" "node2" {
  name        = "node02"
  machine_type= "e2-medium"

  tags = ["node"]

  boot_disk {
    initialize_params {
      image   = "ubuntu-2004-focal-v20201014"
    }
  }

  network_interface {
    subnetwork   = google_compute_subnetwork.kube-subnetwork.id
    network_ip = "192.168.0.4"
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_key)}"
  }
}
