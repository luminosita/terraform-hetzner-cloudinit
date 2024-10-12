variable "root_ssh_public_key_file" {
  type = string
}

variable "os" { 
    type = object({
        vm_base_image = string
    })
}

variable "images" {
    type        = map(object({
        vm_name         = string
        vm_location     = string
        vm_server_type  = string

        vm_user         = string
        vm_ssh_public_key_files = list(string)

        vm_run_cmds     = list(string)
    }))
}
