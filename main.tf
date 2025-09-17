terraform {
  required_version = ">= 1.0.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.11.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = "5.2.1"
    }
  }
}

provider "aws" {
  # Configuration options
  region  = var.aws_region
  profile = "project1-sso"
}

provider "vault" {
  # Configuration options
}


data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"] # Propriétaire de l'AMI

  filter {
    name = "name"
    # Modèle de nom pour Amazon Linux 2023 AMI (standard x86_64)
    values = ["al2023-ami-*-kernel-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


ephemeral "vault_kv_secret_v2" "app_db_credentials" {
  mount = "secret"
  name  = "projet1/app/database"
}

resource "null_resource" "ephemeral_secret" {
  provisioner "local-exec" {
    command = "echo ${ ephemeral.vault_kv_secret_v2.app_db_credentials.data["password"] }"
  }
  
}

# Appel de notre module local 'instance_web'
module "serveur_web_1" {
  source = "./modules/instance_web" # Chemin vers notre module
  ami_id          = data.aws_ami.amazon_linux_2023.id
  instance_type   = local.current_instance_config.instance_type # Utilise la variable définie dans le variables.tf racine
  project_name    = var.project_name
  environment_tag = terraform.workspace
  subnet_id       = module.vpc.public_subnets[0] # Utilise le premier sous-réseau public du module VPC
  vpc_id          = module.vpc.vpc_id            # Utilise l'ID du VPC créé par le module VPC
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  # Consultez le Terraform Registry pour la dernière version stable et compatible (ex: ~> 5.0)
  version = "~> 5.5.0" # IMPORTANT: Spécifiez et vérifiez la version !

  name = "${var.project_name}-VPC-${ terraform.workspace }"
  cidr = var.vpc_cidr_block # Utilise la variable définie dans variables.tf racine

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"] # Exemple pour 3 AZs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]                      # Exemple de CIDRs pour sous-réseaux privés
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]                # Exemple de CIDRs pour sous-réseaux publics

  enable_nat_gateway = terraform.workspace == "prod" ? true : false # Crée une NAT Gateway pour les sous-réseaux privés (peut engendrer des coûts)
  single_nat_gateway = true # Utilise une seule NAT Gateway pour toutes les AZs (réduit les coûts)

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.common_tags
}

