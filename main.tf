terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}
provider "libvirt" {
    uri = "qemu:///system"
}
resource "libvirt_volume" "ubuntu_focal_server" {
  name   = "zabbix.qcow2" 
  format = "qcow2"
  source = "/home/romain/Téléchargements/ubuntu-22.04.2-desktop-amd64.iso"
}
resource "libvirt_volume" "test_ubuntu" {
    name           = "test_ubuntu.qcow2"
    size = 10000000000
}
resource "libvirt_domain" "default" {
    name = "testvm-ubuntu1"
    vcpu = 2
    memory = 2048
    running = false 
    disk {
      volume_id = libvirt_volume.ubuntu_focal_server.id
    }
    disk {
      volume_id = libvirt_volume.test_ubuntu.id
    }
    network_interface {
      bridge = "virbr0"
    }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent"
    ]
  }
}

