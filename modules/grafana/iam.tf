resource "aws_iam_instance_profile" "grafana" {
  name = "${lower(var.env_name)}-grafana"
  role = "${aws_iam_role.grafana_role.name}"
}

resource "aws_iam_role" "grafana_role" {
  name = "${lower(var.env_name)}-grafana"
  assume_role_policy = "${data.aws_iam_policy_document.ec2_assume_policy.json}"
}

resource "aws_iam_role" "grafana_task_role" {
  name = "${lower(var.env_name)}-grafana-task"
  assume_role_policy = "${data.aws_iam_policy_document.task_assume_policy.json}"
}

resource "aws_iam_role_policy" "docker_policy" {
  name = "${lower(var.env_name)}-docker-policy"
  role = "${aws_iam_role.grafana_role.id}"
  policy = "${data.aws_iam_policy_document.docker_policy.json}"
}

data "aws_iam_policy_document" "ec2_assume_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "task_assume_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "docker_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:Submit*",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:Describe*",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "extra_iam_roles" {
  count = "${length(var.extra_iam_roles)}"
  policy_arn = "${var.extra_iam_roles[count.index]}"
  role = "${aws_iam_role.grafana_role.id}"
}

resource "aws_iam_role_policy_attachment" "extra_task_iam_roles" {
  count = "${length(var.extra_task_iam_roles)}"
  policy_arn = "${var.extra_task_iam_roles[count.index]}"
  role = "${aws_iam_role.grafana_task_role.id}"
}