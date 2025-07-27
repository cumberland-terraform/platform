output "metadata" {
  description             = "Platform metdata."
  value                   = {
    client                = local.client
    environment           = local.environment
    subnet_type           = local.subnet_type
    region                = local.region
  }
}

output "aws" {
  description             = "Platform AWS metadata"
  value                   = {
    caller_arn            = data.aws_caller_identity.current.arn
    region                = data.aws_region.current.id
    account_id            = data.aws_caller_identity.current.account_id
    arn                   = local.arn
  }
}

output "prefix" {
  description             = "Platform resource name prefix."
  value                   = lower(join("-", [local.client.key, local.environment.key]))
}

output "tags" {
  description             = "Platform resource tags, grouped by module family (compute, security, identity, etc.)"
  value                   = local.tags
}

output "network" {
  description             = "Platform network resources for the inputted variables."
  value                   = {
    vpc                   = try(data.aws_vpc.vpc[0], null)
    subnets               = try(data.aws_subnets.subnets[0], null)
    security_groups       = {
      public              = try(data.aws_security_group.public_security_group[0], null)
      private             = try(data.aws_security_group.private_security_group[0], null)
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