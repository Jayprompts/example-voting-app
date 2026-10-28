output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Kubernetes API server address"
  value       = aws_eks_cluster.this.endpoint
}

output "region" {
  description = "AWS region the cluster runs in"
  value       = var.region
}

output "configure_kubectl" {
  description = "Run this to point kubectl at the new cluster"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.this.name}"
}

output "github_actions_variables" {
  description = "Add these as repository variables in GitHub (Settings > Secrets and variables > Actions > Variables)"
  value = {
    DEPLOY_ENABLED   = "true"
    AWS_ROLE_ARN     = aws_iam_role.github_deploy.arn
    AWS_REGION       = var.region
    EKS_CLUSTER_NAME = aws_eks_cluster.this.name
  }
}
