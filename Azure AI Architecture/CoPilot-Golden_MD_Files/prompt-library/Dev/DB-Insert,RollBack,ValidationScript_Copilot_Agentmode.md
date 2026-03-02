1. Insert Script
This script inserts a new role called "GSP User Profile" into the Roles table, but only if it does not already exist. 
It sets both the Permission and PermissionDescription columns to "GSP User Profile". 
The ID column is assumed to be an identity column and will auto-increment.
2. Rollback Script
This script removes the "GSP User Profile" role from the Roles table if it exists.
3. Validation Script
This script checks if the "GSP User Profile" role exists in the Roles table.