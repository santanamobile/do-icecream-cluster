output "scheduler_public_ipv4" {
  value = digitalocean_droplet.scheduler.*.ipv4_address
}

output "scheduler_private_ipv4" {
  value = digitalocean_droplet.scheduler.*.ipv4_address_private
}

output "icecream_worker_public" {
  value = digitalocean_droplet.icecream.*.ipv4_address
}

output "icecream_worker_private_ipv4" {
  value = digitalocean_droplet.icecream.*.ipv4_address_private
}
