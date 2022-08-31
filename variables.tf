variable "prefix" {
    description = "What to prefix all resource names with in this deployment."
    default = "itpd"
    type = string
}

variable "location" {
    description = "Which geographical region to use for this deployment."
    default = "canadaeast"
    type = string
}

# Cannot use this one yet as not every occurrence can be parameterized.
# variable "login" {
#     description = "Login name for VM administrator account."
#     default = "adminuser"
#     type = string
# }

variable "public_key_file_name" {
    description = "Public key to use when provisioning the vm."
    default = "./ssh-keys/pa11y-web-server-vm-key.pub"
}

variable "user_data" {
    description = "cloud-config file for post-deployment provisioning."
    default = "./cloud-init/cloud-config.yaml"
}
