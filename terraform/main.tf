provider "digitalocean" {
  token = "${var.do_token}"
}

# Create appropriate tagging for our k8s cluster
resource "digitalocean_tag" "k8s-tag" {
  name = "k8s"
}

# Create our Kubernetes nodes
resource "digitalocean_droplet" "k8s-nodes" {
  count              = "${var.instance_count}"
  ssh_keys           = ["${var.instance_ssh_key_id}"]
  image              = "${var.ubuntu}"
  region             = "${var.do_tor1}"
  size               = "${var.instance_size}"
  private_networking = true
  backups            = false
  ipv6               = false
  name               = "k8s-node-${count.index + 1}"
  tags               = ["${digitalocean_tag.k8s-tag.id}"]
}