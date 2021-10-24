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

resource "google_compute_instance" "vm_builder" {
  name         = "terraform-builder"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-minimal-2004-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "dimamuro91"
      timeout     = "500s"
      private_key = "${file("/home/dmitriy/homework14/google_key.pem")}"
      host        = "${google_compute_instance.vm_builder.network_interface.0.access_config.0.nat_ip}"
    }

    inline = [
      "sudo apt-get update",
      "sudo apt-get install maven -y",
      "sudo apt-get install git -y",
      "git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git",
      "sudo mvn package -f boxfuse-sample-java-war-hello",
    ]
  }
}



resource "google_compute_instance" "vm_app" {
  name         = "terraform-app"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-minimal-2004-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "dimamuro91"
      timeout     = "500s"
      private_key = "${file("/home/dmitriy/homework14/google_key.pem")}"
      host        = "${google_compute_instance.vm_app.network_interface.0.access_config.0.nat_ip}"
    }

    source      = "google_key.pem"
    destination = "/tmp/google_key.pem"
  }


  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "dimamuro91"
      timeout     = "500s"
      private_key = "${file("/home/dmitriy/homework14/google_key.pem")}"
      host        = "${google_compute_instance.vm_app.network_interface.0.access_config.0.nat_ip}"
    }

    inline = [
      "sudo apt-get update",
      "sudo apt-get install tomcat9 -y",
      "sudo chmod 400 /tmp/google_key.pem",
      "sudo scp -i /tmp/google_key.pem -o StrictHostKeyChecking=no dimamuro91@${google_compute_instance.vm_builder.network_interface.0.access_config.0.nat_ip}:boxfuse-sample-java-war-hello/target/hello-1.0.war /var/lib/tomcat9/webapps"
    ]
  }


}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}