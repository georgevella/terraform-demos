variable "count" { 
    default = 2
}

variable "names" {
    type = "list"
    default = [
        "web.0",
        "web.1"
    ]
}

resource "null_resource" "export_rendered_template" {
    count  = "${var.count}"

    provisioner "local-exec" {
        command = "echo ${element(data.template_file.index.*.rendered, count.index)}"
    }
    # provisioner "file" {
    #     content = "${data.template_file.index.rendered}"
    #     destination = "index.html"
    # }
}

data "template_file" "index" {
  template = "${file("./index.tpl")}"   
  count = "${var.count}" 
  vars {
      machine_name = "${element(var.names, count.index)}"
  }
}