variable "tenancy_ocid" {
    description = "OCID do tenancy"
    default     = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}

variable "user_ocid" {
    description = "OCID do usuário Terraform"
    default     = "ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}

variable "fingerprint" {
    default     = "xd:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
}

variable "region" {
    default     = "us-ashburn-1"
}

variable "ad_region_mapping" {
  type = map(string)

  default = {
    us-ashburn-1 = 1
    us-ashburn-2 = 2
    us-ashburn-3 = 3
  }
}
variable "private_key_path" {
		description = "Caminho da private key SSH"
    default     = "~/.mykeys/terraform_api_key.pem"
}

variable "compartment_ocid" {
    description = "OCID do Compartment TDC"
    default     = "ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}

variable "instance_shape_always_free" {
	description = "Shape Always Free"
	default = "VM.Standard.E2.1.Micro"
}

variable "ubuntu_20_04_image_ocid" {
	description = "OCID da image Ubunt 20.04 - https://docs.cloud.oracle.com/en-us/iaas/images/ubuntu-2004/"
	default = "ocid1.image.oc1.iad.aaaaaaaava52km5tsiuwrig2fgz5wzb2cz4ms3fglns6ephkotbt7zriblga"
}

variable "ssh_public_key" {
		description = "Local onde a chave SSH publica que será configurada na VM está armazenado"
    default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key" {
		description = "Local onde a chave SSH privada que será configurada na VM está armazenado"
    default     = "~/.ssh/id_rsa"
}
