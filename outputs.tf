output "metadata" {
  description           = "Platform metdata."
  value                 = {
    client              = local.client
    environment         = local.environment
    subnet_type         = local.subnet_type
    region              = local.region
  }
}

output "aws" {
  description           = "Platform AWS metadata"
  value                 = {
    caller_arn          = data.aws_caller_identity.current.arn
    region              = data.aws_region.current.name
    account_id          = data.aws_caller_identity.current.account_id
    arn                 = local.arn
  }
}

output "prefixes" {
  description             = "Platform resource name prefixes, grouped by module family (compute, security, identity, etc.)."
  value                   = lower(join("-", [local.client.key, local.environment.key]))
}

output "tags" {
  description             = "Platform resource tags, grouped by module family (compute, security, identity, etc.)"
  value                   = local.tags
}

output "network" {
  description             = "MDThink Platform network resources for the inputted variables."
  value                   = {
    vpc                   = try(data.aws_vpc.vpc[0], null)
    subnets               = try(data.aws_subnets.subnets[0], null)
    security_groups       = {
      dmem                = try(data.aws_security_group.dmem_security_group[0], null)
      rhel                = try(data.aws_security_group.rhel_security_group[0], null)
    }
  }
}

output "certificate" {
  description             = "Platform Certificate resource"
  value                   = try(data.aws_acm_certificate.acm_certificate[0], null)
}

output "ami" {
  description             = "Platform AMI resources for the inputted variables"
  value                   = {
    eks                   = try(data.aws_ami.eks_ami[0], null)
  }
} 