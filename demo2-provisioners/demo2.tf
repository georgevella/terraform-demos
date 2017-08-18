variable "do_token" {
    description = "Digital Ocean Token"
}

provider "digitalocean" {
   token = "${var.do_token}"   
}

variable "count" { 
    default = 1
}

output "DigitalOcean IP Addresses" {
   value = "${join(", ",digitalocean_droplet.webhost.*.ipv4_address)}"
}

resource "digitalocean_droplet" "webhost" {
    count  = "${var.count}"
    image  = "ubuntu-16-04-x64"
    name   = "demo2.webhost.${count.index}"
    region = "lon1"
    size   = "512mb"

    // ssh key reference
    ssh_keys = [
        "${digitalocean_ssh_key.ssh-key.id}"
    ]

    // provisioner   
    provisioner "remote-exec" {
        inline = [
            "sudo apt-get update",
            "sudo apt-get -y install nginx",
        ]

        connection {
            type = "ssh"
            user = "root"
            private_key = "${file("../demo_id_rsa")}"
        }
    }
}

resource "digitalocean_ssh_key" "ssh-key" {
    name = "TerraformDemo2"
    public_key = "${file("../demo_id_rsa.pub")}"
}