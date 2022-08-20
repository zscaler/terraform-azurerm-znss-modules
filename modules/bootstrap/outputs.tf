output "storage_access_key" {
  value = azurerm_storage_account.this.primary_access_key
}

output "webhookurlcontainerfile" {
  value = azurerm_automation_webhook.containerwebhook.uri
}