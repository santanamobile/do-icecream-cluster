resource "digitalocean_vpc" "icecream" {
  name     = "icecream-vpc"
  region   = var.region
  ip_range = "172.16.10.0/24"
}
