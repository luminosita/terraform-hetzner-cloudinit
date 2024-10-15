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

locals {
    cloud-init-template-data = {
        for k, v in var.images : k => var.images[k].vm_cloud_init ? templatefile("${path.module}/resources/cloud-init/vm-init.yaml.tftpl", {
            hostname      = k
            username      = var.images[k].vm_user
            pub-keys      = var.images[k].vm_ssh_public_key_files
            run-cmds-enabled        = var.images[k].vm_ci_run_cmds.enabled
            run-cmds-content        = var.images[k].vm_ci_run_cmds.content
            packages-enabled        = var.images[k].vm_ci_packages.enabled
            packages-content        = var.images[k].vm_ci_packages.content
            write-files-enabled     = var.images[k].vm_ci_write_files.enabled
            write-files-content     = var.images[k].vm_ci_write_files.content
            reboot-enabled          = var.images[k].vm_ci_reboot_enabled
        }) : null
    }

    cloud-init-data = {
        for k, v in var.images : k => var.images[k].vm_cloud_init_data == null ? local.cloud-init-template-data[k] : var.images[k].vm_cloud_init_data
    }
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

  user_data = local.cloud-init-data[each.key]

  connection {
    type            = "ssh"
    user            = var.images[each.key].vm_user
    host            = self.ipv4_address
    timeout         = "1m"
    agent           = false
    private_key     = file(var.hcloud.ssh_private_key_file)    
  }

  provisioner "remote-exec" {
    inline = [ var.images[each.key].vm_cloud_init ? "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for Cloud-Init...'; sleep 1; done" : "" ]
  }
}
