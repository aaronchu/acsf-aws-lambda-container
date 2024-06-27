variable "environment_name" {
  description = "The environment where this lambda exists"
  type        = string
}

variable "function_name" {
  description = "The name of the Lambda function."
  type        = string
}

variable "image_uri" {
  description = "The URI of the container image in ECR."
  type        = string
}

variable "timeout" {
  description = "The amount of time that Lambda allows a function to run before stopping it."
  type        = number
  default     = 15
}

variable "memory_size" {
  description = "The amount of memory available to the function at runtime."
  type        = number
  default     = 128
}

variable "environment_variables" {
  description = "Initial set of environment variables."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
