resource "aws_iam_role" "fargate-pod-executionrole-actionsdemo" {
  name = "fargate-execution-role-actionsdemo"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSFargatePodExecutionRolePolicyActionsDemo" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate-pod-executionrole-actionsdemo.name
}

resource "aws_iam_role" "eks-cluster-role-actionsdemo" {
    name = "aws_eks_iam_role"

    assume_role_policy =  <<POLICY
{
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
            }
        }
    ],
    "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicyActionsDemo" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role-actionsdemo.name
}