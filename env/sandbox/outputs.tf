output "karpenter_sa_role_arn" {
  value = module.eks_cluster.karpenter_sa_role_arn
}

output "cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}

output "instance_profile_name" {
  value = module.eks_cluster.instance_profile_name
}