# Configure the all the resouces
provider "azurerm" {
    features {}
  }

resource "azurerm_resource_group" "az_rg" {
  name                    = "${var.prefix}-${var.env}-rg-Ujwala"
  location                = var.location_name
  tags                        = var.az_tags
}

#Configure the Virtual network and NSG and subnets
# Single Vnet
resource "azurerm_virtual_network" "vnet_databricks" {
  address_space         = [var.vnet_address_space]
  location              = azurerm_resource_group.az_rg.location
  name                  = "${var.vnet_name}_${var.env}"
  resource_group_name = azurerm_resource_group.az_rg.name

  tags                        = var.az_tags
}
#Single NSG
resource "azurerm_network_security_group" "az_nsg_services" {
  location              = azurerm_resource_group.az_rg.location
  name                  = "azure_service-${var.env}"
  resource_group_name   = azurerm_resource_group.az_rg.name

  tags                        = var.az_tags
}
resource "azurerm_network_security_group" "nsg_public" {
  location              = azurerm_resource_group.az_rg.location
  name                  = "public_nsg_${var.env}"
  resource_group_name   = azurerm_resource_group.az_rg.name
  tags                        = var.az_tags
}
resource "azurerm_network_security_group" "nsg_privat" {
  location              = azurerm_resource_group.az_rg.location
  name                  = "private_nsg_${var.env}"
  resource_group_name   = azurerm_resource_group.az_rg.name
  tags                        = var.az_tags
}

#Configure the private subnet and delegation with databrcks workspace
resource "azurerm_subnet" "subnet_private" {
  name                  = "${var.vnet_private_subnet_name}_${var.env}"
  resource_group_name   = azurerm_resource_group.az_rg.name
  virtual_network_name  = azurerm_virtual_network.vnet_databricks.name
  address_prefixes      = [var.vnet_private_address_prefix]
  delegation {
    name      = "databricks"
    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/networkinterfaces/*",
        "Microsoft.Network/virtualNetworks/subnets/action",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }
}
# Here private subnet associate with NSG
resource "azurerm_subnet_network_security_group_association" "ass_private" {
  network_security_group_id = azurerm_network_security_group.nsg_privat.id
  subnet_id                 = azurerm_subnet.subnet_private.id
}
#Configure the public subnet and delegation with databrcks workspace
resource "azurerm_subnet" "subnet_public" {
  name                    = "${var.vnet_public_subnet_name}_${var.env}"
  resource_group_name     = azurerm_resource_group.az_rg.name
  virtual_network_name    = azurerm_virtual_network.vnet_databricks.name
  address_prefixes        = [var.vnet_public_address_prefix]
  delegation {
    name      = "databricks"
    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/networkinterfaces/*",
        "Microsoft.Network/virtualNetworks/subnets/action",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }
}

#Here public subnet associated with NSG
resource "azurerm_subnet_network_security_group_association" "ass_public" {
  network_security_group_id = azurerm_network_security_group.nsg_public.id
  subnet_id                 = azurerm_subnet.subnet_public.id
}
# Configure the Azure services Subnet for Private end points for storage and event hub services
resource "azurerm_subnet" "az_services" {
  name                      = "${var.vnet_services_address_name}_${var.env}"
  resource_group_name       = azurerm_resource_group.az_rg.name
  virtual_network_name      = azurerm_virtual_network.vnet_databricks.name
  address_prefixes          = [var.vnet_services_address_prefix]
  enforce_private_link_endpoint_network_policies = true

}
# Here Azure services associated with NSG
resource "azurerm_subnet_network_security_group_association" "az_services_sub" {
  network_security_group_id = azurerm_network_security_group.az_nsg_services.id
  subnet_id                 = azurerm_subnet.az_services.id
}

# Configure the Databricks workspace
resource "azurerm_databricks_workspace" "databrick_workspace" {
  location                    = azurerm_resource_group.az_rg.location
  name                        = "${var.databricks_ws_name}_${var.env}"
  resource_group_name         = azurerm_resource_group.az_rg.name
  sku                         = "premium"
  managed_resource_group_name = "${var.prefix}_${var.managed_rg_name}_${var.env}"
  //depends_on = [azurerm_resource_group.az_rg]
  custom_parameters {
    public_subnet_name        = azurerm_subnet.subnet_public.name
    no_public_ip              = true
    virtual_network_id        = azurerm_virtual_network.vnet_databricks.id
    private_subnet_name       = azurerm_subnet.subnet_private.name
  }

  tags                        = var.az_tags
}

provider "databricks" {
  azure_workspace_name        = azurerm_databricks_workspace.databrick_workspace.name
  azure_workspace_resource_id = azurerm_databricks_workspace.databrick_workspace.id
  /*  azure_client_id             = var.client_id
  azure_client_secret         = var.client_secret
  azure_tenant_id             = var.tenant_id */
}
resource "databricks_cluster" "shared_autoscaling" {
  cluster_name            = "${var.prefix}_${var.env}_${var.cluster_name}"
  spark_version           = var.spark_version
  node_type_id            = var.node_type_id
  driver_node_type_id     = var.driver_type
  autotermination_minutes = 30

  autoscale {
    min_workers = 5
    max_workers = 16
  }

  library {
    maven {
      coordinates = "com.microsoft.azure:azure-eventhubs-spark_2.12:2.3.18"
    }
  }

  library {
    maven {
      coordinates = "org.apache.spark:spark-avro_2.12:3.1.1"
    }
  }

  library {
    pypi {
      package = "sparkaid"
      // repo can also be specified here
    }
  }

}
# Nat gateway public ip address
resource "azurerm_public_ip" "nat_publicip" {
  name                = "${var.nat_gw_pip_name}_${var.env}"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  allocation_method   = "Static"
  sku                 = var.az_pub_sku
  ip_version          = var.az_pub_ip_ver

  tags                        = var.az_tags
}
# Nat gateway configure
resource "azurerm_nat_gateway" "nat_gateway" {
  name                    = "${var.nat_gateway_name}_${var.env}"
  location                = azurerm_resource_group.az_rg.location
  resource_group_name     = azurerm_resource_group.az_rg.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10

  tags                        = var.az_tags
}
# Associate the public ip address into Nat gateway
resource "azurerm_nat_gateway_public_ip_association" "associ_nat_publicip" {
  nat_gateway_id          = azurerm_nat_gateway.nat_gateway.id
  public_ip_address_id    = azurerm_public_ip.nat_publicip.id
}
#Associate the public subnet into natgateway
resource "azurerm_subnet_nat_gateway_association" "nat_public_sub" {
  nat_gateway_id          = azurerm_nat_gateway.nat_gateway.id
  subnet_id               = azurerm_subnet.subnet_public.id
}
/*resource "azurerm_subnet_nat_gateway_association" "nat_services" {
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id
  subnet_id = azurerm_subnet.az_services.id
}

resource "azurerm_subnet_nat_gateway_association" "nat_private_sub" {
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id
  subnet_id = azurerm_subnet.subnet_private.id
} */

#Azure Event Hub Namespace
resource "azurerm_eventhub_namespace" "mdp_hubns" {
  name                        = "${var.az_event_hubns_name}${var.env}"
  resource_group_name         = azurerm_resource_group.az_rg.name
  location                    = azurerm_resource_group.az_rg.location
  sku                         = var.az_hubns_sku
  capacity                    = var.az_hubns_capacity
  auto_inflate_enabled        = (var.az_hubns_sku != "Basic" ? var.az_hub_inflate : "false")
  maximum_throughput_units    = (var.az_hub_inflate != "false" ? var.az_hubns_maxunits : "0")

  tags                        = var.az_tags
}

#Azure Event Hub
resource "azurerm_eventhub" "mdp_hub" {
  name                        = var.az_event_hub_name
  namespace_name              = azurerm_eventhub_namespace.mdp_hubns.name
  resource_group_name         = azurerm_resource_group.az_rg.name
  partition_count             = var.az_hub_partcount
  message_retention           = var.az_hub_retention
}

#------------------------------------------------------------------------------------
#
# Create Storage account for Data Lake store
#
#------------------------------------------------------------------------------------
resource "azurerm_storage_account" "az_stor" {
  name                        = "${var.prefix}ct${var.env}"
  resource_group_name         = azurerm_resource_group.az_rg.name
  location                    = azurerm_resource_group.az_rg.location
  account_tier                = var.az_stor_acc_tier
  account_replication_type    = var.az_stor_repl_type
  account_kind                = var.az_stor_kind
  access_tier                 = var.az_stor_tier
  enable_https_traffic_only   = var.az_stor_secure
  min_tls_version             = "TLS1_2"
  is_hns_enabled              = true

  tags                        = var.az_tags
}

resource "azurerm_storage_container" "az_stor" {
  name                        = var.az_container_name
  storage_account_name        = azurerm_storage_account.az_stor.name
  container_access_type       = var.az_conta_acce_tier
}
#-------------------------------------------------------------------------------------
#
#  Two Private end points configuration to Azure Services Vnet
#
#--------------------------------------------------------------------------------------

resource "azurerm_private_endpoint" "az_pr_enp_enhub" {
  name                        = "${var.az_pr_endpnt_name}_${var.env}"
  location                    = azurerm_resource_group.az_rg.location
  resource_group_name         = azurerm_resource_group.az_rg.name
  subnet_id                   = azurerm_subnet.az_services.id

  tags                        = var.az_tags

  private_service_connection {
    name                            = var.az_pr_service_name
    private_connection_resource_id  = azurerm_eventhub_namespace.mdp_hubns.id
    subresource_names               = [ "namespace" ]
    is_manual_connection            = false

  }
}

resource "azurerm_private_endpoint" "az_pr_enp_storage" {
  name                        = "${var.az_pr_endp_stor_name}_${var.env}"
  location                    = azurerm_resource_group.az_rg.location
  resource_group_name         = azurerm_resource_group.az_rg.name
  subnet_id                   = azurerm_subnet.az_services.id
  tags                        = var.az_tags
  private_service_connection {
    name                            = var.az_pr_service_stor_name
    private_connection_resource_id  = azurerm_storage_account.az_stor.id
    subresource_names               = [ "dfs" ]
    is_manual_connection            = false

  }
}

#--------------------------------------------------------------------------------------
#
# Private DNS Zone
#
#--------------------------------------------------------------------------------------

resource "azurerm_private_dns_zone" "az_private_dns" {
  name                    = "${var.az_private_dns_name}_${var.env}"
  resource_group_name     = azurerm_resource_group.az_rg.name

}

resource "azurerm_private_dns_a_record" "az_private_dns_record1" {
  name                    = var.az_private_dns_record_name
  zone_name               = azurerm_private_dns_zone.az_private_dns.name
  resource_group_name     = azurerm_resource_group.az_rg.name
  ttl                     = var.az_private_dns_ttl
  records                 = [ var.az_private_dns_records ]
}

resource "azurerm_private_dns_a_record" "az_private_dns_record2" {
  name                    = var.az_private_dns_record_name1
  zone_name               = azurerm_private_dns_zone.az_private_dns.name
  resource_group_name     = azurerm_resource_group.az_rg.name
  ttl                     = var.az_private_dns_ttl
  records                 = [ var.az_private_dns_records1 ]

}

resource "azurerm_private_dns_zone" "az_private_dns1" {
  name                    = var.az_private_dns_name1
  resource_group_name     = azurerm_resource_group.az_rg.name

}

resource "azurerm_private_dns_a_record" "az_private_dns1" {
  name                    = var.az_private_dns_record_name2
  zone_name               = azurerm_private_dns_zone.az_private_dns1.name
  resource_group_name     = azurerm_resource_group.az_rg.name
  ttl                     = var.az_private_dns_ttl1
  records                 = [ var.az_private_dns_records1 ]
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "azkeyvault" {
  location                  = azurerm_resource_group.az_rg.location
  name                      = "mdpkeyv${var.env}"
  resource_group_name       = azurerm_resource_group.az_rg.name
  sku_name                  = "standard"
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled  = true

  tags                        = var.az_tags
}

resource "azurerm_key_vault_access_policy" "default_policy" {
  key_vault_id          = azurerm_key_vault.azkeyvault.id
  object_id             = data.azurerm_client_config.current.object_id
  tenant_id             = data.azurerm_client_config.current.tenant_id

  lifecycle {
    create_before_destroy = true
  }
  key_permissions             = var.kv-key-permissions-full
  secret_permissions          = var.kv-secret-permissions-full
  certificate_permissions     = var.kv-certificate-permissions-full
  storage_permissions         = var.kv-storage-permissions-full
}

resource "azurerm_private_dns_zone" "kv_zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.az_rg.name
}

# Private Endpoint configuration

resource "azurerm_private_endpoint" "kv_pe" {
  name = "${var.prefix}_${var.env}_kv_pe"
  location = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  subnet_id = azurerm_subnet.az_services.id

  private_service_connection {
    name = "${var.env}_kv_psc_${var.env}"
    private_connection_resource_id = azurerm_key_vault.azkeyvault.id
    subresource_names = ["vault"]
    is_manual_connection = false
  }
  private_dns_zone_group {
    name = "private-dns-zone-group-kv"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv_zone.id]
  }
}
