/*
resource "digitalocean_project" "icecream-cluster" {
  name        = "Icecream Cluster"
  description = "Distributed building of yocto using icecream"
  purpose     = "Yocto Buld"
  environment = "Development"
  #  resources   = [digitalocean_droplet.icecream.urn]
  resources = [
    "$flatten([digitalocean_droplet.icecream.*.urn])",
    "${digitalocean_droplet.scheduler.urn}"
  ]
}
*/

resource "digitalocean_droplet" "scheduler" {
  image      = var.image
  name       = "scheduler"
  region     = var.region
  size       = var.droplet_size
  ssh_keys   = [data.digitalocean_ssh_key.main.id]
  tags       = ["iceccd", "scheduler"]
  vpc_uuid   = digitalocean_vpc.icecream.id
  user_data  = file("bootstrap-scheduler.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "digitalocean_droplet" "icecream" {
  depends_on = [digitalocean_droplet.scheduler]
  count      = var.droplet_count
  image      = var.image
  name       = "node-${count.index + 1}"
  region     = var.region
  size       = var.droplet_size
  ssh_keys   = [data.digitalocean_ssh_key.main.id]
  tags       = ["iceccd", "worker", "node"]
  vpc_uuid   = digitalocean_vpc.icecream.id
  user_data  = file("bootstrap-nodes.sh")

  lifecycle {
    create_before_destroy = true
  }
}
