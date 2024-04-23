data "azurerm_resource_group" "this" {
    name = var.resource_group_name
  
}

data "azurerm_service_plan" "this" {
    resource_group_name = split("/", var.service_plan_id)[4]
    name                = split("/", var.service_plan_id)[8]
  
}

data "azurerm_user_assigned_identity" "this" {
    count = length(var.user_assigned_identity_ids)
    resource_group_name = split("/", var.user_assigned_identity_ids[count.index])[4]
    name = split("/", var.user_assigned_identity_ids[count.index])[8]
  
}

resource "time_static" "created_on" {
  
}

module "wf_resource_tags" {
    source                 = "value"
    version                = "~>3.1.0"
    created_on             = time_static.created_on.rfc3339
    copy_from_subscription = false
    env                    = var.env
    tags                   = var.tags
}

locals {
  combined_app_settings  = merge(var.app_settings, tomap({
    AzureWebJobsStorage__accountname  = "${var.storage_account_name}"
    AzureWebJobsStorage__blobserviceuri = "${var.storage_account_name}.blob.core.windows.net"
    AzureWebJobsStorage__queueserviceuri = "${var.storage_account_name}.queue.core.windows.net"
    AzureWebJobsStorage__tableserviceuri = "${var.storage_account_name}.table.core.windows.net"   
  }

  ))
}

resource "azurerm_linux_function_app" "this" {
   location                                      = data.azurerm_resource_group.this.location
   name                                          = lower(var.function_app_service_name)
   resouresource_group_name                      = data.azurerm_resource_group.this.name
   service_plan_id                               = var.service_plan_id
   keykey_vault_reference_identity_id            = null
   storage_account_name                          = var.storage_account_name
   content_share_forcontent_share_force_disabled = "false"
   functions_extension_functions_extension_version = "~4"
   https_only                                      = true
   public_public_network_access_enabled            = true
   storage_ustorage_uses_managed_identity          = true
   app_settings                                    = local.combined_app_settings
   client_certificate_enabled                      = var.client_certificate_enabled
   client_certificate_mode                         = var.client_certificate_mode
   enabled                                         = var.enabled
   zip_deploy_file                                 = var.zip_deploy_file

   site_config {
     api_definition_url                            = null
     api_management_api_id                         = null
     app_scale_limit                               = null
     elastic_instance_minimum                      = null
     ftps_state                                    = "Disabled"
     http2_enabled                                 = true
     minimum_tls_version                           = "1.2"
     pre_warmed_instance_count                     = null
     remote_debugging_enabled                       = false
     remote_debugging_version                       = null
     runtime_scale_monitoring_enabled               = null


     always_on                                      = coalesce(lookup(var.site_config, "always_on", null), false)
     app_command_line                               = lookup(var.site_config, "app_command_line", null)
     default_documents                              = lookup(var.site_config, "default_documents", null)
     health_check_eviction_time_in_min              = lookup(var.site_config, "health_check_eviction_time_in_min", null)
     health_check_path                              = lookup(var.site_config, "health_check_path", null)
     load_balancing_mode                            = coalesce(lookup(var.site_config, "load_balancing_mode", null), "LeastRequests")
     managed_pipeline_mode                          = coalesce(lookup(var.site_config, "managed_pipeline_mode", null), "Integrated") 
     use_32_bit_worker                              = coalesce(lookup(var.site_config, "use_32_bit_worker", null), "false")
     vnet_route_all_enabled                         = coalesce(lookup(var.site_config, "vnet_route_all_enabled", null), "false") 
     websockets_enabled                             = coalesce(lookup(var.site_config, "websockets_enabled", null), "false")
     worker_count                                   = coalesce(lookup(var.site_config, "worker_count", null), "false")

     application_stack {
       
       dotnet_version                               = lookup(var.site_config, "application_stack", null) != null ? (lookup(var.site_config.application_stack, "dotnet_version" null)) : null
       java_version                               = lookup(var.site_config, "application_stack", null) != null ? (lookup(var.site_config.application_stack, "java_version" null)) : null
       node_version                               = lookup(var.site_config, "application_stack", null) != null ? (lookup(var.site_config.application_stack, "node_version" null)) : null
       powershell_core_version                               = lookup(var.site_config, "application_stack", null) != null ? (lookup(var.site_config.application_stack, "powershell_core_version" null)) : null
       python_version                               = lookup(var.site_config, "application_stack", null) != null ? (lookup(var.site_config.application_stack, "python_version" null)) : null
       use_custom_runtime                                = lookup(var.site_config, "application_stack", null) != null ? (lookup(var.site_config.application_stack, "use_custom_runtime" null)) : null
       use_dotnet_isolated_runtime                       = lookup(var.site_config, "application_stack", null) != null ? (lookup(var.site_config.application_stack, "use_dotnet_isolated_runtime" null)) : null

       dynamic "docker" {
        for_each = lookup(var.site_config, "application_stack", null) != null ? (lookup(var.site_config.application_stack, "docker" null) == null ? [] : ["docker"]) : []
        content {
          registry_url              = var.site_config.application_stack.docker.registry_url
          image_name                = var.site_config.application_stack.docker.image_name
          image_tag                 = var.site_config.application_stack.docker.image_tag
          registry_username         = lookup(var.site_config.application_stack.docker, "registry_username", null)
          registry_password         = lookup(var.site_config.application_stack.docker, "registry_password", null)
        }
         
       }
     }

     cors {
       allowed_origins               = lookup(var.site_config.cors, "allowed_origins", [])
       support_credentials           = lookup(var.site_config.cors, "support_credentials", false)

     }
   }

   identity {
     type                            = length(var.user_assigned_identity_ids) == 0 ? "SystemAssigned" : "SystemAssigned, UserAssigned"
     identity_ids                    = length(var.user_assigned_identity_ids) == 0 ? null : tolist([for v in data.azurerm_user_assigned_identity.this : v.id])

   }

   tags = module.wf_resource_tags.tags

}