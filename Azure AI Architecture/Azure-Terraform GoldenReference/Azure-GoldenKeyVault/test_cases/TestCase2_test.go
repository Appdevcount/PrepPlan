package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Note, the function name must begin with "Test", and each test in package must have a unique function name
// include the t.Parallel line to allow multiple tests to run in parallel
func TestCase2(t *testing.T) {
	//	t.Parallel()

	/******************************************************************************************************
		Test 1 - Deploy Key Vault using RBAC assignments
	******************************************************************************************************/
	testpath := "./TestEnvironment1"
	testvars := "UseRBAC.tfvars"
	expectresults := []string{
		"module.Azure-GoldenKeyVault.azurerm_key_vault.kv: Creation complete",
		"module.Azure-GoldenKeyVault.azurerm_role_assignment.initial[\"0\"]: Creation complete",
		"module.Azure-GoldenKeyVault.azurerm_role_assignment.initial[\"1\"]: Creation complete",
		"module.Azure-GoldenKeyVault.azurerm_role_assignment.initial[\"2\"]: Creation complete",
		"Apply complete! Resources: 5 added, 0 changed, 0 destroyed."}

	/******************************************************************************************************/

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
