resource "hcloud_ssh_key" "default" {
  name       = "Gianni"
  public_key = file(var.root_ssh_public_key_file)
}

resource "hcloud_server" "vm" {
  for_each = toset(distinct([for k, v in var.images : k]))

  name        = each.key
  image       = var.os.vm_base_image
  datacenter  = var.images[each.key].vm_location
  server_type = var.images[each.key].vm_server_type
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  ssh_keys = [ hcloud_ssh_key.default.id ]

  user_data = templatefile("${path.module}/resources/cloud-init/vm-init.yaml.tftpl", {
    hostname      = each.key
    username      = var.images[each.key].vm_user
    pub-keys      = var.images[each.key].vm_ssh_public_key_files
    run-cmds      = var.images[each.key].vm_run_cmds
  })
}

