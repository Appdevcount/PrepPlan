# Terraform Module Unit Testing				
## Module: Azure Golden Key Vault
## Developer: Marc Billings
## Version: 1.0.0		

<br>

## Checklist				
| x | Item checked |
| --- | --------------------------------------------------------------------------------------------------- |
|  | All standard files exist (\_providers.tf, \_variables.tf, \_outputs.tf, /example folder, README.MD) |
|  | Tags\_notes.MD (If updating an existing module)     |
|  | Follows accepted Cigna Terraform standards, best practices, and conventions                         |
|  | Final unit test called module being tested from the Github repository                               |
|  | Unit test root module(s) saved in "/unit\_test" folder                                              |

<br>

# Unit Testing -- use cases should cover (as applicable):

  Deployment using default variable values (i.e. no value passed in to optional variables)			
	Solution components in multiple resource groups (e.g. VNet passed into module resides in a resource group other than the resources that will be created by the module)			
	Components that might be in a different subscription (such as private endpoints)			
	Geo-redundant (if supported)			
	Use cases with different configurations			

<br>

## Major Functionality Area: <Functionaliy area 1>
| Test case config | Functionality covered |
|------------------|-----------------------|

| 1 | 2 | 3 | 4 |                                      |
|---|---|---|---|--------------------------------------|
|  |   |   |   | Configuration tested |
|  |   |   |   | ... |


## Major Functionality Area: <If applicable, Functionality 2>
| Test case config | Functionality covered |
|------------------|-----------------------|

| 1 | 2 | 3 | 4 |                                      |
|---|---|---|---|--------------------------------------|
|  |   |   |   | Configuration tested |
|  |   |   |   | ... |

