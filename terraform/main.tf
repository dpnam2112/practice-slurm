provider "libvirt" {
  uri = "qemu:///system"
}

# One volume per VM
resource "libvirt_volume" "os" {
  for_each = var.vms
  name     = "${each.key}-os.qcow2"
  pool     = "default"
  source   = var.base_image_path
  format   = "qcow2"
}

# cloud-init runs inside the VM at first boot to apply user-data (users, SSH keys, etc.)
# Normally, on real clouds (AWS/GCP/Azure), this metadata is provided automatically via an
# internal API. Here we attach it manually since libvirt/KVM lacks that built-in mechanism.
resource "libvirt_cloudinit_disk" "seed" {
  for_each       = var.vms
  name           = "${each.key}-seed.iso"
  pool           = "default"
  user_data      = templatefile("${path.module}/cloud-init.tmpl.yml", {
    hostname = each.key
  })
  network_config = templatefile("${path.module}/network-config.tmpl.yml", {
    iface   = lookup(each.value, "iface", "ens3")
    ip      = each.value.ip
    prefix  = each.value.prefix
    gateway = each.value.gateway
    dns     = coalesce(try(each.value.dns, null), var.default_dns)
  })
}

# Define the database VMs
resource "libvirt_domain" "vm" {
  for_each = var.vms
  name     = each.key
  memory   = each.value.memory_mb
  vcpu     = each.value.vcpus

  # A small caution: many cloud images expect virtio devices and serial console.
  disk { volume_id = libvirt_volume.os[each.key].id }
  cloudinit = libvirt_cloudinit_disk.seed[each.key].id

  network_interface {
    network_name = "default"  # NAT network
  }

  # Enable a serial console so `virsh console` works
  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "none"
    autoport    = true
  }

  # Optional CPU model tweaks
  cpu {
    mode = "host-passthrough"
  }

  # Metadata helpful for troubleshooting
  provisioner "local-exec" {
    command = "echo VM ${self.name} created with IP will appear after DHCP."
  }
}
