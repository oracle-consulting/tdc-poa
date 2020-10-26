resource "oci_core_vcn" "core_vcn" {
  cidr_block     = "13.8.16.0/22"
  dns_label      = "tdcvcntf"
  compartment_id = var.compartment_ocid
  display_name   = "TDC-VCN-Terraform"
}

resource "oci_core_internet_gateway" "core_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.core_vcn.id
  enabled        = true
  display_name   = "igtw"
}

resource "oci_core_route_table" "rt_public_subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.core_vcn.id
  display_name   = "rt_public_subnet"
  route_rules {
    network_entity_id = oci_core_internet_gateway.core_igw.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_security_list" "public_sl" {
	# rule 1 - Allow all trafic out
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.core_vcn.id
  display_name   = "sl_public_subnet"
  egress_security_rules {
		description = "All traffic for all ports"
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    # rule 2 - Allow SSH
    protocol = "6"
		description = "TCP traffic for ports: 22 SSH Remote Login Protocol"
    source   = "0.0.0.0/0"
    tcp_options {
      max = "22"
      min = "22"
    }
  }

  ingress_security_rules {
    # rule 3 - Allow HTTP Access
		description = "Allow HTTP connections"
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      max = "80"
      min = "80"
    }
  }

  ingress_security_rules {
    # rule 4 - Allow ICMP
		description = "ICMP traffic for: 3, 4 Destination Unreachable: Fragmentation Needed and Don’t Fragment Was Set"
    protocol = "1"
    source   = "0.0.0.0/0"
  }

}


resource "oci_core_subnet" "public_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.core_vcn.id
  display_name               = "public_subnet"
  cidr_block                 = "13.8.16.0/24"
  route_table_id             = oci_core_route_table.rt_public_subnet.id
  security_list_ids          = [oci_core_security_list.public_sl.id]
  dns_label                  = "publicsubnet"
  prohibit_public_ip_on_vnic = "false"
}
