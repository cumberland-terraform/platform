# Enterprise Terraform 
## Cumberland Cloud Platform

This is the Cumberland CLoud Platform module. It provides the baseline configuration for the Cumberland Cloud platform. All Cumberland Cloud modules use this repository as a submodule to enforce consistent naming standards and provide access to platform level information.

### Usage

***providers.tf**

```hcl
provider "aws" {
    region                  = "us-east-1"

    assume_role {
        role_arn            = "arn:aws:iam::<target-account>:role/<target-role>"
    }
}
```

**modules.tf**

```
module "platform" {
	source 					    = "github.com/cumberland-terraform/platform"
	
	platform                    = {
        client                  = "<client>"
        environment             = "<environment>"
        subnet_type             = "<subnet-type>"
        availability_zones      = [ "<availability_zone>" ]
    }
}
```

### Lookup Values

This table details the valid values for each ``platform`` variable,

TODO: pretty picture