output "oidc_provider_arn" {
    value = module.k8s-cluster.oidc_provider_arn
}

output "cluster_oidc_issuer_url" {
  value = module.k8s-cluster.cluster_oidc_issuer_url
}

output "cluster_id" {
  value = module.k8s-cluster.cluster_id
}