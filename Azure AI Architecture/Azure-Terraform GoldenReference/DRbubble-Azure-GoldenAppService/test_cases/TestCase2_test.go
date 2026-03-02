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
		Test 1 - Deploy typical App Service using standard tier SKU
	******************************************************************************************************/
	testpath := "./TestEnvironment1"
	testvars := "standardApp.tfvars"
	expectresults := []string{
		"module.Azure-GoldenAppService.azurerm_app_service_plan.asp: Creation complete",
		"module.Azure-GoldenAppService.azurerm_app_service.webapp: Creation complete",
		"module.Azure-GoldenAppService.azurerm_app_service_slot.stage: Creation complete",
		"Resources: 6 added, 0 changed, 0 destroyed.",
		"Apply complete!"}

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
