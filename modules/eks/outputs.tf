output "karpenter_sa_role_arn" {
  value = module.karpenter_irsa.iam_role_arn
}

output "cluster_endpoint" {
  value = module.main.cluster_endpoint
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.karpenter.name
}