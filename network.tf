variable "VPC-CIDR" {
  default = "10.0.0.0/16"
}

resource "oci_core_virtual_network" "TF_VCN" {
  cidr_block     = var.VPC-CIDR
  dns_label      = "tfvcn${var.student}"
  compartment_id = var.compartment_ocid
  display_name   = "TF-VCN-${var.student}"
}

resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.TF_VCN.id
  display_name   = "nat_gateway"
}

resource "oci_core_internet_gateway" "ig" {
  compartment_id = var.compartment_ocid
  display_name   = "ig"
  vcn_id         = oci_core_virtual_network.TF_VCN.id
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.TF_VCN.id
  display_name   = "public"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.ig.id
  }
}

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_ocid
  display_name   = "public"
  vcn_id         = oci_core_virtual_network.TF_VCN.id
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }
  egress_security_rules {
    protocol    = "1" //icmp
    destination = "0.0.0.0/0"
  }
  ingress_security_rules {
    tcp_options {
      max = 80
      min = 80
    }
    protocol = "6" //tcp
    source   = "0.0.0.0/0"
  }
  ingress_security_rules {
    tcp_options {
      max = 443
      min = 443
    }
    protocol = "6" //tcp
    source   = "0.0.0.0/0"
  }
  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }
    protocol = "6" // tcp
    source   = "0.0.0.0/0"
  }
  ingress_security_rules {
    protocol = "6" //tcp
    source   = var.VPC-CIDR
  }
  ingress_security_rules {
    protocol = "1" //icmp
    source   = var.VPC-CIDR
  }
}

resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.TF_VCN.id
  display_name   = "private"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gateway.id
  }
}

resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_ocid
  display_name   = "private"
  vcn_id         = oci_core_virtual_network.TF_VCN.id
  egress_security_rules {
    protocol    = "6" //tcp
    destination = "0.0.0.0/0"
  }
  egress_security_rules {
    protocol    = "1" //icmp
    destination = "0.0.0.0/0"
  }
  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }
    protocol = "6" //tcp
    source   = var.VPC-CIDR
  }
  ingress_security_rules {
    tcp_options {
      max = 80
      min = 80
    }
    protocol = "6" //tcp
    source   = "0.0.0.0/0"
  }
  ingress_security_rules {
    tcp_options {
      max = 443
      min = 443
    }
    protocol = "6" //tcp
    source   = "0.0.0.0/0"
  }
  ingress_security_rules {
    protocol = "1" //icmp
    source   = var.VPC-CIDR
  }
}

resource "oci_core_subnet" "public" {
  cidr_block        = "10.0.100.0/24"
  display_name      = "public"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.TF_VCN.id
  route_table_id    = oci_core_route_table.public.id
  security_list_ids = [oci_core_security_list.public.id]
  dhcp_options_id   = oci_core_virtual_network.TF_VCN.default_dhcp_options_id
  dns_label         = "public"
}

resource "oci_core_subnet" "private" {
  cidr_block                 = "10.0.1.0/24"
  display_name               = "private"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.TF_VCN.id
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.private.id]
  dhcp_options_id            = oci_core_virtual_network.TF_VCN.default_dhcp_options_id
  dns_label                  = "private"
  prohibit_public_ip_on_vnic = true
}

