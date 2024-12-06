data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "vpc" {
    count           = local.conditions.vpc_query_valid ? 1 : 0

    dynamic "filter" {
        for_each    = local.queries.vpc

        content {
            name    = "tag:${filter.key}"
            values  = filter.value
        }
    }
} 

data "aws_subnets" "subnets" {
    count           = local.conditions.subnets_query_valid ? 1 : 0
    
    dynamic "filter" {
        for_each    = local.queries.subnets

        content {
            name    = "tag:${filter.key}"
            values  = filter.value
        }
    }
}

data "aws_security_group" "private_security_group" {
    count           = local.conditions.private_sg_query_valid ? 1 : 0

    dynamic "filter" {
        for_each    = local.queries.private_security_group

        content {
            name    = "tag:${filter.key}"
            values  = filter.value
        }
    }
}

data "aws_security_group" "public_security_group" {
    count           = local.conditions.public_sg_query_valid ? 1 : 0

    dynamic "filter" {
        for_each    = local.queries.public_security_group

        content {
            name    = "tag:${filter.key}"
            values  = filter.value
        }
    }
}

data "aws_ami" "eks_ami" {
    count           = local.conditions.eks_ami_query_valid ? 1 : 0
    
    most_recent     = true

    dynamic "filter" {
        for_each    = local.queries.eks_ami

        content {
            name    = filter.key
            values  = filter.value
        }
    }
}

data "aws_acm_certificate" "acm_certificate" {
    count           = local.conditions.acm_cert_query_valid ? 1 : 0

    most_recent     = true

    domain          = var.configuration.domain_name
    statuses        = local.queries.acm_cert.statuses
}