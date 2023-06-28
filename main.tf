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
  source = "/home/romain.tortosa@Digital-Grenoble.local/snap/firefox/common/Downloads/ubuntu-22.04.2-desktop-amd64.iso"  
  # Chemin daccès du fichier ISO dinstallation dUbuntu
}

resource "libvirt_volume" "test_ubuntu" {
    name   = "test_ubuntu.qcow2"  # Nom du volume
    size = 10000000000  # Taille du volume en octets (10 Go)
}

resource "libvirt_domain" "default" {
    name   = "ubuntu"  # Nom de la machine virtuelle
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

    provisioner "file" {
      source      = "preseed.cfg"
      destination = "/tmp/preseed.cfg"
 # Configuration de la connexion
    connection {
      type        = "ssh"
      user        = "votre_utilisateur_ssh"
      private_key = file("~/.ssh/id_ed25519.pub")  # Chemin vers votre clé privée SSH
      host        = "votre_hôte_ssh"
    }
  }


    provisioner "remote-exec" {
    inline = [
        "sudo debconf-set-selections /tmp/preseed.cfg",
        "sudo rm /tmp/preseed.cfg"
      ]
    }
}

