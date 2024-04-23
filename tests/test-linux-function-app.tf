locals {
  lnxfunc_test_regoin_code = "scus"
  lnxfunc_test_env         = "nonprod"
  lnxfunc_test_base_name   = ""
  lnxfunc_test_additional_name = ""
  
  lnx_app_service_plan_id = ""
  private_endpoint_subnet_id = ""
  lnxfunc_test_tags = {
    ci_environment   = "test"
    data_classification = "internal"
  }

}

module "wf_resource_group_lnxfunc_test" {
    providers = {
      azurerm = azurerm.ase_testing
    }
    source = ""
    version = "~>3.0.0"
    region_code = local.lnxfunc_test_regoin_code
    env = local.lnxfunc_test_env
    base_name = local.lnxfunc_test_base_name
    additional_name = local.lnxfunc_test_additional_name
    tags = local.lnxfunc_test_tags
}

module "wf_key_vault_lnxfunc_test" {
    providers = {
      azurerm = azurerm.ase_testing

    }
    source = ""
    version = "~>4.1.0"

    region_code = local.lnxfunc_test_regoin_code
    env = local.lnxfunc_test_env
    base_name = local.lnxfunc_test_base_name
    additional_name = local.lnxfunc_test_additional_name
    rnd_suffix_length = 0
    no_dashes = true

    resource_group_name = module.wf_resource_group_lnxfunc_test.base_name
    subnet_id = local.private_endpoint_subnet_id
    network_acls = {
        bypass = "AzureServices"
        default_action = "Deny"
        ip_rules = [
            ""
            ""
            ""
            ""
            ""
        ]

        virtual_network_subnet_ids = []
    }

    tags = local.lnxfunc_test_tags
}


module "wf_storage_account_lnxfunc_storage1" {
    providers = {
      azurerm = azurerm.ase_testing

    }
    source = "value"
    version = "~>4.4.0"

    region_code = local.lnxfunc_test_regoin_code
    env          = local.lnxfunc_test_env
    base_name    = local.lnxfunc_test_base_name
    additional_name = local.additional_name
    rnd_suffix_length = 0

    resource_group_name = module.wf_resource_group_lnxfunc_test.base_name

    account_kind   = ""
    account_replication_type = ""
    access_tier  = ""
    key_vault_id = module.wf_key_vault_lnxfunc_test.id
    key_size = 2048
    shared_access_key_enabled = false
    private_endpoints = ["blob"]
    subnet_id = local.private_endpoint_subnet_id
    network_rules = {
        bypass = ["AzureServices"]
        default_action = "Deny"
        ip_rules = [
            ""
            ""
            ""
            ""
            ""
            ""

        ]
        virtual_network_subnet_ids = []
        }

        containers = {
            containera = {
                name = "releases"
            }
        }

        tags = local.lnxfunc_test_tags
    }

    module "wf_user_assigned_identity_lnx_funcapp_test" {
        providers = {
          azurerm = azurerm.ase_testing
        }

        source = "value"
        version = "value"
        azuread_object_id = module.wf_user_assigned_identity_lnx_funcapp_test.principal_id

        role_definition_name = ""
        scope = module.wf_key_vault_lnxfunc_test.id
        azuread_principal_type = "objectid"

           
    }

    module "wf_linux_function_write" {
        providers = {
          azurerm = azurerm.ase_testing
        }
        source = ""
        env = local.lnxfunc_test_env
        function_app_service_name = "test-lnx-func"
        resource_group_name = module.wf_resource_group_lnxfunc_test.name
        service_plan_id = local.lnx_app_service_plan_id
        storage_account_name = module.wf_storage_account_lnxfunc_storage1.name
        enabled = true
        user_assigned_identity_ids = [module.wf_user_assigned_identity_lnx_funcapp_test.id]

        app_settings = {
            NODE_TLS_REJECT_UNAUTHORIZED = 0
            WEBSITE_VNET_ROUTE_ALL = 1
        }

        site_config = {
            always_on = "true"
            application_stack = {
                python_version = ""
            }
            cors = {
                allowed_origins = []
                support_credentials = false
            }
            https_enabled = true
            managed_pipeline_mode = "Integrated"
            minimum_tls_version   = "1.2"
            vnet_route_all_enabled = true
            worker_count           = 1
        }
        tags = local.lnxfunc_test_tags
    }
