variable "hcloud" {
    type        = object({
        ssh_public_key_file    = string
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

        vm_user         = optional(string)
        vm_ssh_public_key_files = optional(list(string))

        vm_run_cmds     = optional(list(string))
    }))
}
