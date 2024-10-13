data "hcloud_ssh_key" "default" {
  name = "Gianni"
}

resource "hcloud_ssh_key" "default" {
  count = data.hcloud_ssh_key.default.public_key == null ? 1 : 0

  name       = "Gianni"
  public_key = file(var.hcloud.ssh_public_key_file)
}

resource "hcloud_primary_ip" "primary_ip" {
  for_each = toset(distinct([for k, v in var.images : k]))

  name          = "primary_ip_${each.key}"
  datacenter    = var.images[each.key].vm_location
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = true
}

resource "hcloud_server" "vm" {
  for_each = toset(distinct([for k, v in var.images : k]))

  name        = var.images[each.key].vm_name
  image       = var.os.vm_base_image != null ? var.os.vm_base_image : var.os.vm_snapshot_id
  datacenter  = var.images[each.key].vm_location
  server_type = var.images[each.key].vm_server_type
  
  public_net {
    ipv4_enabled = true
    ipv4 = hcloud_primary_ip.primary_ip[each.key].id
    ipv6_enabled = false
  }

  ssh_keys = [ data.hcloud_ssh_key.default.public_key == null ? hcloud_ssh_key.default[0].id : data.hcloud_ssh_key.default.id ]

  user_data = var.images[each.key].vm_cloud_init ? templatefile("${path.module}/resources/cloud-init/vm-init.yaml.tftpl", {
    hostname      = var.images[each.key].vm_name
    username      = var.images[each.key].vm_user
    pub-keys      = var.images[each.key].vm_ssh_public_key_files
    run-cmds      = var.images[each.key].vm_run_cmds
  }) : null
}
