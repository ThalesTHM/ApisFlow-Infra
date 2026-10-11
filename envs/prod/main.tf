module "network" {
  source = "../../modules/network"

  project     = var.project
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  enable_nat  = var.enabled
  single_nat  = var.single_nat
}

module "ecr" {
  source = "../../modules/ecr"

  project      = var.project
  environment  = var.environment
  repositories = ["backend", "frontend"]
}
