variable "do_token" {
    description = "Digital Ocean Token"
}

provider "digitalocean" {
   token = "${var.do_token}"   
}

variable "names" {
    type = "list"
    default = [
        "demo4.web.0",
        "demo4.web.1"
    ]
}

output "DigitalOcean IP Addresses" {
   value = "${join(", ",digitalocean_droplet.webhost.*.ipv4_address)}"
}

resource "digitalocean_droplet" "webhost" {
    count  = "${length(var.names)}"
    image  = "ubuntu-16-04-x64"
    name   = "${var.names[count.index]}"
    region = "lon1"
    size   = "512mb"

    // ssh key reference
    ssh_keys = [
        "${digitalocean_ssh_key.ssh-key.id}"
    ]

    // provisioner
    provisioner "file" {
        content = "${element(data.template_file.indexpage.*.rendered, count.index)}"
        destination = "/tmp/index.html"

        connection {
            type = "ssh"
            user = "root"
            private_key = "${file("../demo_id_rsa")}"
        }
    }

    provisioner "remote-exec" {
        inline = [
            "sudo apt-get update",
            "sudo apt-get -y install nginx",
            "mv /tmp/index.html /var/www/html/index.html"
        ]

        connection {
            type = "ssh"
            user = "root"
            private_key = "${file("../demo_id_rsa")}"
        }
    }
}

resource "digitalocean_ssh_key" "ssh-key" {
    name = "TerraformDemo"
    public_key = "${file("../demo_id_rsa.pub")}"
}

data "template_file" "indexpage" {
  template = "${file("./index.tpl")}"
  count  = "${length(var.names)}"
  vars {
    # machine_name = "${var.names[count.index]}"
    machine_name = "${element(var.names, count.index)}"
  }
}