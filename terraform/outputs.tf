output "public ips" {
  value = "${join(",", digitalocean_droplet.k8s-nodes.*.ipv4_address)}"
}

output "private ips" {
  value = "${join(",", digitalocean_droplet.k8s-nodes.*.ipv4_address_private)}"
}