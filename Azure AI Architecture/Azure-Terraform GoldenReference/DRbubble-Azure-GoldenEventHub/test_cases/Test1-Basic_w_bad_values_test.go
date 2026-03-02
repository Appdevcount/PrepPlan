package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Note, the function name must begin with "Test", and each test in package must have a unique function name
// include the t.Parallel line to allow multiple tests to run in parallel
func Test1_DefaultValues(t *testing.T) {
	//	t.Parallel()

	/******************************************************************************************************
		Test 1 - Basic tier event hub with bad values passed in to test module logic for incompatible values
	******************************************************************************************************/
	testpath := "./Standard_&_Basic"
	testvars := "test1.tfvars"
	expectresults := []string{
		"azurerm_resource_group.rg: Creation complete",
		"azurerm_resource_group.rg2: Creation complete",
		"azurerm_virtual_network.vnet: Creation complete",
		"azurerm_subnet.allowsnet: Creation complete",
		"azurerm_subnet.remoteendpoints: Creation complete",
		"azurerm_virtual_network.endpoints: Creation complete",
		"azurerm_subnet.snendpoints: Creation complete",
		"azurerm_storage_account.storage: Creation complete",
		"module.Azure-GoldenEventHub-Test.azurerm_eventhub_namespace.namespace: Creation complete",
		"module.Azure-GoldenEventHub-Test.azurerm_eventhub.eventhub[\"defaulthub\"]: Creation complete",
		"module.Azure-GoldenEventHub-Test.azurerm_monitor_diagnostic_setting.eventhub[0]: Creation complete",
		"module.Azure-GoldenEventHub-Test.azurerm_eventhub_consumer_group.consumer_group[\"defaulthub.notallowed\"]: Creation complete",
		"azurerm_eventhub_namespace_authorization_rule.LoggingRule: Creation complete",
		"Resources: 16 added, 0 changed, 0 destroyed.",
		"ns_name = \"evhns-basic\"",
		"default_RootManageSharedAccessKey = <sensitive>",
		"drprivate_endpoint_id = [",
		"eventhub_namespace_authorization_rule_id = []",
		"ns_id = \"/subscriptions/",
		"ns_identity = tolist([",
		"private_endpoint_id = [",
		"Apply complete!"}

	terraformOptions := &terraform.Options{
		// The relative path to where Terraform test code is located
		TerraformDir: testpath,

		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{testvars},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}

	//Destroy resources after test is complete
	defer terraform.Destroy(t, terraformOptions)

	//Run Terraform Init and Apply to test
	terraOut := terraform.InitAndApply(t, terraformOptions)

	// !! Use this instead if module being created should be tested using "Terraform plan" only, without actually deploying resources !!
	// !! Remember to comment out destroy command above if using InitAndPlan																													!!
	//terraOut := terraform.InitAndPlan(t, terraformOptions)

	//Check for expected output text
	for _, outtxt := range expectresults {
		assert.Contains(t, terraOut, outtxt)
	}

}
