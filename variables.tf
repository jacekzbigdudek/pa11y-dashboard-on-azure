variable "prefix" {
    description = "What to prefix all resource names with in this deployment."
    default = "jzd"
    type = string
}

variable "location" {
    description = "Which geographical region to use for this deployment."
    default = "canadaeast"
    type = string
}

variable "public_key_file_name" {
    description = "Public key to use when provisioning the vm."
    default = "~/JZD/ssh-keys/pa11y-web-server-vm-key.pub"
}

variable "user_data" {
    description = "Bash script that installs and runs the web-server."
    default = "./cloud-init/provision-web-server.txt"
}
