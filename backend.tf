#-----------------------------------------------------------
# Provider Authentication 
#----------------------------------------------------------

terraform {
    required_providers {
        databricks = {
            source = "databrickslabs/databricks"
            version = "0.2.5"
        }
        azurerm = {
            source = "hashicorp/azurerm"
            version = "=2.46.0"
        }
    }
    backend "azurerm" { }
/*
    backend "azurerm" {
        resource_group_name         = "mdp_terraformstatefile"
        storage_account_name        = "storageterraformfile"
        container_name              = "prod"
        key                         = "terraform.tfstate"
    }
*/
}
