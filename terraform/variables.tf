variable "region" {
  description = "AWS region to create the cluster in"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster (also used to name its IAM roles and node group)"
  type        = string
  default     = "voting-app"
}

variable "kubernetes_version" {
  description = "Kubernetes minor version; must be on EKS standard support to avoid extended-support charges"
  type        = string
  default     = "1.36"
}

variable "node_instance_types" {
  description = "EC2 instance types for the worker nodes"
  type        = list(string)
  # t3.large (2 vCPU, 8 GiB) leaves room for Capstone 2's Robot Shop and monitoring stack
  default = ["t3.large"]
}

variable "node_desired_size" {
  description = "Number of worker nodes to run"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}
