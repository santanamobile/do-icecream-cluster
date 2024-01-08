# Our DigitalOcean API token.
variable "do_token" {}

# Name of your SSH Key as it appears in the DigitalOcean dashboard
variable "ssh_key" {
  type = string
}

# Name of your project. Will be prepended to most resources
variable "name" {
  type    = string
  default = "vps-icecream"
}

# The region to deploy our infrastructure to.
variable "region" {
  type    = string
  default = "nyc1"
}

# The number of droplets to create.
variable "droplet_count" {
  type    = number
  default = 1
}

variable "droplet_size" {
  type    = string
  default = "s-1vcpu-512mb-10gb"
}

variable "image" {
  type    = string
  default = "ubuntu-20-04-x64"
}
