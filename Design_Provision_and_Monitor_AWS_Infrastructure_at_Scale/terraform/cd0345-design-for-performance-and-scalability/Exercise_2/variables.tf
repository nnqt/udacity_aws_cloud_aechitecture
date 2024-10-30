# TODO: Define the variable for aws_region
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "lambda_function_name" {
  type    = string
  default = "greet_lambda"
}

variable "runtime" {
  type    = string
  default = "python3.9"
}

variable "output_file_name" {
  type    = string
  default = "greet_lambda.zip"
}

variable "lambda_handler" {
  type    = string
  default = "greet_lambda.lambda_handler"
}