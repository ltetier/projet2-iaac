variable "aws_region" {
  description = "La région AWS où les ressources seront déployées."
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Nom du projet, utilisé pour le taggage des ressources."
  type        = string
  default     = "Projet1-IaaC"
}

variable "vpc_cidr_block" {
  description = "Le bloc CIDR pour le VPC principal."
  type        = string
  default     = "10.0.0.0/16"
}

variable "TFC_AWS_PROVIDER_AUTH" {
  description = "Activer connexion avec openID"
  type        = bool
}

variable "TFC_AWS_RUN_ROLE_ARN" {
  description = "role pour openID pour HCP terraform"
  type        = string
}
