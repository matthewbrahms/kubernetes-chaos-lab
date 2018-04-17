provider "digitalocean" {
  token = "${var.do_token}"
}

# Create appropriate tagging for our k8s cluster
resource "digitalocean_tag" "k8s-tag" {
  name = "k8s"
}

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
/*
  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "apt-get update && apt-get install -y apt-transport-https",
      "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -",
      "cat <<EOF >/etc/apt/sources.list.d/kubernetes.list \
       deb http://apt.kubernetes.io/ kubernetes-xenial main
       EOF"
      "apt-get install -y kubelet kubeadm kubectl docker.io",
    ]

    connection {
      type        = "ssh"
      private_key = "${file("~/.ssh/ansible_lab")}"
      user        = "root"
      timeout     = "2m"
    }
  }
*/
}

