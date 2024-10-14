variable "hcloud" {
    type        = object({
        ssh_public_key_file    = string
        ssh_private_key_file    = string
    })
}

variable "os" { 
    type = object({
        vm_base_image = optional(string)
        vm_snapshot_id = optional(number)
    })

    validation {
        condition     = var.os.vm_base_image != null || var.os.vm_snapshot_id != null
        error_message = "vm_base_image or vm_snapshot_id must be specified"
    }

    # validation {
    #     condition     = try(var.os.vm_snapshot_id == null, var.os.vm_snapshot_id > 0)
    #     error_message = "vm_snapshot_id must be greater than 0"
    # }
}

variable "images" {
    type        = map(object({
        vm_name         = string
        vm_location     = string
        vm_server_type  = string

        vm_cloud_init   = bool

        vm_ci_packages  = optional(object({
            enabled = optional(bool)
            content = optional(list(string))
        }), {
            enabled = true,
            content = null
        })

        vm_ci_write_files  = optional(object({
            enabled = optional(bool)
            content = optional(list(object({
                path = string
                content = string
            })))
        }), {
            enabled = true,
            content = null
        })

        vm_ci_run_cmds  = optional(object({
            enabled = optional(bool)
            content = optional(list(string))
        }), {
            enabled = true,
            content = null
        })

        vm_ci_reboot_enabled = optional(bool, false)

        vm_user         = optional(string)
        vm_ssh_public_key_files = optional(list(string))
    }))
}
