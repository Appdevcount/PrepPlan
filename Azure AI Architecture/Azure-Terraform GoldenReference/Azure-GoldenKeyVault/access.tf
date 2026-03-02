locals {
  #  assign_RBAC = var.enable_rbac_authorization && var.initial_access_assignments != null
  #  assign_AP   = !var.enable_rbac_authorization && var.initial_access_assignments != null

  rbac_to_kvap_map = {
    "none" = { key_permissions = [], secret_permissions = [], certificate_permissions = [] }
    "Key Vault Administrator" = {
      key_permissions         = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "Decrypt", "Encrypt", "UnwrapKey", "WrapKey", "Verify", "Sign", "Purge", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
      secret_permissions      = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
      certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "ManageContacts", "ManageIssuers", "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers", "Purge"]
    }
    "Key Vault Certificates Officer" = {
      key_permissions         = []
      secret_permissions      = []
      certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "Manage Contacts", "Manage Certificate Authorities", "List Certificate Authorities", "Set Certificate Authorities", "Delete Certificate Authorities", "Purge"]
    }
    "Key Vault Crypto Officer" = {
      key_permissions         = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "Rotate", "Decrypt", "Encrypt", "UnwrapKey", "WrapKey", "Verify", "Sign", "Purge", "Release", "GetRotationPolicy", "SetRotationPolicy"]
      certificate_permissions = []
      secret_permissions      = []
    }
    "Key Vault Crypto Service Encryption User" = {
      key_permissions         = ["Get", "List", "UnwrapKey", "WrapKey"]
      secret_permissions      = []
      certificate_permissions = []
    }
    "Key Vault Crypto User" = {
      key_permissions         = ["Get", "List", "Update", "Backup", "Encrypt", "Decrypt", "UnwrapKey", "WrapKey", "Verify", "Sign"]
      secret_permissions      = []
      certificate_permissions = []
    }
    "Key Vault Reader" = {
      key_permissions         = ["Get", "List"]
      certificate_permissions = ["Get", "List"]
      secret_permissions      = ["Get", "List"]
    }
    "Key Vault Secrets Officer" = {
      key_permissions         = []
      certificate_permissions = []
      secret_permissions      = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
    }
    "Key Vault Secrets User" = {
      key_permissions         = []
      certificate_permissions = []
      secret_permissions      = ["Get"]
    }
  }

  #Create map of Key Vault Access Policies to apply for selected RBAC role equivilancy
  mapped_access_policies = { for a in var.initial_access_assignments : a.principal_id => [for r in a.roles : local.rbac_to_kvap_map["${r}"]] }

  # Convert access assignments to a map of individual roles (vs list of roles)
  # 1) Convert RBAC assignments to a key/value mapping with assignments as a list
  # 2) Convert to a list of objects with single assignment per principal ID
  # 3) Convert to map so we can iterate through assignments
  RBAC_assignments = { for i, a in tolist(flatten([for user in keys({ for a in var.initial_access_assignments : a.principal_id => a.roles }) : [for policy in { for a in var.initial_access_assignments : a.principal_id => a.roles }[user] : { user = user, policy = policy }]])) : i => a }

  #Convert initial assignment to map
  initial_assignment_map = {
    for obj in var.initial_access_assignments : "${obj.principal_id}" => obj
  }

  #Add Principal Type to RBAC Assignments
  #Convert to map
  RBAC_assignments_with_principal_type = {for i,a in [
    for role in local.RBAC_assignments : merge(role, {principal_type = lookup(local.initial_assignment_map, role.user).principal_type})
  ] : i => a } 


}

#Configure initial access policies or roles
resource "azurerm_key_vault_access_policy" "initial" {
  for_each = var.enable_rbac_authorization ? {} : local.mapped_access_policies

  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.key == "self" ? data.azurerm_client_config.current.object_id : each.key

  key_permissions         = distinct(concat([for p in each.value : p["key_permissions"]]...))
  certificate_permissions = distinct(concat([for p in each.value : p["certificate_permissions"]]...))
  secret_permissions      = distinct(concat([for p in each.value : p["secret_permissions"]]...))
}

resource "azurerm_role_assignment" "initial" {
  for_each = var.enable_rbac_authorization ? local.RBAC_assignments_with_principal_type : {}

  scope                = azurerm_key_vault.kv.id
  principal_id         = each.value.user == "self" ? data.azurerm_client_config.current.object_id : each.value.user
  role_definition_name = each.value.policy
  principal_type       = each.value.principal_type #Required for RASS
}
