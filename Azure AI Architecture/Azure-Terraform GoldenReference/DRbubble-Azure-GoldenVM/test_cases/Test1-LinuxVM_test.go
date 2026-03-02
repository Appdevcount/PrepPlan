package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Note, the function name must begin with "Test", and each test in package must have a unique function name
// include the t.Parallel line to allow multiple tests to run in parallel
func Test1_LinuxVM(t *testing.T) {
	//	t.Parallel()

	/******************************************************************************************************
		Test 1 - Deploy standard Linux and Windows VMs from Azure Compute Gallery
	******************************************************************************************************/
	testpath := "./TestEnvironment"
	testvars := "testVMs.tfvars"
	expectresults := []string{
		"module.Azure-GoldenKeyVault.azurerm_key_vault.kv: Creation complete",
		"module.Azure-GoldenKeyVault.azurerm_key_vault_access_policy.initial[\"self\"]: Creation complete",
		"module.Azure-GoldenVMs[\"Win2019-vm\"].azurerm_network_interface.vmnic[0]: Creation complete",
		"module.Azure-GoldenVMs[\"Win2019-vm\"].azurerm_network_interface.vmnic[0]: Creation complete",
		"module.Azure-GoldenVMs[\"Win2019-vm\"].azurerm_windows_virtual_machine.windows-vm[0]: Creation complete",
		"module.Azure-GoldenVMs[\"Linux2004-vm\"].azurerm_managed_disk.vmDataDisk[\"01\"]: Creation complete",
		"module.Azure-GoldenVMs[\"Linux2004-vm\"].azurerm_network_interface.vmnic[0]: Creation complete",
		"module.Azure-GoldenVMs[\"Linux2004-vm\"].azurerm_linux_virtual_machine.linux-vm[0]: Creation complete",
		"module.Azure-GoldenVMs[\"Linux2004-vm\"].azurerm_virtual_machine_data_disk_attachment.vmDataDisk[\"01\"]: Creation complete",
		"Apply complete! Resources: 14 added, 0 changed, 0 destroyed."}

	/******************************************************************************************************/

	terraformOptions := &terraform.Options{
		// The relative path to where Terraform test code is located
		TerraformDir: testpath,

		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{testvars},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}

	//Multiple defer statements execute in LIFO order
	//Destroy resources after test is complete
	defer terraform.Destroy(t, terraformOptions)
	//Sleep 5 minutes to mitigate issues trying to destroy a Key Vault immediately after creation
	defer time.Sleep(5 * time.Minute)
	defer fmt.Println("Sleeping 5 minutes before destroy to mitigate issue with destroying Key Vault immediately after creation")

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
