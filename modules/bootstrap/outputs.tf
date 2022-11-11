output "storage_access_key" {
  value = var.create_storage_account == true ? azurerm_storage_account.this[0].primary_access_key : data.azurerm_storage_account.this[0].primary_access_key
}

output "webhookurlcontainerfile" {
  value = azurerm_automation_webhook.containerwebhook.uri
}
