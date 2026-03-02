/* Here is a third test that will run when "go test -v -timeout 30m" command is issued in the test folder.
   Build as many test cases as needed to exercise all code logic / options for your module. Multiple
	 tests may use the same underlying support infrastructure -- so may refer to the same test
	 subfolder (but referencing different variable files). Notice the "test3.tfvars" file in ../Testenvironmnt2
	 folder as an example of this.                                                                               */

/* This template can be used to quickly build automated test cases using Go and Terratest.
   Update function name and test description; and provide appropriate values for testpath,
   testvars, and expectedresults. If your module supports running multiple tests in parrallel
   uncomment the "t.Parallel()", which will allow test cases to run simultaneously. 						*/

package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Note, the function name must begin with "Test", and each test in package must have a unique function name
// include the t.Parallel line to allow multiple tests to run in parallel
func Test3_ComplexValues(t *testing.T) {
	//	t.Parallel()

	/******************************************************************************************************
		Test 3 - <description of what is being tested>
	******************************************************************************************************/
	testpath := "./<folder containing Terraform test module and variables file>"
	testvars := "<name of variables file, such as test3.tfvars>"
	expectresults := []string{
		"<expected result 1 -- this is text that will be output by Terraform>",
		"EXAMPLE RESULTS FOLLOW:",
		"azurerm_resource_group.rg: Creation complete",
		"module.Azure-GoldenNewModule-Test.azurerm_created_resource.example[\"QuotedName\"]: Creation complete",
		"Resources: 16 added, 0 changed, 0 destroyed.",
		"NewModuleOutput_name = \"expected_name\"",
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
