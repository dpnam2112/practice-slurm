variable "vms" {
  type = map(object({
    memory_mb = number
    vcpus     = number
    ip        = string     # e.g. "192.168.122.50"
    prefix    = number     # e.g. 24
    gateway   = string     # e.g. "192.168.122.1"
    dns       = optional(list(string))
    iface     = optional(string)  # default "ens3"
    mac       = optional(string)  # optional
  }))
}

variable "base_image_path" {
  type        = string
  description = "Absolute path to the base cloud image (qcow2)"
}

variable "default_dns" {
  type        = list(string)
  description = "Fallback DNS servers"
  default     = ["8.8.8.8", "1.1.1.1"]
}
