module "main" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.21.0"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnet_ids      = var.subnet_ids
  vpc_id          = var.vpc_id

  enable_irsa = true

  eks_managed_node_groups = {
    example = {
      create_security_group                 = false
      attach_cluster_primary_security_group = true

      min_size       = var.node_min_count
      max_size       = var.node_max_count
      desired_size   = var.node_desired_count
      instance_types = ["t2.medium"]
      capacity_type  = "SPOT"

      iam_role_additional_policies = [
        "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
      ]

      labels = {
        workload-system = "true"
      }
    }
  }

  aws_auth_users = [
    for name in var.map_users :
    {
      groups   = ["system:masters"]
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${name}"
      username = name
    }
  ]

  tags = var.tags
}

module "karpenter_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "4.17.1"

  role_name                          = "karpenter-controller-${var.cluster_name}"
  attach_karpenter_controller_policy = true

  karpenter_controller_cluster_id = module.main.cluster_id
  karpenter_controller_node_iam_role_arns = [
    module.main.eks_managed_node_groups["example"].iam_role_arn
  ]

  oidc_providers = {
    eks_oidc = {
      provider_arn               = module.main.oidc_provider_arn
      namespace_service_accounts = ["karpenter:karpenter"]
    }
  }
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile-${var.cluster_name}"
  role = module.main.eks_managed_node_groups["example"].iam_role_name
}