# namespace
resource "kubernetes_namespace" "amazon-cloudwatch" {
  metadata {
    labels = {
      app = "amazon-cloudwatch"
    }

    name = "amazon-cloudwatch"
  }
}

# fargate
resource "aws_iam_role_policy_attachment" "AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_pod_execution_role.name
}

resource "aws_iam_role" "fargate_pod_execution_role" {
  name                  = "${var.name}-eks-fargate-pod-execution-role"
  force_detach_policies = true

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "eks.amazonaws.com",
          "eks-fargate-pods.amazonaws.com"
          ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_eks_fargate_profile" "main" {
  cluster_name           = aws_eks_cluster.eks_clu.name
  fargate_profile_name   = "fp-default"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn
  subnet_ids             = aws_subnet.private[*].id

  selector {
    namespace = "default"
  }

  timeouts {
    create = "30m"
    delete = "60m"
  }
}

# Nginx
resource "kubernetes_deployment" "web-server" {
  metadata {
    name = "web-server"
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "web-server"
      }
    }

    template {
      metadata {
        name = "web-server"
        labels = {
          app = "web-server"
        }
      }

      spec {
        container {
          name  = "web-server-container"
          image = var.web_image

          port {
            container_port = 80
          }

          resources {
            limits {
              cpu = "500m"
            }
            requests {
              cpu = "200m"
            }
          }
          }
        }
      }
    }
  depends_on = [aws_eks_fargate_profile.main]
}

resource "kubernetes_service" "web-server" {
  metadata {
    name = "web-server"
    labels = {
      app = "web-server"
    }
  }
  spec {
    selector = {
      app = "web-server"
    }
    type = "NodePort"
    port {
      port        = 80
      target_port = 80
    }
  }

  depends_on = [kubernetes_deployment.web-server]
}

# #Tomcat
resource "kubernetes_deployment" "was-server" {
  metadata {
    name = "was-server"
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "was-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "was-server"
        }
      }

      spec {
        container {
          image = var.was_image
          name  = "was-server-container"

          port {
            container_port = 8080
          }

          resources {
            limits {
              cpu = "500m"
            }
            requests {
              cpu = "200m"
            }
          }
        }
      }
    }
  }
  depends_on = [aws_eks_fargate_profile.main]
}

resource "kubernetes_service" "was-server" {
  metadata {
    name = "was-server"
    labels = {
      app = "was-server"
    }
  }
  spec {
    selector = {
      app = "was-server"
    }
    type = "ClusterIP"
    port {
      port        = 8080
      target_port = 8080
    }
  }

  depends_on = [kubernetes_deployment.was-server]
}

# HPA
resource "kubernetes_horizontal_pod_autoscaler" "web-hpa" {
  metadata {
    name      = "web-hpa"
    namespace = "default"
  }
  spec {
    max_replicas                      = 5
    min_replicas                      = 2
    target_cpu_utilization_percentage = 40

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "web-server"
    }
  }
}
resource "kubernetes_horizontal_pod_autoscaler" "was-hpa" {
  metadata {
    name      = "was-hpa"
    namespace = "default"
  }
  spec {
    max_replicas                      = 5
    min_replicas                      = 2
    target_cpu_utilization_percentage = 40

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "was-server"
    }
  }
}
