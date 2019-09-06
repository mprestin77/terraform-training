variable "tenancy_ocid" {
}

variable "user_ocid" {
}

variable "fingerprint" {
}

variable "private_key_path" {
}

variable "region" {
}

variable "compartment_ocid" {
}

variable "ssh_public_key" {
}

variable "ssh_private_key" {
}

variable "student" {
}

# Defines the number of instances to deploy
variable "NumInstances" {
  default = "2"
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

/* Instances */

variable "instance_shape" {
  default = "VM.Standard2.2"
}

variable "instance_image_id" {
  type = map(string)

  default = {
    // Oracle-provided image "Oracle-Linux-7.5-2018.10.16-0"
    // See https://docs.us-phoenix-1.oraclecloud.com/images/
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaaoqj42sokaoh42l76wsyhn3k2beuntrh5maj3gmgmzeyr55zzrwwa"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaageeenzyuxgia726xur4ztaoxbxyjlxogdhreu3ngfj2gji3bayda"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaitzn6tdyjer7jl34h2ujz74jwy5nkbukbh55ekp6oyzwrtfa4zma"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaa32voyikkkzfxyo4xbdmadc2dmvorfxxgdhpnk6dw64fa3l4jh7wa"
  }
}

# Gets the OCID of the image. This technique is for example purposes only. The results of oci_core_images may
# change over time for Oracle-provided images, so the only sure way to get the correct OCID is to supply it directly.
#data "oci_core_images" "image-list" {
#    compartment_id = "${var.compartment_ocid}"
#    display_name = "Oracle-Linux-7.6-2019.05.28-0"
#}

variable "tag_namespace_name" {
  default = "TF-lab1"
}

