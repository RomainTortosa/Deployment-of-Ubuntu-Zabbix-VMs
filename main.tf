terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"  # Fournisseur Libvirt provenant de la source "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
    uri = "qemu:///system"  # URI de connexion au système QEMU/KVM local
}

resource "libvirt_volume" "ubuntu_focal_server" {
  name   = "zabbix.qcow2"  # Nom du volume
  format = "qcow2"  # Format du volume
  source = "/home/romain.tortosa@Digital-Grenoble.local/snap/firefox/common/Downloads/ubuntu-22.04.2-desktop-amd64.iso"  # Chemin daccès du fichier ISO dinstallation dUbuntu
}

resource "libvirt_volume" "test_ubuntu" {
    name   = "test_ubuntu.qcow2"  # Nom du volume
    size = 10000000000  # Taille du volume en octets (10 Go)
}

resource "libvirt_domain" "default" {
    name   = "testvm-ubuntu1"  # Nom de la machine virtuelle
    vcpu   = 2  # Nombre de VCPUs
    memory = 2048  # Mémoire en Mo
    running = false  # La machine virtuelle ne sera pas démarrée automatiquement après sa création

    disk {
      volume_id = libvirt_volume.ubuntu_focal_server.id  # Associe le volume "ubuntu_focal_server" à la machine virtuelle
    }

    disk {
      volume_id = libvirt_volume.test_ubuntu.id  # Associe le volume "test_ubuntu" à la machine virtuelle
    }

    network_interface {
      bridge = "virbr0"  # Interface réseau utilisant le pont "virbr0"
    }

    provisioner "remote-exec" {
      inline = [
        "sudo apt-get update",
        "sudo apt-get install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent"  # Commandes exécutées à distance pour linstallation de Zabbix
      ]
    }
}