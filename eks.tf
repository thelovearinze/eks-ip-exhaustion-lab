# 1. The EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "eks-custom-network-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private_constrained_a.id,
      aws_subnet.private_constrained_b.id
    ]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# 2. The Constrained Node Group
resource "aws_eks_node_group" "constrained_nodes" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "constrained-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  # Forcing the nodes into our tiny /28 subnets
  subnet_ids = [
    aws_subnet.private_constrained_a.id,
    aws_subnet.private_constrained_b.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.micro"] # Changed to Free Tier eligible

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only
  ]
}