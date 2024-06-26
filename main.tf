data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.function_name}_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create a custom policy for reading Parameter Store parameters
resource "aws_iam_policy" "ssm_parameter_read_policy" {
  name        = "${var.function_name}_ssm_read_policy"
  description = "Policy to allow Lambda function to read SSM Parameter Store parameters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParameterHistory",
          "ssm:GetParametersByPath"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment_name}/${var.function_name}/*"
      }
    ]
  })
}

# Attach the custom policy to the Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_ssm_read_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.ssm_parameter_read_policy.arn
}

# Create a custom policy for loading ECR images
resource "aws_iam_policy" "ecr_read_policy" {
  name        = "${var.function_name}_ecr_read_policy"
  description = "Policy to allow Lambda function to read ECR images"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:GetDownloadUrlForLayer",
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Attach the custom policy to the Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_ecr_read_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.ecr_read_policy.arn
}

resource "aws_lambda_function" "lambda_function" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_exec_role.arn
  package_type  = "Image"
  image_uri     = var.image_uri
  timeout       = var.timeout
  memory_size   = var.memory_size

  environment {
    variables = {
      ENVIRONMENT = var.environment_name,
      NAME        = var.function_name
    }
  }

  tags = var.tags
}

# Create secure string parameters for environment variables
resource "aws_ssm_parameter" "env_vars" {
  for_each = var.environment_variables

  name  = "/${var.environment_name}/${var.function_name}/${each.key}"
  type  = "SecureString"
  value = each.value

  lifecycle {
    ignore_changes = [value]
  }
}
