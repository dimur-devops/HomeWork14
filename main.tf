terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.89.0"
    }
  }
}


provider "google" {
  project = "hazel-sphinx-325404"
  region  = "europe-central2"
  zone    = "europe-central2-a"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-builder"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-minimal-2004-lts"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}


resource "google_compute_instance" "vm_instance2" {
  name         = "terraform-app"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-minimal-2004-lts"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
}

resource "google_compute_network" "vpc_network2" {
  name                    = "terraform-network2"
  auto_create_subnetworks = "true"
}
