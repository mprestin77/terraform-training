/*
 * This example demonstrates how to spin up an Oracle Linux instance and get its public ip.
 */

/* Instances */

resource "oci_core_instance" "bastion" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[2]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "bastion"
  shape               = var.instance_shape

  source_details {
    source_id   = var.instance_image_id[var.region]
    source_type = "image"
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.public.id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  defined_tags = {
    "TF-lab1.owner" = var.student
  }

  timeouts {
    create = "10m"
  }
}

output "bastion_public_ip" {
  value = oci_core_instance.bastion.public_ip
}

resource "oci_core_instance" "web_server" {
  count               = var.NumInstances
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[count.index % 3]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "web${count.index + 1}"
  source_details {
    source_id   = var.instance_image_id[var.region]
    source_type = "image"
  }

  shape = var.instance_shape
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(var.user-data)
  }
  defined_tags = {
    "TF-lab1.owner" = var.student
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.private.id
    display_name     = "primaryvnic"
    assign_public_ip = false
    hostname_label   = "web${count.index + 1}"
  }
  timeouts {
    create = "10m"
  }
}

output "web_servers_ips" {
  value = oci_core_instance.web_server.*.private_ip
}

variable "user-data" {
  default = <<EOF
#!/bin/bash -x
echo '################### webserver userdata begins #####################'
touch ~opc/userdata.`date +%s`.start
# echo '########## yum update all ###############'
# yum update -y
echo '########## basic webserver ##############'
yum install -y httpd
systemctl enable  httpd.service
systemctl start  httpd.service
echo '<html><head></head><body><pre><code>' > /var/www/html/index.html
hostname >> /var/www/html/index.html
echo '' >> /var/www/html/index.html
cat /etc/os-release >> /var/www/html/index.html
echo '</code></pre></body></html>' >> /var/www/html/index.html
firewall-offline-cmd --add-service=http
systemctl enable  firewalld
systemctl restart  firewalld
touch ~opc/userdata.`date +%s`.finish
echo '################### webserver userdata ends #######################'
EOF

}

