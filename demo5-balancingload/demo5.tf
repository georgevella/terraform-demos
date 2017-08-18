variable "do_token" {
    description = "Digital Ocean Token"
}

variable "aws_access_key" {
    description = "AWS Access Key"
}

variable "aws_secret_key" {
    description = "AWS Secret Key"
}

variable "environment" {
    default = "demo5"
}

variable "names" {
    type = "list"
    default = [
        "web.0",
        "web.1"
    ]
}

output "DigitalOcean IP Addresses" {
   value = "${join(", ",digitalocean_droplet.webhost.*.ipv4_address)}"
}

# providers

provider "digitalocean" {
   token = "${var.do_token}"   
}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region     = "us-east-1"
}

resource "digitalocean_droplet" "webhost" {
    count  = "${length(var.names)}"
    image  = "ubuntu-16-04-x64"
    name   = "${var.environment}.${var.names[count.index]}"
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
    name = "Terraform${var.environment}"
    public_key = "${file("../demo_id_rsa.pub")}"
}

# template for index.html page

data "template_file" "indexpage" {
  template = "${file("./index.tpl")}"
  count  = "${length(var.names)}"
  vars {
    machine_name = "${element(var.names, count.index)}"
  }
}

# route53 configuration
resource "aws_route53_record" "demo5" {
    zone_id = "${data.aws_route53_zone.experiments.zone_id}"
    name    = "demo5.${data.aws_route53_zone.experiments.name}"
    type    = "A"
    ttl     = "1"
    records = ["${digitalocean_droplet.webhost.*.ipv4_address}"]

    weighted_routing_policy {
        weight = 1
    }

    set_identifier = "live"
}

data "aws_route53_zone" "experiments" {
  name         = "experiments.georgevella.com."
  private_zone = false
}
