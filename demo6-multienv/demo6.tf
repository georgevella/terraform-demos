provider "digitalocean" {
   token = "${var.do_token}"   
}

resource "digitalocean_droplet" "webhost" {
    count  = "${terraform.workspace == "default" ? 1 : 2}"
    image  = "ubuntu-16-04-x64"
    name   = "${terraform.workspace}.demo6.webhost.${count.index}"
    region = "lon1"
    size   = "512mb"

    // ssh key reference
    ssh_keys = [
        "${digitalocean_ssh_key.ssh-key.id}"
    ]
}

resource "digitalocean_ssh_key" "ssh-key" {
    name = "TerraformDemo1"
    public_key = "${file("../demo_id_rsa.pub")}"
}

variable "do_token" {
    description = "Digital Ocean Token"
}

variable "env" {
    default = "dev"
}

output "DigitalOcean IP Addresses" {
   value = "${join(", ",digitalocean_droplet.webhost.*.ipv4_address)}"
}