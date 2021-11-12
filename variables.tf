variable "prefix" {
  type = string
}
variable "env" {
  type = string
}

variable "az_tags" {
  type        = map
  description = "The default tags for resources and resources groups"
}

variable "location_name" {
  type = string
}
variable "vnet_name" {
  type = string
}
variable "vnet_address_space" {
  type = string
}
variable "vnet_private_subnet_name" {
  type = string
}
variable "vnet_private_address_prefix" {
  type = string
}
variable "vnet_public_subnet_name" {
  type = string
}
variable "vnet_public_address_prefix" {
  type = string
}

variable "vnet_services_address_name" {
  type = string
  description = "az services name"
}
variable "vnet_services_address_prefix" {
  type = string
  description = "az services address prefixes"
}

#Databricks workspace variables defined
variable "databricks_ws_name" {
  type = string
  description = "databricks workspace name "
}
variable "managed_rg_name" {
  type = string
  description = "databricks managed resource group name"
}

#cluster variables defined
variable "cluster_name" {
  type = string
  description = "cluster name "
}
variable "spark_version" {
  type = string
  description = "spark version details"
}
variable "node_type_id" {
  type = string
  description = "node type details"
}

variable "driver_type" {
  type        = string
  description = "Driver type"
}
# Nat gateway variables details
variable "nat_gw_pip_name" {
  type = string
  description = "nat gateway public ip address name"
}

variable "nat_gateway_name" {
  type = string
  description = "nat gateway name"
}

variable "az_pub_sku" {
  type        = string
  description = "public ip sku type standard/Basic"
}
variable "az_pub_ip_ver" {
  type        = string
  description = "public ip address ipv4 version"
}

variable "az_pr_endpnt_name" {
  type        = string
}

variable "az_pr_service_name" {
  type        = string
}

variable "az_pr_endp_stor_name" {
  type        = string
}

variable "az_pr_service_stor_name" {
  type        = string
}


variable "databricks" {
  type        = string
  description = "deploy databricks or not?"
}

variable "eventhub" {
  type        = string
  description = "deploy eventhub or not?"
}

variable "az_stor_acc_tier" {
  type        = string
  description = "Azure Storage Account Tier (Std/Premium)"
}

variable "az_stor_repl_type" {
  type        = string
  description = "Azure Storage Replication Type (GRS/LRS/RA-GRS)"
}

variable "az_stor_kind" {
  type        = string
  description = "Azure Storage Account Kind (V1/V2/Blob)"
}

variable "az_stor_tier" {
  type        = string
  description = "Azure Storage Access Tier (Hot/Cool)"
}

variable "az_stor_secure" {
  type        = string
  description = "Is Azure Secure Transfer Required?"
}

#Storage Container Access Tier
variable "az_conta_acce_tier" {
  type        = string
  description = "Azure Storage Container Access Tier"
}

variable "az_container_name" {
  type        = string
  description = "azure storage account container name"
}
#Azure Event Hubs Namespace

variable "az_event_hubns_name" {
  type = string
  description = "The Azure Event Hubns name"
}

variable "az_hubns_sku" {
  type        = string
  description = "The Azure Event Hubs Sku (Basic/Standard)"
}

variable "az_hubns_maxunits" {
  type        = string
  description = "If  auto_inflate_enabled is set to True, defines maximum throughput units"
}

variable "az_hub_inflate" {
  type        = string
  description = "Should we enable auto_inflate on Event Hubs namespace? (true/false)"
}

variable "az_hubns_capacity" {
  type        = string
  description = "The Azure Event Hubs capacity (throughput units). Only applicable if SKU is Standard"
}

variable "az_hub_partcount" {
  type        = string
  description = "Azure Event Partition Count (1-32)"
}

variable "az_hub_retention" {
  type        = string
  description = "Azure Event Hub Message Retention (days)"
}

variable "az_hub_capture" {
  type        = string
  description = "Should we enable capturing to Azure Storage?"
}

variable "az_event_hub_name" {
  type        = string
  description = "should we give event hub name"
}

#Azure Private DNS Zone variables

variable "az_private_dns_name" {
  type        = string
  description = "Azure private dns zone name"
}

variable "az_private_dns_record_name" {
  type        = string
  description = "Azure private dns zone record name"
}

variable "az_private_dns_records" {
  type        = string
  description = "Azure private dns zone records"
}

variable "az_private_dns_ttl" {
  type        = string
  description = "Azure private dns zone ttl values"
}

variable "az_private_dns_record_name1" {
  type        = string
  description = "Azure private dns zone record name"
}

variable "az_private_dns_records1" {
  type        = string
  description = "Azure private dns zone records"
}

variable "az_private_dns_name1" {
  type        = string
  description = "Azure private dns zone name"
}

variable "az_private_dns_record_name2" {
  type        = string
  description = "Azure private dns zone record name"
}

variable "az_private_dns_ttl1" {
  type        = string
  description = "Azure private dns zone ttl values"
}

variable "kv-storage-permissions-full" {
  type        = list(string)
  description = "List of full storage permissions, must be one or more from the following: backup, delete, deletesas, get, getsas, list, listsas, purge, recover, regeneratekey, restore, set, setsas and update"
  default     = [ "backup", "delete", "deletesas", "get", "getsas", "list", "listsas",
    "purge", "recover", "regeneratekey", "restore", "set", "setsas", "update" ]
}

variable "kv-key-permissions-full" {
  type        = list(string)
  description = "List of full key permissions, must be one or more from the following: backup, create, decrypt, delete, encrypt, get, import, list, purge, recover, restore, sign, unwrapKey, update, verify and wrapKey"
  default     = [ "backup", "create", "decrypt", "delete", "encrypt", "get", "import", "list", "purge",
    "recover", "restore", "sign", "unwrapKey","update", "verify", "wrapKey" ]
}

variable "kv-secret-permissions-full" {
  type        = list(string)
  description = "List of full secret permissions, must be one or more from the following: backup, delete, get, list, purge, recover, restore and set"
  default     = [ "backup", "delete", "get", "list", "purge", "recover", "restore", "set" ]
}

variable "kv-certificate-permissions-full" {
  type        = list(string)
  description = "List of full certificate permissions, must be one or more from the following: backup, create, delete, deleteissuers, get, getissuers, import, list, listissuers, managecontacts, manageissuers, purge, recover, restore, setissuers and update"
  default     = [ "create", "delete", "deleteissuers", "get", "getissuers", "import", "list", "listissuers",
    "managecontacts", "manageissuers", "purge", "recover", "setissuers", "update", "backup", "restore" ]
}

variable "kv_ad_user_principal_names" {
  type        = list(string)
  description = "List of users to add into principal names"
  default     = ["gvenka29@optumcloud.com","pannepu2@optumcloud.com"]
}
