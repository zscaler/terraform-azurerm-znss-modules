#---------------------------------------------------------
# Storage Account creation
#----------------------------------------------------------
resource "azurerm_storage_account" "this" {
  count                     = var.create_storage_account ? 1 : 0
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

# -------------------------------------------------
# Data Storage Account
# -------------------------------------------------
data "azurerm_storage_account" "this" {
  count               = var.create_storage_account == false ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

#-----------------------------------------
# Storage Container Creation for VHD Copy
#-----------------------------------------
resource "azurerm_storage_container" "this" {
  name                  = var.containers_name
  storage_account_name  = var.storage_account_name
  container_access_type = var.containers_access_type
  depends_on = [
    azurerm_storage_account.this
  ]
}

#-------------------------------------------------
# Storage Container Creation for storing ZIP file
#-------------------------------------------------
resource "azurerm_storage_container" "blobcontainer" {
  name                  = var.asset_container_name
  storage_account_name  = var.storage_account_name
  container_access_type = "blob"
  depends_on = [
    azurerm_storage_account.this
  ]
}

#-------------------------------------------------
# Uplaod the file from Asssets folder to container
#-------------------------------------------------
resource "azurerm_storage_blob" "example" {
  name                   = var.file_to_copy
  storage_account_name   = var.storage_account_name
  storage_container_name = azurerm_storage_container.blobcontainer.name
  type                   = "Block"
  source                 = "./../../assets/${var.file_to_copy}"
  depends_on = [
    azurerm_storage_container.blobcontainer
  ]
}

resource "azurerm_storage_blob" "scriptblob" {
  name                   = "nscript.sh"
  storage_account_name   = var.storage_account_name
  storage_container_name = azurerm_storage_container.blobcontainer.name
  type                   = "Block"
  source                 = "./../../scripts/nscript.sh"
  depends_on = [
    azurerm_storage_blob.example
  ]
}

resource "azurerm_storage_blob" "scriptblob2" {
  name                   = "executescript.sh"
  storage_account_name   = var.storage_account_name
  storage_container_name = azurerm_storage_container.blobcontainer.name
  type                   = "Block"
  source                 = "./../../scripts/executescript.sh"
  depends_on = [
    azurerm_storage_blob.scriptblob
  ]
}

#----------------------------------
# Azure Automation Account Creation
#----------------------------------
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

#-------------------------------------
# Azure Automation Account Credential
#-------------------------------------
resource "azurerm_automation_credential" "this" {
  name                    = "automationCredential"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  username                = "unusedUsername"
  password                = var.create_storage_account == true ? azurerm_storage_account.this[0].primary_access_key : data.azurerm_storage_account.this[0].primary_access_key
  description             = "This is an example credential"
  depends_on = [
    azurerm_automation_account.this
  ]
}

#-----------------------------------------
# Azure Automation Account Runbook for VHD
#-----------------------------------------
resource "azurerm_automation_runbook" "this" {
  name                    = "copyvhd"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  log_verbose             = "false"
  log_progress            = "false"
  description             = "This is runbook for copying the vhd file to the storage container"
  runbook_type            = "PowerShellWorkflow"

  publish_content_link {
    uri = var.copy_vhd_url
  }
  depends_on = [
    azurerm_automation_account.this,
    azurerm_automation_credential.this
  ]
}

#-----------------------------------------
# Get content of PowerShell File
#-----------------------------------------
data "local_file" "script_ps1" {
  filename = "../../ssh/script.ps1"
}

#---------------------------------------------------------------
# Azure Automation Account Runbook for deleting Assets Container
#---------------------------------------------------------------
resource "azurerm_automation_runbook" "delete_container" {
  name                    = "deletecontainer"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  log_verbose             = "false"
  log_progress            = "false"
  description             = "This Runbook is for deleting the zip file container"
  runbook_type            = "PowerShellWorkflow"
  content                 = data.local_file.script_ps1.content
  depends_on = [
    azurerm_automation_account.this,
    azurerm_automation_credential.this
  ]
}

#-----------------------------------------
# Azure Automation Account Webhook for VHD
#-----------------------------------------
resource "azurerm_automation_webhook" "this" {
  name                    = "webhook"
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  expiry_time             = "2022-12-31T00:00:00Z"
  enabled                 = true
  runbook_name            = azurerm_automation_runbook.this.name
  parameters = {
    newstorageaccountname          = var.storage_account_name
    newstorageaccountcontainername = var.containers_name
    destvhdname                    = var.blob_name
    vhdurl                         = var.osdisk
    sastoken                       = var.sastok
  }
  depends_on = [
    azurerm_automation_account.this,
    azurerm_automation_runbook.this
  ]
}


#--------------------------------------------------------
# Azure Automation Account Webhook for Container deletion
#--------------------------------------------------------
resource "azurerm_automation_webhook" "containerwebhook" {
  name                    = "webhookcontainer"
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  expiry_time             = "2022-12-31T00:00:00Z"
  enabled                 = true
  runbook_name            = azurerm_automation_runbook.delete_container.name
  parameters = {
    newstorageaccountname          = var.storage_account_name
    newstorageaccountcontainername = var.asset_container_name
  }
  depends_on = [
    azurerm_automation_account.this,
    azurerm_automation_runbook.delete_container
  ]
}

#-------------------------------
# Invoke VHD WebHook through API
#-------------------------------
resource "null_resource" "this" {
  provisioner "local-exec" {
    command     = "Invoke-WebRequest -Method Post -Uri ${azurerm_automation_webhook.this.uri}"
    interpreter = ["pwsh", "-Command"]
  }
  depends_on = [
    azurerm_automation_account.this,
    azurerm_automation_webhook.this
  ]
}

#--------------------------------------------
# Delay in deployment before provisioining VM
#--------------------------------------------
resource "null_resource" "before" {
}
resource "null_resource" "delay" {
  provisioner "local-exec" {
    command     = "start-sleep 1800"
    interpreter = ["pwsh", "-Command"]
  }
  triggers = {
    "before" = "${null_resource.before.id}"
  }
  depends_on = [
    azurerm_automation_account.this,
    null_resource.before,
    null_resource.this
  ]
}
