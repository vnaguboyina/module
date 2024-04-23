variable "function_app_service_name" {
    type            = string
    validation {
      condition = can(regex("^[0-9a-z][-0-9a-z]{1,58}[0-9a-z]$", var.function_app_service_name))
      error_message = "Must be a minimum of 3 characters and cannot start or end with a special character."
    }

    validation {
      condition = length(var.function_app_service_name) < 32
      error_message = "Value for function app service name should not be more than 31 characters"
    }
  
}

variable "app_settings" {
    type = map(string)
    default = {
      
    }
    validation {
      condition = (
        (!contains(keys(var.app_settings), "AzureWebJobsStorage__accountname")) &&
        (!contains(keys(var.app_settings), "AzureWebJobsStorage__queueServiceUri"))
      )
      error_message = "settings for azurewebjobsstorage are handled by the module and should not be passed with in app_settings"
    }

  
}

variable "health_check_settings" {
  type       = object({
    health_check_eviction_time_in_min = number
    health_check_path                 = string

  })

  dedefault = null
  validation {
    condition = (
        var.health_check_settings == null ? true :
        var.health_check_settings.health_check_eviction_time_in_min > 1 &&
        var.health_check_settings.health_check_eviction_time_in_min < 11
    )
    error_message = "health_check_settings.health_check_eviction_time_in_min must be between 2 and 10 "
  }
    
  } 

default = {}

validation {
    condition   = try(contains(["true", "false"], var.site_config.always_on), true)

}

validation {
    condition        = alltrue([ for curr_element in var.site_config.cors.allowed_origins : !contains(["*", "*.com", "*.net", "*.*"], curr_element)])

}

validation {
    condition  = contains(keys(var.site_config.application_stack), "dotnet_version") || contains(keys(var.site_config.application_stack), "java_version")

}
  
validation {
    condition  = ((try(var.site_config.application_stack.dotnet_version != null, false) && try(var.site_config.application_stack.use_dotnet_isolated_runtime != null, false)) || (!try(var.site_config.application_stack.dotnet_version != null, false) && !try(var.site_config.application_stack.use_dotnet_isolated_runtime != null, false)))

    error_message = "When `dotnet version is set, a value must be provided for use dotnet isolated runtime"
}
