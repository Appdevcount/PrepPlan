package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Note, the function name must begin with "Test", and each test in package must have a unique function name
// include the t.Parallel line to allow multiple tests to run in parallel
func Test4_DefaultValues(t *testing.T) {
	//	t.Parallel()

	/************************************************************************************************************
		Test 4 - Geo-redundant event hub, logging to EH. Terraform Destroy does not always tear down properly,
		so testing only uses Terraform plan action.
	*************************************************************************************************************/
	testpath := "./Standard_&_Basic"
	testvars := "test4.tfvars"
	expectresults := []string{
		"azurerm_eventhub_namespace_authorization_rule.LoggingRule will be created",
		"azurerm_log_analytics_workspace.law will be created",
		"azurerm_resource_group.rg will be created",
		"azurerm_resource_group.rg2 will be created",
		"azurerm_storage_account.storage will be created",
		"azurerm_subnet.allowsnet will be created",
		"azurerm_subnet.remoteendpoints will be created",
		"azurerm_subnet.sndrendpoints[0] will be created",
		"azurerm_subnet.snendpoints will be created",
		"azurerm_virtual_network.drendpoints[0] will be created",
		"azurerm_virtual_network.endpoints will be created",
		"azurerm_virtual_network.vnet will be created",
		"random_id.rndm will be created",
		"module.Azure-GoldenEventHub-Test.azurerm_eventhub.eventhub[\"be-messaging\"] will be created",
		"module.Azure-GoldenEventHub-Test.azurerm_eventhub.eventhub[\"fe-messaging\"] will be created",
		"module.Azure-GoldenEventHub-Test.azurerm_eventhub.eventhub[\"offloading\"] will be created",
		"module.Azure-GoldenEventHub-Test.azurerm_eventhub_authorization_rule.eventhub_allowed[\"fe-messaging.app_policy\"] will be created",
		"module.Azure-GoldenEventHub-Test.azurerm_eventhub_authorization_rule.eventhub_allowed[\"fe-messaging.device_policy\"] will be created",
		"module.Azure-GoldenEventHub-Test.azurerm_eventhub_authorization_rule.eventhub_allowed[\"offloading.ol_policy\"] will be created",
		"module.Azure-GoldenEventHub-Test.azurerm_eventhub_consumer_group.consumer_group[\"be-messaging.beapps\"] will be created",
		"module.Azure-GoldenEventHub-Test.azurerm_eventhub_consumer_group.consumer_group[\"fe-messaging.feapps\"] will be created",
		"module.Azure-GoldenEventHub-Test.azurerm_eventhub_consumer_group.consumer_group[\"fe-messaging.iotand\"] will be created",
		"module.Azure-GoldenEventHub-Test.azurerm_eventhub_consumer_group.consumer_group[\"fe-messaging.iotios\"] will be created",
		"module.Azure-GoldenEventHub-Test.azurerm_eventhub_consumer_group.consumer_group[\"offloading.olgroup\"] will be created",
		"module.Azure-GoldenEventHub-Test.azurerm_eventhub_namespace.drnamespace[0] will be created",
		"module.Azure-GoldenEventHub-Test.azurerm_eventhub_namespace.namespace will be created",
		"module.Azure-GoldenEventHub-Test.azurerm_eventhub_namespace_authorization_rule.nssap[\"auditpol\"] will be created",
		"module.Azure-GoldenEventHub-Test.azurerm_eventhub_namespace_disaster_recovery_config.dr[0] will be created",
		"module.Azure-GoldenEventHub-Test.azurerm_monitor_diagnostic_setting.eventhub[0] will be created",
		"module.Azure-GoldenEventHub-Test.azurerm_private_endpoint.drendpoint[0] will be created",
		"module.Azure-GoldenEventHub-Test.azurerm_private_endpoint.endpoint[0] will be created",
		"Plan: 32 to add, 0 to change, 0 to destroy.",
	}

	terraformOptions := &terraform.Options{
		// The relative path to where Terraform test code is located
		TerraformDir: testpath,

		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{testvars},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}

	//Destroy resources after test is complete
	//defer terraform.Destroy(t, terraformOptions)

	//Run Terraform Init and Apply to test
	//terraOut := terraform.InitAndApply(t, terraformOptions)

	// !! Use this instead if module being created should be tested using "Terraform plan" only, without actually deploying resources !!
	// !! Remember to comment out destroy command above if using InitAndPlan																													!!
	terraOut := terraform.InitAndPlan(t, terraformOptions)

	//Check for expected output text
	for _, outtxt := range expectresults {
		assert.Contains(t, terraOut, outtxt)
	}

}
