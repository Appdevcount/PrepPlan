# How to use site_config variable
Every application will require unique configurations, defined by the site_config block. This block is constructed based on values provide in the site_config variable for this module. Some configurations have been pre-selected based on Cigna standards, but most need to be selected and configured based on the specific workload.

## Supported site_config variables

| Variable | Description |
|----------|-------------|
| always_on | Should the app be loaded at all times? Defaults to false. |
| app_command_line | App command line to launch, e.g. /sbin/myserver -b 0.0.0.0. |
| dotnet_framework_version | The version of the .net framework's CLR used in this App Service. |
| health_check_path | The health check path to be pinged by App Service. |
| http2_enabled | Is HTTP2 Enabled on this App Service? Defaults to false. |
| java_version | The version of Java to use. If specified java_container and java_container_version must also be specified. |
| java_container | The Java Container to use. If specified java_version and java_container_version must also be specified. Possible values are JAVA, JETTY, and TOMCAT. |
| java_container_version | The version of the Java Container to use. If specified java_version and java_container must also be specified. |
| linux_fx_version | Linux App Framework and version for the App Service. To set this property the App Service Plan to which the App belongs must be configured with kind = "Linux", and reserved = true or the API will reject any value supplied. |
| windows_fx_version | The Windows App Framework and version for the App Service. |
| php_version | The version of PHP to use in this App Service. |
| python_version | The version of Python to use in this App Service. |
| vnet_route_all_enabled | Should all outbound traffic have Virtual Network Security Groups and User Defined Routes applied? This is automatically enabled for App Services running on premium tier as part of deploying the private endpoint. |
| websockets_enabled | Should WebSockets be enabled? |


Reference https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service