# Terraform Module Unit Testing				
## Module: Azure-GoldenEventHub		
## Developer: Michael Schroeder		
## Version: 0.1.0		

<br>

## Checklist				
| x   | All standard files exist (\_providers.tf, \_variables.tf, \_outputs.tf, /example folder, README.MD) |
| --- | --------------------------------------------------------------------------------------------------- |
| n/a | Tags\_notes.MD (If updating an existing module)     |
| x   | Follows accepted Cigna Terraform standards, best practices, and conventions                         |
| x   | Final unit test called module being tested from the Github repository                               |
| x   | Unit test root module(s) saved in "/unit\_test" folder                                              |

<br>

# Unit Testing -- use cases should cover (as applicable):

  Deployment using default variable values (i.e. no value passed in to optional variables)			
	Solution components in multiple resource groups (e.g. VNet passed into module resides in a resource group other than the resources that will be created by the module)			
	Components that might be in a different subscription (such as private endpoints)			
	Geo-redundant (if supported)			
	Use cases with different configurations			

<br>

## Major Functionality Area: Basic and Standard Tier 
| Test case config | Functionality covered |
|------------------|-----------------------|

| 1 | 2 | 3 | 4 |                                      |
|---|---|---|---|--------------------------------------|
| x |   |   |   | Simple Basic tier namespace with hub |
| x |   |   |   | Simple Basic tier namespace with hub |
|   | x |   |   | All default values -- only required variables passed in |
| x |   |   |   | No  Private Endpoint (over-ride value) |
|   | x |   | x | With Private Endpoint |
|   |   | x |   | Private endpoint in different subscription |
| x | x |   |   | Single Region |
|   |   |   | x | Geo-Redundant |
|   | x |   |   | No firewall rules (virtual network or IP ranges) |
|   |   | x | x | With allowed virtual networks |
|   |   |   | x | With allowed CIDR ranges |
|   | x |   |   | No Shared Access Policy rules (namespace) |
|   |   |   | x | With Shared Access Policy rules (namespace) |
|   | x |   |   | No logging |
| x |   |   |   | Logging to storage account |
|   |   | x |   | Logging to LAW |
|   |   |   | x | Logging to event hub |
|   |   | x | x | Multiple hubs |
| x | x |   |   | No consumer groups |
|   |   | x | x | With consumer groups |
|   | x | x | x | No Shared Access Policy rules (hubs) |
|   |   | x | x | With Shared Access Policy rules (hubs) |
| x |   |   |   | With incompatible values passed in for Basic tier (auto-inflate, multiple/non-defult consumer group(s) |


## Major Functionality Area: Dedicated Cluster
| Covered by test case                              | Functionality |
|------------------|-----------------------|

| 5 | 6 | 7 |   |                                      |
|---|---|---|---|--------------------------------------|
| x | x |   |   | No  Private Endpoint (over-ride value) |
|   |   | x |   | With Private Endpoint |
| x | x |   |   | Single region |
|   |   | x |   | Geo-redundant paired with Standard tier hub |
| x |   |   |   | No firewall rules |
|   | x | x |   | With firewall rules |
| x |   |   |   | No Shared Access Policy rules (namespace) |
|   | x | x |   | With Shared Access Policy rules (namespace) |
| x |   |   |   | No logging |
|   | x | x |   | Logging to event hub (other logging options covered in Shared Tier) |
|   |   |   |   | No hubs |
| x | x | x |   | With hubs |
| x | x | x |   | No Shared Access Policy rules (hubs) |
|   | x | x |   | With Shared Access Policy rules (hubs) |
| x |   |   |   | With incompatible configuration values (TU, Auto-inflate, wrong region, wrong resource group) to verify code logic corrects |

