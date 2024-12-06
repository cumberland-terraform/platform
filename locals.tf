locals {

    ########################################################################################
    ### STEP 1: LOAD METADATA
    ########################################################################################
    clients                                 = jsondecode(
                                                file("${path.module}/metadata/clients.json")
                                            )

    environments                            = jsondecode(
                                                file("${path.module}/metadata/environments.json")
                                            )

    regions                                 = jsondecode(
                                                file("${path.module}/metadata/regions.json")
                                            )

    subnet_types                            = jsondecode(
                                                file("${path.module}/metadata/subnets.json")
                                            )
    
    ########################################################################################
    ### STEP 2: PARSE METADATA
    ########################################################################################
    client                                  = {
        key                                 = try(local.clients[upper(var.platform.client)].key, null)
        name                                = try(local.clients[upper(var.platform.client)].name, null)
    }

    environment                             = {
        key                                 = try(local.environments[upper(var.platform.environment)].key, null)
        name                                = try(local.environment[upper(var.platform.environment)].name, null)
    }

    region                                  = {
        key                                 = try(local.environments[upper(var.platform.region)].key, null)
        name                                = try(local.environment[upper(var.platform.region)].name, null)
    }

    subnet_type                             = {
        key                                 = try(local.subnet_types[upper(var.platform.subnet_type)].key, null)
        name                                = try(local.subnet_types[upper(var.platform.subnet_type)].name, null)
    }
    
    ########################################################################################
    ### STEP 3: GENERATE RESOURCE TAGS
    ########################################################################################
    tags                                    = merge({
        CreationDate                        = formatdate("YYYY-MM-DD", timestamp())  
        Terraform                           = true
    }, 
    local.client.key                        != null ? {
        Client                              = local.client.key 
    } : {},
    local.environment.key                   != null ? {
        Account                             = local.environment.key
    } : {},
    local.subnet_type.key                   != null ? {
        Subnet                              = local.subnet_type.key
    } : {},
    local.region.key                        != null ? {
        Region                              = local.aws.region.twoletterkey
    } : {})
    
    ########################################################################################
    ### STEP 4: VALIDATE PLATFORM QUERIES
    ########################################################################################
    ##      NOTE: Terraform errors out if a data query comes back empty. `conditions` is a map of 
    ##          booleans that determine which queries have enough information to return a result.
    conditions                              = {
        vpc_query_valid                     = var.hydration.vpc_query && alltrue([
                                                local.client.key                != null, 
                                                local.environment.key           != null,
                                            ])
        subnets_query_valid                 = var.hydration.subnets_query && alltrue([
                                                local.subnet_type.key           != null,
                                                length(var.platform.availability_zones) > 0,
                                            ])
        public_sq_query_valid               = var.hydration.public_sg_query
        private_sg_query_valid              = var.hydration.private_sg_query
        eks_ami_query_valid                 = var.hydration.eks_ami_query
        acm_cert_query_valid                = var.hydration.acm_cert_query && (
                                                var.configuration.domain_name != null
                                            )
    }

    ########################################################################################
    ## STEP 5: GENERATE PLATFORM QUERIES
    ########################################################################################
    ##      NOTE: `queries` is a map of dynamically generated resource names and prefixes
    ##          used to retrieve the networking and platform data from the AWS Cloud.
    queries                                 = {
        public_security_group               = {
            Client                          = [ local.client.key ]
            Enviroment                      = [ local.environment.key ]
            Group                           = "PUBLIC"
        }
        private_security_group              = {
            Client                          = [ local.client.key ]
            Enviroment                      = [ local.environment.key ]
            Group                           = "PRIVATE"
        }
        subnets                             = { 
            Client                          = [ local.client.key ]
            Enviroment                      = [ local.environment.key ]
            Subnet                          = [ local.subnet_type.key ]
            AZ                              = var.platform.availability_zones
        }
        vpc                                 = {
            Client                          = [ local.client.key ]
            Enviroment                      = [ local.environment.key ]
        }
        eks_ami                             = {
            "tag:Version"                   = [ var.configuration.eks_ami_version ]
            state                           = [ "available" ]
        }
        acm_cert                            = {
            statuses                        = [ "ISSUED" ]
        }
    }

    ########################################################################################
    ## STEP 6: GENERATE AWS ARNS
    ########################################################################################
    arn                     = {
        acm                 = {
            cert            = join(":", [
                                "arn",
                                "aws",
                                "acm",
                                data.aws_region.current.name,
                                data.aws_caller_identity.current.account_id,
                                "certificate"
                            ])
        }
        iam                 = {
            role            =  join(":", [
                                "arn",
                                "aws",
                                "iam:",
                                data.aws_caller_identity.current.account_id,
                                "role"
                            ])
            root            = join(":", [
                                "arn",
                                "aws",
                                "iam:",
                                data.aws_caller_identity.current.account_id,
                                "root"
                            ])
        }
        kms                 = {
            key             = join(":", [
                                "arn",
                                "aws",
                                "kms",
                                data.aws_region.current.name,
                                data.aws_caller_identity.current.account_id,
                                "key"
                            ])
            alias           = join(":", [
                                "arn",
                                "aws",
                                "kms",
                                data.aws_region.current.name,
                                data.aws_caller_identity.current.account_id,
                                "alias"
                            ])
        }
        s3                  = {
            bucket          = join(":", [
                                "arn",
                                "aws",
                                "s3",
                                "::",
                            ])
        }
    }
}