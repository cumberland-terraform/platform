variable "platform" {
  description               = "Platform metadata object."
  type                      = object({
    client                  = string
    environment             = string
    region                  = optional(string, null)
    subnet_type             = optional(string, null)
    availability_zones      = optional(list(string), null)
  })

  validation {
    condition               = var.platform.availability_zones == null || (
                              contains(var.platform.availability_zones, "A") 
                            ) || (
                              contains(var.platform.availability_zones, "B")
                            ) || (
                              contains(var.platform.availability_zones, "C")
                            ) || (
                              contains(var.platform.availability_zones, "D")
                            )
    error_message           = "Availability zone must be one of the following: A, B, C or D."
  }
}

variable "configuration" {
  description               = "Platform configuration object. This object is entirely optional. It can be used to set the version of platform services and adjust various settings."

  type                      = object({
    domain_name             = optional(string, null)
    docdb_engine            = optional(string, "D")
    eks_ami_version         = optional(string, "AMZN2-EKS_1.24.7")
    sql_engine              = optional(string, "P")
  })
  default                   = {
    domain_name             = null
    eks_ami_version         = "AMZN2-EKS_1.24.7"
    sql_engine              = "P"
  }

  validation {
    condition               = contains(["P", "M", "Y", "A"], var.configuration.sql_engine)
    error_message           = "SQL Engine must be P (Postgres), M (Microsoft SQL), Y (MySQL) or A (Aurora)"
  }

  validation {
    # NOTE: DocDB currently only supports a single engine type, but that may changes
    #       in the future!
    condition               = contains(["D"], var.configuration.docdb_engine)
    error_message           = "DocDB Engine must be D (DocDB)"
  }
}

variable "hydration" {
  description               = "This variable is entirely optional. This object is made of override flags that prevent certain AWS API Calls from being made. This object is essential in new accounts, when prerequisite resources have not yet been deployed. It is also useful when the platform module is being called as a submodule, to suppress unnecessary data calls."
  type                      = object({
    vpc_query               = optional(bool, true)
    subnets_query           = optional(bool, true)
    private_sg_query        = optional(bool, true)
    public_sg_query         = optional(bool, true)
    eks_ami_query           = optional(bool, false)
    acm_cert_query          = optional(bool, false)
  })
  default                   = {
    vpc_query               = true
    subnets_query           = true
    public_sg_query         = true
    private_sg_query        = true
    eks_ami_query           = false
    acm_cert_query          = false
  }
}