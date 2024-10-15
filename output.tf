output "result" {
    value = {
        for k, v in var.images : k => {
            ip = hcloud_server.vm[k].ipv4_address
            cloud-init = local.cloud-init-data[k]
        }
    }
}
