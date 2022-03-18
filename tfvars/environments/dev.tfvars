#Deployment variables defined

prefix            = "asd"
env               = "dev"

# what should be deploy
databricks       = true  # Azure DataBricks
eventhub         = true  # Azure EventHub

# Virtual Network details
location_name               = "centralus"
vnet_name                   = "databricks_vnet"
vnet_address_space          = "100.100.0.0/16"
vnet_private_subnet_name    = "private_subnet"
vnet_private_address_prefix = "100.100.0.0/24"
vnet_public_subnet_name     = "public_subnet"
vnet_public_address_prefix  = "100.100.1.0/24"
vnet_services_address_name  = "az_services"
vnet_services_address_prefix= "100.100.2.0/24"

# Databricks Workspace details
databricks_ws_name          = "databricks_workspace"
managed_rg_name             = "databricks_workspace_group"
#cluster details
cluster_name                = "cluster"
spark_version               = "8.4.x-scala2.12"
node_type_id                = "Standard_D8_v3"
driver_type                 = "Standard_D12_v2"


# Nat Gateway details
nat_gw_pip_name             = "nat_gw_pip"
az_pub_sku                  = "Standard"
az_pub_ip_ver               = "IPV4"
nat_gateway_name            = "nat_gateway"

# Event Hubs settings | uhgasd.com

az_event_hubns_name = "datastream"     # Event Hubns name
az_hubns_sku        = "Standard"            # Event Hubs SKU (Basic/Standard)
az_hubns_capacity   = "9"                   # Capacity (Throughput Units)
az_hub_inflate      = "false"               # Auto-inflate (applicable to Standard SKU)
az_hubns_maxunits   = "2"                   # Max number of units if inflate enabled
az_hub_partcount    = "2"                   # Event Hub Partition Count
az_hub_retention    = "2"                   # Event Hub Message Retention
az_hub_capture      = "false"               # Enable capture to Azure storage?

az_event_hub_name   = "testingconnection"


# Storage details
az_stor_acc_tier            = "Standard"                # Standard or Premium
az_stor_repl_type           = "RAGRS"                   # Storage Replication Type
az_stor_kind                = "StorageV2"               # Storage Kind
az_stor_tier                = "Hot"                     # Tier (Cold/Hot/Archive)
az_stor_secure              = true                      # Secured Storage or not? (HTTPS only)

# Data Storage Container
az_conta_acce_tier      = "private"
az_container_name       = "medical"

az_tags = {
  environment = "dev"
  name        = "asd"
  AppName     = "Databricks"
  Reason      = "SingleVnet"
}

#Azure private endpoint details
az_pr_endpnt_name                       = "hubnamespace"
az_pr_service_name                      = "asdeventhub"

az_pr_endp_stor_name                    = "privateendstorage"
az_pr_service_stor_name                 = "asdstorage"

# Azure private dns zone details

az_private_dns_name                     = "privatelink.blob.core.windows.net"
az_private_dns_record_name              = "asddataplatformdatalake"
az_private_dns_records                  = "100.100.2.4"
az_private_dns_ttl                      = 3600
az_private_dns_record_name1             = "asddeltalake"
az_private_dns_records1                 = "100.100.2.5"

az_private_dns_name1                     = "privatelink.servicebus.windows.net"
az_private_dns_record_name2              = "asddatastream"
az_private_dns_ttl1                      = 10
