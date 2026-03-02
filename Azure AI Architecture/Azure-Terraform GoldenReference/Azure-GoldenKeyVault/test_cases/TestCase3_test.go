package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Note, the function name must begin with "Test", and each test in package must have a unique function name
// include the t.Parallel line to allow multiple tests to run in parallel
func TestCase3(t *testing.T) {
	//	t.Parallel()

	/******************************************************************************************************
		Test 1 - Deploy Key Vault with private endpoints, VNet integration, and all deployment options true.
		 --> This test will not work, because Golden VNet module has an incompatible AzureRM constraint <--
	*******************************************************************************************************/
	testpath := "./TestEnvironment2"
	testvars := "withPEandOptions.tfvars"
	expectresults := []string{"no available releases match the given constraints", "<=2.95.0"}

	/******************************************************************************************************/

	terraformOptions := &terraform.Options{
		// The relative path to where Terraform test code is located
		TerraformDir: testpath,

		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{testvars},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,

		PlanFilePath: "out.tfplan",
	}

	//Run Terraform Init and Apply to test
	_, err := terraform.InitAndPlanE(t, terraformOptions)

	//Check for expected output text
	for _, outtxt := range expectresults {
		assert.Contains(t, err.Error(), outtxt)
	}
}
