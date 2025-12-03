output "vm_names" {
  value = keys(var.vms)
}

output "hint_get_ip" {
  value = "Use: virsh domifaddr <vm> --source agent  (after qemu-guest-agent starts)"
}

