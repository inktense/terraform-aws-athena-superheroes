variable "aws_region" {
  description = "Region where main resources should be created."
  type        = string
  default     = "eu-west-2"
}

variable "project_prefix" {
  description = "Project prefix for naming resources."
  type        = string
  default     = "athena-superheroes"
}

variable "tags" {
  description = "A map containing all the mandatory tags for the resources."
  type        = map(string)

  default = {
    Initialised = "20220627"
  }
}

# TF has a bug that not lets you add just one Glue worker
variable "glue_number_of_workers" {
  description = "Number of workers for Glue jobs."
  type        = number
  default     = 2
}
