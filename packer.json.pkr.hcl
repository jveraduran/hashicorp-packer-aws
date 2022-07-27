# This file was autogenerated by the 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# Avoid mixing go templating calls ( for example ```{{ upper(`string`) }}``` )
# and HCL2 calls (for example '${ var.string_value_example }' ). They won't be
# executed together and the outcome will be unknown.

# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info.
variable "aws_access_key" {
  type    = string
  default = "${env("AWS_ACCESS_KEY")}"
}

variable "aws_secret_key" {
  type    = string
  default = "${env("AWS_SECRET_KEY")}"
}

variable "region" {
  type    = string
  default = "${env("AWS_REGION")}"
}

variable "consul_http_addr" {
  type    = string
  default = "${env("CONSUL_HTTP_ADDR")}"
}

variable "consul_http_token" {
  type    = string
  default = "${env("CONSUL_HTTP_TOKEN")}"
}
# https://www.packer.io/docs/templates/hcl_templates/functions/contextual/consul
locals {
  ssh_username  = "${consul_key("polymathes/temporal/packer/ssh-username")}"
  ami_name      = "${consul_key("polymathes/temporal/packer/ami-name")}"
  source_ami    = "${consul_key("polymathes/temporal/packer/source-ami")}"
  instance_type = "${consul_key("polymathes/temporal/packer/instance-type")}"
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
# https://www.packer.io/plugins/builders/amazon/ebs
source "amazon-ebs" "ami" {
  access_key            = "${var.aws_access_key}"
  ami_name              = "${local.ami_name}-v1.0.0"
  force_delete_snapshot = true
  instance_type         = "${local.instance_type}"
  region                = "${var.region}"
  secret_key            = "${var.aws_secret_key}"
  source_ami            = "${local.source_ami}"
  ssh_username          = "${local.ssh_username}"
  tags = {
    Name     = "${local.ami_name}"
  }
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.amazon-ebs.ami"]

# details about provisioner in the documentation
# https://www.packer.io/docs/provisioners/shell
  provisioner "shell" {
    inline = ["mkdir ~/ssh-conf"]
  }

# details about provisioner in the documentation
# https://www.packer.io/plugins/provisioners/ansible/ansible
  provisioner "ansible" {
    playbook_file = "../ansible/k8s.yaml"
    user          = "ubuntu"
  }

# details about provisioner in the documentation
# https://www.packer.io/docs/provisioners/file
  provisioner "file" {
    source      = "../ssh/ssh_config"
    destination = "~/ssh-conf/ssh_config"
  }
}
