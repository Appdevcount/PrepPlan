package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Note, the function name must begin with "Test", and each test in package must have a unique function name
// include the t.Parallel line to allow multiple tests to run in parallel
func Test2_DefaultValues(t *testing.T) {
	//	t.Parallel()

	/**********************************************************************
		Test 2 - Simple standard tier event hub with default configurations
	***********************************************************************/
	testpath := "./DefaultValues"
	testvars := "test2.tfvars"
	expectresults := []string{
		"azurerm_resource_group.rg: Creation complete",
		"azurerm_subnet.snendpoints: Creation complete",
		"azurerm_virtual_network.endpoints: Creation complete",
		"module.Azure-GoldenEventHub-TC2.azurerm_eventhub.eventhub[\"messages\"]: Creation complete",
		"module.Azure-GoldenEventHub-TC2.azurerm_eventhub_namespace.namespace: Creation complete",
		"module.Azure-GoldenEventHub-TC2.azurerm_private_endpoint.endpoint[0]: Creation complete",
		"Resources: 6 added, 0 changed, 0 destroyed.",
		"ns_name = \"evhns-standard-simple\"",
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
