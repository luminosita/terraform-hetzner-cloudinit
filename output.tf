output "ip_addresses" {
    value = {
        for k, v in var.images : k => hcloud_server.vm[k].ipv4_address
    }
}