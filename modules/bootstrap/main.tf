#---------------------------------------------------------
# Storage Account creation
#----------------------------------------------------------
resource "azurerm_storage_account" "this" {
  name                      = var.storage_account_name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_kind              = var.account_kind
  account_tier              = var.account_tier
  account_replication_type  = var.account_replication_type
  access_tier               = var.access_tier
  enable_https_traffic_only = true
  min_tls_version           = var.min_tls_version
  tags                      = var.tags

  blob_properties {
    delete_retention_policy {
      days = var.blob_soft_delete_retention_days
    }
    container_delete_retention_policy {
      days = var.container_soft_delete_retention_days
    }
    versioning_enabled       = var.enable_versioning
    last_access_time_enabled = var.last_access_time_enabled
    change_feed_enabled      = var.change_feed_enabled
  }
}

#-------------------------------
# Storage Container Creation
#-------------------------------
resource "azurerm_storage_container" "this" {
  name                  = var.containers_name
  storage_account_name  = var.storage_account_name
  container_access_type = var.containers_access_type
   depends_on = [
    azurerm_storage_account.this
  ]
}

#-------------------------------
# Azure Automation Account Creation
#-------------------------------
resource "azurerm_automation_account" "this" {
  name                = var.automation_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Basic"
  depends_on = [
    azurerm_storage_account.this,
    azurerm_storage_container.this
  ]
}

#-------------------------------
# Azure Automation Account Credential
#-------------------------------
resource "azurerm_automation_credential" "this" {
  name                    = "automationCredential"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  username                = "unusedUsername"
  password                = azurerm_storage_account.this.primary_access_key
  description             = "This is an example credential"
  depends_on = [
    azurerm_automation_account.this
  ]
}

#-------------------------------
# Azure Automation Account Runbook
#-------------------------------
resource "azurerm_automation_runbook" "this" {
  name                    = "copyvhd"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  log_verbose             = "false"
  log_progress            = "false"
  description             = "This is runbook"
  runbook_type            = "PowerShellWorkflow"

  publish_content_link {
    uri = var.copy_vhd_url
  }
  depends_on = [
    azurerm_automation_credential.this
  ]
}

#-------------------------------
# Azure Automation Account Webhook
#-------------------------------
resource "azurerm_automation_webhook" "this" {
  name                    = "webhook"
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  expiry_time             = "2022-12-31T00:00:00Z"
  enabled                 = true
  runbook_name            = azurerm_automation_runbook.this.name
  parameters = {
    newstorageaccountname = var.storage_account_name
    newstorageaccountcontainername = var.containers_name
    destvhdname = var.blob_name
    vhdurl = var.osdisk
    sastoken = var.sastok
  }
  depends_on = [
    azurerm_automation_runbook.this
  ]
}

#-------------------------------
# Invoke WebHook through API
#-------------------------------
resource "null_resource" "this" {
    provisioner "local-exec" {
        command = "Invoke-WebRequest -Method Post -Uri ${azurerm_automation_webhook.this.uri}"
        interpreter = ["pwsh", "-Command"]
    }
    depends_on = [
    azurerm_automation_webhook.this
  ]
}
