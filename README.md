# `acsf-aws-lambda-container` Terraform Module

## Purpose

Lambda function using containers hosted in ECR. Lambda is allowed to access SSM Parameter Store at a given prefix. Environment variables configured for the function include `ENVIRONMENT` and `NAME` come from `environment_name` and `function_name` respectively.

## Inputs

| Variable | Type | Example | Description |
| - | - | - | - |
| `environment_name` | `string` | `production` | (required) The environment where this lambda exists. |
| `function_name` | `string` | `my-function` | (required) The name of the Lambda function. |
| `image_uri` | `string` | `123456789012.dkr.ecr.us-west-2.amazonaws.com/my-container:latest` | (required) The URI of the container image in ECR. |
| `timeout` | `number` | `30` |(optional) The amount of time that Lambda allows a function to run before stopping it. Default 15 sec. |
| `memory_size` | `number` | `256` |(optional) The amount of memory to allocate to the function at runtime. Default 128 MB. |
| `environment_variables` | `map(string)` | `{setting="123"}` |(optional) Initial set of environment variables. These are created in SSM Parameter Store, and you adjust the values manually in the console. |
| `tags` | `map(string)` | `{application="my-app"}` |(optional) The name of the DNS zone to create. |

## Outputs

| Variable | Type | Example | Description |
| - | - | - | - |
| `lambda_function_arn` | `string` | `arn:aws:lambda:us-west-2:123456789012:function:my-function` | The ARN of the Lambda function. |

## Usage

Using the module:

```
module "lambda" {
  source           = "git::https://github.com/aaronchu/acsf-aws-lambda-container.git?ref=v0.1.0"

  function_name = "my-function"
  image_uri     = "123456789012.dkr.ecr.us-west-2.amazonaws.com/my-container:latest"
  timeout       = 60
  memory_size   = 256
  environment_variables = {
    DB_HOST     = "initial_fqdn"
    DB_NAME     = "mydata"
    DB_USER     = "initial_user"
    DB_PASSWORD = "initial"
    DB_PORT     = "5432"
  }
  environment_name = var.environment_name
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.7 |
| aws | ~> 5.0 |

## Providers

`aws` (see requirements)

## Notes

1. Intended for hobbyist use only.
2. Built with `terraform` version `1.5.x` and intent to move to [`opentofu`](https://opentofu.org/) eventually.
