variable "resource_group_name" {
  description = "Name of the Resource Group to use."
  type        = string
}

variable "location" {
  description = "Region to deploy vm-series bootstrap resources. Ignored when using an `existing_storage_account`."
  default     = null
  type        = string
}

variable "create_storage_account" {
  description = "If true, create a Storage Account and ignore `existing_storage_account`."
  default     = true
  type        = bool
}

variable "create_storage_container" {
  description = "If true, create a Storage container and ignore `existing_storage_container`."
  default     = true
  type        = bool
}

variable "existing_storage_account" {
  description = "Name of the existing Storage Account object to use. Ignored when `create_storage_account` is true."
  default     = null
  type        = string
}

variable "tags" {
  description = "Azure tags to apply to the created Storage Account. A map, for example `{ team = \"NetAdmin\", costcenter = \"CIO42\" }`"
  default     = {}
  type        = map(string)
}

variable "storage_account_name" {
  description = "The name of the azure storage account"
    type        = string
}

variable "containers_name" {
  description = "The name of the azure storage account"
  type        = string
}

variable "containers_access_type" {
  default = "private"
}

variable "blob_name" {}

variable "account_kind" {
  description = "The type of storage account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2."
  default     = "StorageV2"
}

variable "access_tier" {
  description = "Defines the access tier for BlobStorage and StorageV2 accounts. Valid options are Hot and Cool."
  default  = "Hot"
}
variable "account_tier" {
  description = "Defines the access tier for BlobStorage and StorageV2 accounts. Valid options are Hot and Cool."
  default     = "Standard"
}
variable "account_replication_type" {
  description = "Defines the access tier for BlobStorage and StorageV2 accounts. Valid options are Hot and Cool."
  default     = "GRS"
}

variable "min_tls_version" {
  description = "The minimum supported TLS version for the storage account"
  default     = "TLS1_2"
}

variable "blob_soft_delete_retention_days" {
  description = "Specifies the number of days that the blob should be retained, between `1` and `365` days. Defaults to `7`"
  default     = 7
}

variable "container_soft_delete_retention_days" {
  description = "Specifies the number of days that the blob should be retained, between `1` and `365` days. Defaults to `7`"
  default     = 7
}

variable "enable_versioning" {
  description = "Is versioning enabled? Default to `false`"
  default     = false
}

variable "last_access_time_enabled" {
  description = "Is the last access time based tracking enabled? Default to `false`"
  default     = false
}

variable "change_feed_enabled" {
  description = "Is the blob service properties for change feed events enabled?"
  default     = false
}

variable "osdisk" {
  type = string
}

variable "sastok" {
  type = string
}

variable "automation_account_name" {
  type = string
}

variable "copy_vhd_url" {
  type = string
}

variable "asset_container_name" {
  type = string
}

variable "file_to_copy" {
  type = string
}