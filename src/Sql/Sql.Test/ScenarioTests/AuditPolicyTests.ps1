﻿# ----------------------------------------------------------------------------------
#
# Copyright Microsoft Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------

<#
.SYNOPSIS
Tests that when setting the storage account property's value in a database's blob auditing policy, that value is later fetched properly
#>
function Test-BlobAuditPolicyDatabaseUpdatePolicyWithStorage
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix

	try 
	{
		# Test
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
	
		# Assert
		Assert-AreEqual $policy.StorageAccountName $params.storageAccount
		Assert-AreEqual $policy.BlobStorageTargetState "Enabled"  
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Tests the flow in which re-setting the policy with storage account that has the same name as before, but it is now on a different region
#>
function Test-BlobAuditPolicyDatabaseUpdatePolicyWithSameNameStorageOnDifferentRegion
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix

	try 
	{
		# Test
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
	
		# Assert
		Assert-AreEqual $policy.StorageAccountName $params.storageAccount
		Assert-AreEqual $policy.BlobStorageTargetState "Enabled"  

		$newResourceGroupName =  "test-rg2-for-sql-cmdlets-" + $testSuffix
		New-AzureRmResourceGroup -Location "West Europe" -ResourceGroupName $newResourceGroupName
		New-AzureRmStorageAccount -StorageAccountName $params.storageAccount  -ResourceGroupName $newResourceGroupName -Location "West Europe" -Type Standard_GRS 

		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
	
		# Assert
		Assert-AreEqual $policy.StorageAccountName $params.storageAccount
		Assert-AreEqual $policy.BlobStorageTargetState "Enabled"  
	}
	finally
	{
		# Cleanup
		Remove-AzureRmResourceGroup -Name $newResourceGroupName -Force
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Tests that when setting the storage account property's value in a server's blob auditing policy, that value is later fetched properly
#>
function Test-BlobAuditPolicyServerUpdatePolicyWithStorage
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix

	try
	{
		# Test
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $params.storageAccount
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
	
		# Assert
		Assert-AreEqual $policy.StorageAccountName $params.storageAccount
		Assert-AreEqual $policy.BlobStorageTargetState "Enabled" 
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Tests that after setting the storage account property's value in a database's auditing policy, this value is used on next policy set operations as default. Meaning: if you don't want to change the 
storage account, you don't need to provide it.
#>
function Test-BlobAuditPolicyDatabaseUpdatePolicyKeepPreviousStorage
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix

	try 
	{
		# Test
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount
		$policyBefore = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName

		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		$policyAfter = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
	
		# Assert
		Assert-AreEqual $policyBefore.StorageAccountName $policyAfter.StorageAccountName
		Assert-AreEqual $policyAfter.StorageAccountName $params.storageAccount 

	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Tests that after setting the storage account property's value in a server's blob auditing policy, this value is used on next policy set operations as default. Meaning: if you don't want to change the 
storage account, you don't need to provide it.
#>
function Test-BlobAuditPolicyServerUpdatePolicyKeepPreviousStorage
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix

	try 
	{
		# Test
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $params.storageAccount
		$policyBefore = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName

		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName 
		$policyAfter = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
	
		# Assert
		Assert-AreEqual $policyBefore.StorageAccountName $policyAfter.StorageAccountName
		Assert-AreEqual $policyAfter.StorageAccountName $params.storageAccount 

	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Tests that when asking to disable blob auditing of a database, later when fetching the policy, it is marked as disabled
#>
function Test-BlobAuditPolicyDisableDatabaseAuditPolicy
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix

	try
	{
		# Test
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $params.storageAccount
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		
		# Assert
		Assert-AreEqual $policy.BlobStorageTargetState "Enabled"

		# Test
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
	
		# Assert
		Assert-AreEqual $policy.BlobStorageTargetState "Disabled"
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Tests that when asking to disable auditing of a server, later when fetching the policy, it is marked as disabled
#>
function Test-BlobAuditPolicyDisableServerAuditPolicy
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix

	try
	{
		# Test
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $params.storageAccount
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
	
		# Assert
		Assert-AreEqual $policy.BlobStorageTargetState "Disabled"
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Tests that a failure occurs when trying to set a policy to a database, and that database does not have a policy as well as the policy does not have a storage account  
#>
function Test-BlobAuditPolicyFailedDatabaseUpdatePolicyWithNoStorage
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix

	try
	{
		# Assert
		Assert-Throws { Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverWithoutPolicy -DatabaseName $params.databaseWithoutPolicy }
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Tests that a failure occurs when trying to set a policy to a server, and that policy does not have a storage account  
#>
function Test-BlobAuditPolicyFailedServerUpdatePolicyWithNoStorage
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix

	try
	{
		# Assert
		Assert-Throws { Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverWithoutPolicy}
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Tests that it is impossible to use non existing database with the cmdlets 
#>
function Test-BlobAuditPolicyFailWithBadDatabaseIndentity
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix

	try 
	{
		# Assert
		Assert-Throws { Get-AzSqlDatabaseAuditPolicy -ResourceGroupName "NONEXISTING-RG" -ServerName $params.serverName -DatabaseName $params.databaseName }
		Assert-Throws { Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName "NONEXISTING-SERVER"-DatabaseName $params.databaseName }
		Assert-Throws { Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName "NONEXISTING-RG"  -ServerName $params.serverName -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount}
		Assert-Throws { Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName "NONEXISTING-SERVER" -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount}
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Tests that it is impossible to use non existing server with the cmdlets 
#>
function Test-BlobAuditPolicyFailWithBadServerIndentity
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix

	try 
	{
		# Assert
		Assert-Throws { Get-AzSqlServerAuditPolicy -ResourceGroupName "NONEXISTING-RG" -ServerName $params.serverName }
		Assert-Throws { Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName "NONEXISTING-SERVER" }
		Assert-Throws { Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName "NONEXISTING-RG"  -ServerName $params.serverName -StorageAccountName $params.storageAccount}
		Assert-Throws { Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName "NONEXISTING-SERVER" -StorageAccountName $params.storageAccount}
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Tests that storage key rotation process for a policy of a Sql database server is managed properly
#>
function Test-BlobAuditPolicyServerStorageKeyRotation
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix

	try
	{
		# Test
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $params.storageAccount -StorageKeyType "Primary"
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName 
	
		# Assert
		Assert-True { $policy.StorageKeyType -eq  "Primary"}

		# Test
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $params.storageAccount -StorageKeyType "Secondary"
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName 
	
		# Assert
		Assert-True { $policy.StorageKeyType -eq  "Secondary"}

		# Test
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $params.storageAccount -StorageKeyType "Primary"
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName 
	
		# Assert
		Assert-True { $policy.StorageKeyType -eq  "Primary"}
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Tests that storage key rotation process for a policy of a Sql database is managed properly
#>
function Test-BlobAuditPolicyDatabaseStorageKeyRotation
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix

	try
	{
		# Test
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName  -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount -StorageKeyType "Primary"
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName  -DatabaseName $params.databaseName
	
		# Assert
		Assert-True { $policy.StorageKeyType -eq  "Primary"}

		# Test
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName  -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount -StorageKeyType "Secondary"
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName  -DatabaseName $params.databaseName
	
		# Assert
		Assert-True { $policy.StorageKeyType -eq  "Secondary"}

		# Test
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName  -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount -StorageKeyType "Primary"
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName  -DatabaseName $params.databaseName
	
		# Assert
		Assert-True { $policy.StorageKeyType -eq  "Primary"}
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Tests that after setting the retention values to a server auditing policy, this value is used on next policy set operations as default.
#>
function Test-BlobAuditPolicyServerRetentionKeepProperties
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix

	try
	{
		# Test
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $params.storageAccount -RetentionInDays 10;

		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $params.storageAccount -RetentionInDays 11;
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName

		# Assert
		Assert-AreEqual $policy.RetentionInDays 11

		# Test
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $params.storageAccount;
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName

		# Assert
		Assert-AreEqual $policy.RetentionInDays 11
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Tests that after setting the retention values to a database auditing policy, this value is used on next policy set operations as default.
#>
function Test-BlobAuditPolicyDatabaseRetentionKeepProperties
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix

	try
	{
		# Test
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount -RetentionInDays 10;
	
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount -RetentionInDays 11;
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName

		# Assert
		Assert-AreEqual $policy.RetentionInDays 11

		# Test
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount;
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName

		# Assert
		Assert-AreEqual $policy.RetentionInDays 11
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Tests that when modifying properties of a databases's blob auditing policy, these properties are later fetched properly
#>
function Test-BlobAuditPolicyOnDatabase
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix
	$dbName = $params.databaseName

	# NEEDS TO BE FILLED OUT WITH A PRECREATED STORAGE ACCOUNT IN A DIFFERENT SUBSCRIPTION
	$subscriptionId = "a8c9a924-06c0-4bde-9788-e7b1370969e1"
	$storageAccountName = "auditcmdletssa"

	try
	{
		# Test - Tests that when setting blob auditing policy on database without StorageKeyType parameter, it gets the default value - "Primary".
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount -AuditActionGroup "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP", "FAILED_DATABASE_AUTHENTICATION_GROUP" -RetentionInDays 8 
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
	
		# Assert
		Assert-AreEqual $policy.BlobStorageTargetState "Enabled"
		Assert-AreEqual $policy.AuditActionGroup.Length 2
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual $policy.AuditAction.Length 0
		Assert-AreEqual $policy.RetentionInDays 8
		Assert-True { $policy.StorageKeyType -eq  "Primary"}
		
		# Test - Tests setting blob auditing policy on a database with a storage account in a subscription which is different than the database's subscription
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -StorageAccountName $storageAccountName -AuditActionGroup "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP", "FAILED_DATABASE_AUTHENTICATION_GROUP" -RetentionInDays 8 -StorageAccountSubscriptionId $subscriptionId
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		
		# Assert
		Assert-AreEqual $policy.BlobStorageTargetState "Enabled"
		Assert-AreEqual $policy.AuditActionGroup.Length 2
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual $policy.AuditAction.Length 0
		Assert-AreEqual $policy.RetentionInDays 8
		Assert-True { $policy.StorageKeyType -eq  "Primary"}
		Assert-AreEqual $policy.StorageAccountSubscriptionId $subscriptionId
		
		# Test	
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount -StorageKeyType "Secondary" -AuditActionGroup "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP", "FAILED_DATABASE_AUTHENTICATION_GROUP" -RetentionInDays 8 -AuditAction "UPDATE ON database::[$($params.databaseName)] BY [public]"
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		
		# Assert
		Assert-AreEqual $policy.BlobStorageTargetState "Enabled"
		Assert-AreEqual $policy.AuditActionGroup.Length 2
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual $policy.RetentionInDays 8
		Assert-True { $policy.StorageKeyType -eq  "Secondary"}
		Assert-AreEqual $policy.AuditAction.Length 1
		Assert-AreEqual $policy.AuditAction "UPDATE ON database::[$($params.databaseName)] BY [public]"
		
		# Test
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		
		# Assert
		Assert-AreEqual $policy.BlobStorageTargetState "Disabled"
		Assert-AreEqual $policy.AuditAction.Length 1
		
		# Test - Providing empty AuditActionGroups and an AuditAction
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -AuditActionGroup @() -AuditAction "UPDATE ON database::[$($params.databaseName)] BY [public]"
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		
		# Assert
		Assert-AreEqual $policy.AuditActionGroup.Length 0
		Assert-AreEqual $policy.AuditAction.Length 1
		Assert-AreEqual $policy.AuditAction[0] "UPDATE ON database::[$($params.databaseName)] BY [public]"
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Tests that when modifying properties of a server's blob auditing policy, these properties are later fetched properly
#>
function Test-BlobAuditPolicyOnServer
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix

	# NEEDS TO BE FILLED OUT WITH A PRECREATED STORAGE ACCOUNT IN A DIFFERENT SUBSCRIPTION
	$subscriptionId = "a8c9a924-06c0-4bde-9788-e7b1370969e1"
	$storageAccountName = "auditcmdletssa"

	try
	{
		# Test - Tests that when setting blob auditing policy on server without StorageKeyType parameter, it gets the default value - "Primary".
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $params.storageAccount -AuditActionGroup "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP", "FAILED_DATABASE_AUTHENTICATION_GROUP" -RetentionInDays 8
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
	
		# Assert
		Assert-AreEqual $policy.BlobStorageTargetState "Enabled"
		Assert-AreEqual $policy.AuditActionGroup.Length 2
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual $policy.RetentionInDays 8
		Assert-AreEqual $policy.StorageKeyType "Primary"

		# Test - Tests setting blob auditing policy on a server with a storage account in a subscription which is different than the server's subscription
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $storageAccountName -AuditActionGroup "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP", "FAILED_DATABASE_AUTHENTICATION_GROUP" -RetentionInDays 8 -StorageAccountSubscriptionId $subscriptionId
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
	
		# Assert
		Assert-AreEqual $policy.BlobStorageTargetState "Enabled"
		Assert-AreEqual $policy.AuditActionGroup.Length 2
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual $policy.RetentionInDays 8
		Assert-AreEqual $policy.StorageKeyType "Primary"
		Assert-AreEqual $policy.StorageAccountSubscriptionId $subscriptionId

		# Test	
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $params.storageAccount -StorageKeyType "Secondary" -AuditActionGroup "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP", "FAILED_DATABASE_AUTHENTICATION_GROUP" -RetentionInDays 8
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
	
		# Assert
		Assert-AreEqual $policy.BlobStorageTargetState "Enabled"
		Assert-AreEqual $policy.AuditActionGroup.Length 2
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual $policy.RetentionInDays 8
		Assert-AreEqual $policy.StorageKeyType "Secondary"

		# Test
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
	
		# Assert
		Assert-AreEqual $policy.BlobStorageTargetState "Disabled"
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Tests that when modifying the auditActionGroup property of a blob auditing policy, these properties are later fetched properly
#>
function Test-BlobAuditPolicyWithAuditActionGroups
{
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix

	try
	{
		# Test - when setting new blob auditing policy for database without audit action groups, the default audit action groups is set.
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
	
		# Assert
		Assert-AreEqual $policy.AuditActionGroup.Length 3
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::BATCH_COMPLETED_GROUP)}

		# Test - when setting blob auditing policy for database with audit action groups, the default audit action groups is being replaced by the new audit action groups.
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount -AuditActionGroup "APPLICATION_ROLE_CHANGE_PASSWORD_GROUP","DATABASE_OBJECT_PERMISSION_CHANGE_GROUP"
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
	
		# Assert
		Assert-AreEqual $policy.AuditActionGroup.Length 2
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::APPLICATION_ROLE_CHANGE_PASSWORD_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::DATABASE_OBJECT_PERMISSION_CHANGE_GROUP)} 

		# Test - tests that audit action groups can be changed
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount -AuditActionGroup "DATABASE_OPERATION_GROUP","DATABASE_LOGOUT_GROUP"
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
	
		# Assert
		Assert-AreEqual $policy.AuditActionGroup.Length 2
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::DATABASE_OPERATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::DATABASE_LOGOUT_GROUP)}

		# Test - when updating blob auditing policy for existing one without audit action groups, the action groups won't change.
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
	
		# Assert
		Assert-AreEqual $policy.AuditActionGroup.Length 2
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::DATABASE_OPERATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::DATABASE_LOGOUT_GROUP)}

		# Test - when setting new blob auditing policy for server without audit action groups, the default audit action groups is set.
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $params.storageAccount
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
	
		# Assert
		Assert-AreEqual $policy.AuditActionGroup.Length 3
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::BATCH_COMPLETED_GROUP)}

		# Test
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $params.storageAccount -AuditActionGroup "APPLICATION_ROLE_CHANGE_PASSWORD_GROUP","DATABASE_OBJECT_PERMISSION_CHANGE_GROUP"
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
	
		# Assert
		Assert-AreEqual $policy.AuditActionGroup.Length 2
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::APPLICATION_ROLE_CHANGE_PASSWORD_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::DATABASE_OBJECT_PERMISSION_CHANGE_GROUP)}

		# Test - tests that audit action groups can be changed
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $params.storageAccount -AuditActionGroup "DATABASE_OPERATION_GROUP","DATABASE_LOGOUT_GROUP"
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
	
		# Assert
		Assert-AreEqual $policy.AuditActionGroup.Length 2
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::DATABASE_OPERATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::DATABASE_LOGOUT_GROUP)}

		# Test - when updating blob auditing policy for existing one without audit action groups, the action groups won't change.
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $params.storageAccount
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
	
		# Assert
		Assert-AreEqual $policy.AuditActionGroup.Length 2
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::DATABASE_OPERATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::DATABASE_LOGOUT_GROUP)}
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Test for extended auditing and auditing on a server
#>
function Test-ExtendedAuditPolicyOnServer
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix

	try
	{
		# Enable auditing policy, without speficying a predicate expression, and verify it.
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $params.storageAccount -AuditActionGroup "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP", "FAILED_DATABASE_AUTHENTICATION_GROUP" -RetentionInDays 8
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Enabled" $policy.BlobStorageTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual 8 $policy.RetentionInDays
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual "" $policy.PredicateExpression

		# Enable Extended auditing policy, speficying a predicate expression, and verify it.
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $params.storageAccount -AuditActionGroup "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP", "FAILED_DATABASE_AUTHENTICATION_GROUP" -RetentionInDays 8 -PredicateExpression "statement <> 'select 1'"
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Enabled" $policy.BlobStorageTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual 8 $policy.RetentionInDays
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual "statement <> 'select 1'" $policy.PredicateExpression

		# Disable auditing policy and verify it.
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Disabled" $policy.BlobStorageTargetState

		# Enable Extended auditing policy, without speficying a predicate expression, and verify it.
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $params.storageAccount -AuditActionGroup "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP", "FAILED_DATABASE_AUTHENTICATION_GROUP" -RetentionInDays 8
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Enabled" $policy.BlobStorageTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual 8 $policy.RetentionInDays
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual "statement <> 'select 1'" $policy.PredicateExpression

		# Remove Extended auditing policy, and enable auditing policy
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -StorageAccountName $params.storageAccount -AuditActionGroup "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP", "FAILED_DATABASE_AUTHENTICATION_GROUP" -RetentionInDays 8 -PredicateExpression ""
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Enabled" $policy.BlobStorageTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual 8 $policy.RetentionInDays
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual "" $policy.PredicateExpression

		# Disable auditing policy.
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Test for extended auditing and auditing on a database
#>
function Test-ExtendedAuditPolicyOnDatabase
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix

	try
	{
		# Enable auditing policy, without speficying a predicate expression, and verify it.
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount -AuditActionGroup "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP", "FAILED_DATABASE_AUTHENTICATION_GROUP" -RetentionInDays 8
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Enabled" $policy.BlobStorageTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual 8 $policy.RetentionInDays
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual "" $policy.PredicateExpression

		# Enable Extended auditing policy, speficying a predicate expression, and verify it.
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount -AuditActionGroup "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP", "FAILED_DATABASE_AUTHENTICATION_GROUP" -RetentionInDays 8 -PredicateExpression "statement <> 'select 1'"
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Enabled" $policy.BlobStorageTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual 8 $policy.RetentionInDays
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual "statement <> 'select 1'" $policy.PredicateExpression

		# Disable auditing policy and verify it.
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName 
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Disabled" $policy.BlobStorageTargetState

		# Enable Extended auditing policy, without speficying a predicate expression, and verify it.
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount -AuditActionGroup "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP", "FAILED_DATABASE_AUTHENTICATION_GROUP" -RetentionInDays 8
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Enabled" $policy.BlobStorageTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual 8 $policy.RetentionInDays
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual "statement <> 'select 1'" $policy.PredicateExpression

		# Remove Extended auditing policy, and enable auditing policy
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -StorageAccountName $params.storageAccount -AuditActionGroup "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP", "FAILED_DATABASE_AUTHENTICATION_GROUP" -RetentionInDays 8 -PredicateExpression ""
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Enabled" $policy.BlobStorageTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual 8 $policy.RetentionInDays
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual "" $policy.PredicateExpression

		# Disable auditing policy.
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName 
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Test for all auditing settings on a database
#>
function Test-AuditPolicyOnDatabase
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix
	$subscriptionId = (Get-AzContext).Subscription.Id
	$workspaceResourceId = "/subscriptions/" + $subscriptionId + "/resourcegroups/" + $params.rgname + "/providers/microsoft.operationalinsights/workspaces/" + $params.workspaceName
	$eventHubAuthorizationRuleResourceId = "/subscriptions/" + $subscriptionId + "/resourcegroups/" + $params.rgname + "/providers/microsoft.EventHub/namespaces/" + $params.eventHubNamespace + "/authorizationrules/RootManageSharedAccessKey"
	$resourceId = "/subscriptions/" + $subscriptionId + "/resourceGroups/" + $params.rgname + "/providers/Microsoft.Sql/servers/" + $params.serverName + "/databases/" + $params.databaseName

	try
	{
		# Verify Diagnostic Settings do not exist.
		Assert-AreEqual 0 (Get-AzDiagnosticSetting -ResourceId $resourceId).count

		# Verify storage auditing policy is Disabled.
		$policy = Get-AzSqlDatabase -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName | Get-AzSqlDatabaseAuditPolicy
		Assert-AreEqual "Disabled" $policy.BlobStorageTargetState
		Assert-AreEqual 0 $policy.AuditActionGroup.Length
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-Null $policy.PredicateExpression
		Assert-Null $policy.StorageAccountName
		Assert-AreEqual "00000000-0000-0000-0000-000000000000" $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 0 $policy.RetentionInDays
		
		# Verify event hub auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.EventHubTargetState
		Assert-Null $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId
		
		# Enable storage auditing policy and verify it.
		Get-AzSqlDatabase -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName | Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -StorageAccountName $params.storageAccount -AuditActionGroup "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP", "FAILED_DATABASE_AUTHENTICATION_GROUP" -RetentionInDays 8
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Enabled" $policy.BlobStorageTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-AreEqual $params.storageAccount $policy.StorageAccountName
		Assert-AreEqual $subscriptionId $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 8 $policy.RetentionInDays
		
		# Verify event hub auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.EventHubTargetState
		Assert-Null $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId
		
		# Verify Diagnostic Settings do not exist.
		Assert-AreEqual 0 (Get-AzDiagnosticSetting -ResourceId $resourceId).count

		# Enable event hub auditing policy and verify it
		Set-AzSqlDatabaseAuditPolicy -EventHubTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -EventHubAuthorizationRuleResourceId $eventHubAuthorizationRuleResourceId
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify storage auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.BlobStorageTargetState
		Assert-AreEqual $params.storageAccount $policy.StorageAccountName
		Assert-AreEqual $subscriptionId $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 8 $policy.RetentionInDays
		
		# Verify log analytics auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId
		
		# Verify Diagnostic Settings exist.
		Assert-AreEqual 1 (Get-AzDiagnosticSetting -ResourceId $resourceId).count

		# Enable log analytics auditing policy and verify it
		Set-AzSqlDatabaseAuditPolicy -LogAnalyticsTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -WorkspaceResourceId $workspaceResourceId
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Enabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-AreEqual $workspaceResourceId $policy.WorkspaceResourceId
		
		# Verify storage auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.BlobStorageTargetState
		Assert-AreEqual $params.storageAccount $policy.StorageAccountName
		Assert-AreEqual $subscriptionId $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 8 $policy.RetentionInDays
		
		# Verify event hub auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify Diagnostic Settings exist.
		Assert-AreEqual 1 (Get-AzDiagnosticSetting -ResourceId $resourceId).count
		
		# Disable storage auditing policy and verify it.
		Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Disabled" $policy.BlobStorageTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-Null $policy.StorageAccountName
		Assert-AreEqual "00000000-0000-0000-0000-000000000000" $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 0 $policy.RetentionInDays
		
		# Verify event hub auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual $workspaceResourceId $policy.WorkspaceResourceId
		
		# Verify Diagnostic Settings exist.
		Assert-AreEqual 1 (Get-AzDiagnosticSetting -ResourceId $resourceId).count
		
		# Disable log analytics auditing policy and verify it
		Set-AzSqlDatabaseAuditPolicy -LogAnalyticsTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-Null $policy.WorkspaceResourceId
		
		# Verify storage auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.BlobStorageTargetState
		Assert-Null $policy.StorageAccountName
		Assert-AreEqual "00000000-0000-0000-0000-000000000000" $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 0 $policy.RetentionInDays
		
		# Verify event hub auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify Diagnostic Settings exist.
		Assert-AreEqual 1 (Get-AzDiagnosticSetting -ResourceId $resourceId).count

		# Disable event hub auditing policy and verify it
		Set-AzSqlDatabaseAuditPolicy -EventHubTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Disabled" $policy.EventHubTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-Null $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify storage auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.BlobStorageTargetState
		Assert-Null $policy.StorageAccountName
		Assert-AreEqual "00000000-0000-0000-0000-000000000000" $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 0 $policy.RetentionInDays
		
		# Verify log analytics auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId

		# Verify Diagnostic Settings do not exist.
		Assert-AreEqual 0 (Get-AzDiagnosticSetting -ResourceId $resourceId).count
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Test removal of all auditing settings on a database
#>
function Test-RemoveAuditPolicyOnDatabase
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix
	$subscriptionId = (Get-AzContext).Subscription.Id
	$workspaceResourceId = "/subscriptions/" + $subscriptionId + "/resourcegroups/" + $params.rgname + "/providers/microsoft.operationalinsights/workspaces/" + $params.workspaceName
	$eventHubAuthorizationRuleResourceId = "/subscriptions/" + $subscriptionId + "/resourcegroups/" + $params.rgname + "/providers/microsoft.EventHub/namespaces/" + $params.eventHubNamespace + "/authorizationrules/RootManageSharedAccessKey"
	$resourceId = "/subscriptions/" + $subscriptionId + "/resourceGroups/" + $params.rgname + "/providers/Microsoft.Sql/servers/" + $params.serverName + "/databases/" + $params.databaseName

	try
	{
		# Verify Diagnostic Settings do not exist.
		Assert-AreEqual 0 (Get-AzDiagnosticSetting -ResourceId $resourceId).count

		# Verify storage auditing policy is Disabled.
		$policy = Get-AzSqlDatabase -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName | Get-AzSqlDatabaseAuditPolicy
		Assert-AreEqual "Disabled" $policy.BlobStorageTargetState
		Assert-AreEqual 0 $policy.AuditActionGroup.Length
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-Null $policy.PredicateExpression
		Assert-Null $policy.StorageAccountName
		Assert-AreEqual "00000000-0000-0000-0000-000000000000" $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 0 $policy.RetentionInDays
		
		# Verify event hub auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.EventHubTargetState
		Assert-Null $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId
		
		# Enable storage auditing policy and verify it.
		Get-AzSqlDatabase -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName | Set-AzSqlDatabaseAuditPolicy -BlobStorageTargetState Enabled -StorageAccountName $params.storageAccount -AuditActionGroup "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP", "FAILED_DATABASE_AUTHENTICATION_GROUP" -RetentionInDays 8
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Enabled" $policy.BlobStorageTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-AreEqual $params.storageAccount $policy.StorageAccountName
		Assert-AreEqual $subscriptionId $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 8 $policy.RetentionInDays
		
		# Verify event hub auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.EventHubTargetState
		Assert-Null $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId
		
		# Verify Diagnostic Settings do not exist.
		Assert-AreEqual 0 (Get-AzDiagnosticSetting -ResourceId $resourceId).count

		# Enable event hub auditing policy and verify it
		Set-AzSqlDatabaseAuditPolicy -EventHubTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -EventHubAuthorizationRuleResourceId $eventHubAuthorizationRuleResourceId
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify storage auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.BlobStorageTargetState
		Assert-AreEqual $params.storageAccount $policy.StorageAccountName
		Assert-AreEqual $subscriptionId $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 8 $policy.RetentionInDays
		
		# Verify log analytics auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId
		
		# Verify Diagnostic Settings exist.
		Assert-AreEqual 1 (Get-AzDiagnosticSetting -ResourceId $resourceId).count

		# Enable log analytics auditing policy and verify it
		Set-AzSqlDatabaseAuditPolicy -LogAnalyticsTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -WorkspaceResourceId $workspaceResourceId
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Enabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-AreEqual $workspaceResourceId $policy.WorkspaceResourceId
		
		# Verify storage auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.BlobStorageTargetState
		Assert-AreEqual $params.storageAccount $policy.StorageAccountName
		Assert-AreEqual $subscriptionId $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 8 $policy.RetentionInDays
		
		# Verify event hub auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify Diagnostic Settings exist.
		Assert-AreEqual 1 (Get-AzDiagnosticSetting -ResourceId $resourceId).count
		
		# Disable auditing policy and verify it.
		Remove-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Disabled" $policy.BlobStorageTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-Null $policy.StorageAccountName
		Assert-AreEqual "00000000-0000-0000-0000-000000000000" $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 0 $policy.RetentionInDays
		
		# Verify event hub auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.EventHubTargetState
		Assert-Null $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId
		
		# Verify Diagnostic Settings do not exist.
		Assert-AreEqual 0 (Get-AzDiagnosticSetting -ResourceId $resourceId).count
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Test for all auditing settings on a server
#>
function Test-AuditPolicyOnServer
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix
	$subscriptionId = (Get-AzContext).Subscription.Id
	$workspaceResourceId = "/subscriptions/" + $subscriptionId + "/resourcegroups/" + $params.rgname + "/providers/microsoft.operationalinsights/workspaces/" + $params.workspaceName
	$eventHubAuthorizationRuleResourceId = "/subscriptions/" + $subscriptionId + "/resourcegroups/" + $params.rgname + "/providers/microsoft.EventHub/namespaces/" + $params.eventHubNamespace + "/authorizationrules/RootManageSharedAccessKey"
	$resourceId = "/subscriptions/" + $subscriptionId + "/resourceGroups/" + $params.rgname + "/providers/Microsoft.Sql/servers/" + $params.serverName + "/databases/master"

	try
	{
		# Verify Diagnostic Settings do not exist.
		Assert-AreEqual 0 (Get-AzDiagnosticSetting -ResourceId $resourceId).count

		# Verify storage auditing policy is disabled.
		$policy = Get-AzSqlServer -ResourceGroupName $params.rgname -ServerName $params.serverName | Get-AzSqlServerAuditPolicy
		Assert-AreEqual "Disabled" $policy.BlobStorageTargetState
		Assert-AreEqual 0 $policy.AuditActionGroup.Length
		Assert-Null $policy.StorageAccountName
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-AreEqual "00000000-0000-0000-0000-000000000000" $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 0 $policy.RetentionInDays
		
		# Verify event hub auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.EventHubTargetState
		Assert-Null $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId
		
		# Enable storage auditing policy and verify it.
		Get-AzSqlServer -ResourceGroupName $params.rgname -ServerName $params.serverName | Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -StorageAccountName $params.storageAccount -AuditActionGroup "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP", "FAILED_DATABASE_AUTHENTICATION_GROUP" -RetentionInDays 8
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Enabled" $policy.BlobStorageTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-AreEqual $params.storageAccount $policy.StorageAccountName
		Assert-AreEqual $subscriptionId $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 8 $policy.RetentionInDays
		
		# Verify event hub auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.EventHubTargetState
		Assert-Null $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId
		
		# Verify Diagnostic Settings do not exist.
		Assert-AreEqual 0 (Get-AzDiagnosticSetting -ResourceId $resourceId).count

		# Enable event hub auditing policy and verify it
		Set-AzSqlServerAuditPolicy -EventHubTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -EventHubAuthorizationRuleResourceId $eventHubAuthorizationRuleResourceId
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify storage auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.BlobStorageTargetState
		Assert-AreEqual $params.storageAccount $policy.StorageAccountName
		Assert-AreEqual $subscriptionId $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 8 $policy.RetentionInDays
		
		# Verify log analytics auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId
		
		# Verify Diagnostic Settings exist.
		Assert-AreEqual 1 (Get-AzDiagnosticSetting -ResourceId $resourceId).count

		# Enable log analytics auditing policy and verify it
		Set-AzSqlServerAuditPolicy -LogAnalyticsTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -WorkspaceResourceId $workspaceResourceId
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Enabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-AreEqual $workspaceResourceId $policy.WorkspaceResourceId
		
		# Verify storage auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.BlobStorageTargetState
		Assert-AreEqual $params.storageAccount $policy.StorageAccountName
		Assert-AreEqual $subscriptionId $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 8 $policy.RetentionInDays
		
		# Verify event hub auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify Diagnostic Settings exist.
		Assert-AreEqual 1 (Get-AzDiagnosticSetting -ResourceId $resourceId).count
		
		# Disable storage auditing policy and verify it.
		Set-AzSqlServerAuditPolicy -BlobStorageTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Disabled" $policy.BlobStorageTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-Null $policy.StorageAccountName
		Assert-AreEqual "00000000-0000-0000-0000-000000000000" $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 0 $policy.RetentionInDays
		
		# Verify event hub auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual $workspaceResourceId $policy.WorkspaceResourceId
		
		# Verify Diagnostic Settings exist.
		Assert-AreEqual 1 (Get-AzDiagnosticSetting -ResourceId $resourceId).count
		
		# Disable log analytics auditing policy and verify it
		Set-AzSqlServerAuditPolicy -LogAnalyticsTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-Null $policy.WorkspaceResourceId
		
		# Verify storage auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.BlobStorageTargetState
		Assert-Null $policy.StorageAccountName
		Assert-AreEqual "00000000-0000-0000-0000-000000000000" $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 0 $policy.RetentionInDays
		
		# Verify event hub auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify Diagnostic Settings exist.
		Assert-AreEqual 1 (Get-AzDiagnosticSetting -ResourceId $resourceId).count

		# Disable event hub auditing policy and verify it
		Set-AzSqlServerAuditPolicy -EventHubTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Disabled" $policy.EventHubTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-Null $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify storage auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.BlobStorageTargetState
		Assert-Null $policy.StorageAccountName
		Assert-AreEqual "00000000-0000-0000-0000-000000000000" $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 0 $policy.RetentionInDays
		
		# Verify log analytics auditing policy is disabled.
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId

		# Verify Diagnostic Settings do not exist.
		Assert-AreEqual 0 (Get-AzDiagnosticSetting -ResourceId $resourceId).count
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Test removal of all auditing settings on a server
#>
function Test-RemoveAuditPolicyOnServer
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix
	$subscriptionId = (Get-AzContext).Subscription.Id
	$workspaceResourceId = "/subscriptions/" + $subscriptionId + "/resourcegroups/" + $params.rgname + "/providers/microsoft.operationalinsights/workspaces/" + $params.workspaceName
	$eventHubAuthorizationRuleResourceId = "/subscriptions/" + $subscriptionId + "/resourcegroups/" + $params.rgname + "/providers/microsoft.EventHub/namespaces/" + $params.eventHubNamespace + "/authorizationrules/RootManageSharedAccessKey"
	$resourceId = "/subscriptions/" + $subscriptionId + "/resourceGroups/" + $params.rgname + "/providers/Microsoft.Sql/servers/" + $params.serverName + "/databases/master"

	try
	{
		# Verify Diagnostic Settings do not exist.
		Assert-AreEqual 0 (Get-AzDiagnosticSetting -ResourceId $resourceId).count

		# Verify storage auditing policy is disabled.
		$policy = Get-AzSqlServer -ResourceGroupName $params.rgname -ServerName $params.serverName | Get-AzSqlServerAuditPolicy
		Assert-AreEqual "Disabled" $policy.BlobStorageTargetState
		Assert-AreEqual 0 $policy.AuditActionGroup.Length
		Assert-Null $policy.StorageAccountName
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-AreEqual "00000000-0000-0000-0000-000000000000" $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 0 $policy.RetentionInDays
		
		# Verify event hub auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.EventHubTargetState
		Assert-Null $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId
		
		# Enable storage auditing policy and verify it.
		Get-AzSqlServer -ResourceGroupName $params.rgname -ServerName $params.serverName | Set-AzSqlServerAuditPolicy -BlobStorageTargetState Enabled -StorageAccountName $params.storageAccount -AuditActionGroup "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP", "FAILED_DATABASE_AUTHENTICATION_GROUP" -RetentionInDays 8
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Enabled" $policy.BlobStorageTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-AreEqual $params.storageAccount $policy.StorageAccountName
		Assert-AreEqual $subscriptionId $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 8 $policy.RetentionInDays
		
		# Verify event hub auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.EventHubTargetState
		Assert-Null $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId
		
		# Verify Diagnostic Settings do not exist.
		Assert-AreEqual 0 (Get-AzDiagnosticSetting -ResourceId $resourceId).count

		# Enable event hub auditing policy and verify it
		Set-AzSqlServerAuditPolicy -EventHubTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -EventHubAuthorizationRuleResourceId $eventHubAuthorizationRuleResourceId
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify storage auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.BlobStorageTargetState
		Assert-AreEqual $params.storageAccount $policy.StorageAccountName
		Assert-AreEqual $subscriptionId $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 8 $policy.RetentionInDays
		
		# Verify log analytics auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId
		
		# Verify Diagnostic Settings exist.
		Assert-AreEqual 1 (Get-AzDiagnosticSetting -ResourceId $resourceId).count

		# Enable log analytics auditing policy and verify it
		Set-AzSqlServerAuditPolicy -LogAnalyticsTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -WorkspaceResourceId $workspaceResourceId
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Enabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-AreEqual $workspaceResourceId $policy.WorkspaceResourceId
		
		# Verify storage auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.BlobStorageTargetState
		Assert-AreEqual $params.storageAccount $policy.StorageAccountName
		Assert-AreEqual $subscriptionId $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 8 $policy.RetentionInDays
		
		# Verify event hub auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify Diagnostic Settings exist.
		Assert-AreEqual 1 (Get-AzDiagnosticSetting -ResourceId $resourceId).count
		
		# Disable audit policy and verify it.
		Remove-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Disabled" $policy.BlobStorageTargetState
		Assert-AreEqual 2 $policy.AuditActionGroup.Length
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP)}
		Assert-True {$policy.AuditActionGroup.Contains([Microsoft.Azure.Commands.Sql.Auditing.Model.AuditActionGroups]::FAILED_DATABASE_AUTHENTICATION_GROUP)}
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-Null $policy.StorageAccountName
		Assert-AreEqual "00000000-0000-0000-0000-000000000000" $policy.StorageAccountSubscriptionId
		Assert-AreEqual "Primary" $policy.StorageKeyType
		Assert-AreEqual 0 $policy.RetentionInDays
		
		# Verify event hub auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.EventHubTargetState
		Assert-Null $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId
		
		# Verify Diagnostic Settings do not exist.
		Assert-AreEqual 0 (Get-AzDiagnosticSetting -ResourceId $resourceId).count
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}
<#
.SYNOPSIS
Tests that new diagnostic settings are created when needed while enabling or disabling policy.
#>
function Test-NewDatabaseAuditPolicyDiagnosticsAreCreatedOnNeed
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix
	$subscriptionId = (Get-AzContext).Subscription.Id
	$workspaceResourceId = "/subscriptions/" + $subscriptionId + "/resourcegroups/" + $params.rgname + "/providers/microsoft.operationalinsights/workspaces/" + $params.workspaceName
	$eventHubAuthorizationRuleResourceId = "/subscriptions/" + $subscriptionId + "/resourcegroups/" + $params.rgname + "/providers/microsoft.EventHub/namespaces/" + $params.eventHubNamespace + "/authorizationrules/RootManageSharedAccessKey"
	$resourceId = "/subscriptions/" + $subscriptionId + "/resourceGroups/" + $params.rgname + "/providers/Microsoft.Sql/servers/" + $params.serverName + "/databases/" + $params.databaseName

	try
	{
		# Verify event hub auditing policy is disabled.
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Disabled" $policy.EventHubTargetState
		Assert-AreEqual 0 $policy.AuditActionGroup.Length
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-Null $policy.PredicateExpression
		Assert-Null $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace

		# Verify log analytics auditing policy is Disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId

		# Enable event hub auditing policy and verify it.
		Set-AzSqlDatabaseAuditPolicy -EventHubTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -EventHubAuthorizationRuleResourceId $eventHubAuthorizationRuleResourceId
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace

		# Verify log analytics auditing policy is Disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId

		# Verify only one diagnostic settings exists.
		$diagnostics = Get-AzDiagnosticSetting -ResourceId $resourceId
		Assert-AreEqual 1 ($diagnostics).count

		# Enable a new category in existing Diagnostic Settings.
		$settingsName = ($diagnostics)[0].Name
		Set-AzDiagnosticSetting -ResourceId $resourceId -Enabled $True -Name $settingsName -Category SQLInsights
		
		# Enable log analytics auditing policy and verify it
		Set-AzSqlDatabaseAuditPolicy -LogAnalyticsTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -WorkspaceResourceId $workspaceResourceId
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Enabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-AreEqual $workspaceResourceId $policy.WorkspaceResourceId

		# Verify event hub auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace

		# Verify Diagnostic Settings were splitted.
		Assert-AreEqual 2 (Get-AzDiagnosticSetting -ResourceId $resourceId).count
		
		# Remove old Diagnostics.
		Remove-AzDiagnosticSetting -ResourceId $resourceId -Name $settingsName
		# Verify only one diagnostic settings exists.
		$diagnostics = Get-AzDiagnosticSetting -ResourceId $resourceId
		Assert-AreEqual 1 ($diagnostics).count

		# Enable a new category in Diagnostic Settings.
		$settingsName = ($diagnostics)[0].Name
		Set-AzDiagnosticSetting -ResourceId $resourceId -Enabled $True -Name $settingsName -Category SQLInsights
		
		# Verify log analytics auditing policy is enabled.
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Enabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-AreEqual $workspaceResourceId $policy.WorkspaceResourceId
		
		# Verify event hub auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Enable event hub auditing policy and verify it.
		Set-AzSqlDatabaseAuditPolicy -EventHubTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -EventHubAuthorizationRuleResourceId $eventHubAuthorizationRuleResourceId
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual $workspaceResourceId $policy.WorkspaceResourceId
		
		# Verify Diagnostic Settings were splitted.
		Assert-AreEqual 2 (Get-AzDiagnosticSetting -ResourceId $resourceId).count
		
		# Remove old Diagnostics.
		Remove-AzDiagnosticSetting -ResourceId $resourceId -Name $settingsName
		# Verify only one diagnostic settings exist.
		$diagnostics = Get-AzDiagnosticSetting -ResourceId $resourceId
		Assert-AreEqual 1 ($diagnostics).count
		
		# Enable a new category in Diagnostic Settings
		$settingsName = ($diagnostics)[0].Name
		Set-AzDiagnosticSetting -ResourceId $resourceId -Enabled $True -Name $settingsName -Category SQLInsights
		
		# Verify event hub auditing settings is enabled.
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual $workspaceResourceId $policy.WorkspaceResourceId

		# Disable event hub auditing policy and verify it.
		Set-AzSqlDatabaseAuditPolicy -EventHubTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Disabled" $policy.EventHubTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-Null $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual $workspaceResourceId $policy.WorkspaceResourceId
		
		# Verify Diagnostic Settings were splitted.
		Assert-AreEqual 2 (Get-AzDiagnosticSetting -ResourceId $resourceId).count
		
		# Remove old Diagnostics
		Remove-AzDiagnosticSetting -ResourceId $resourceId -Name $settingsName
		# Verify only one diagnostic settings exist.
		$diagnostics = Get-AzDiagnosticSetting -ResourceId $resourceId
		Assert-AreEqual 1 ($diagnostics).count

		# Verify event hub auditing policy is disabled.
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Disabled" $policy.EventHubTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-Null $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual $workspaceResourceId $policy.WorkspaceResourceId
		
		# Enable event hub auditing policy and verify it.
		Set-AzSqlDatabaseAuditPolicy -EventHubTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName -EventHubAuthorizationRuleResourceId $eventHubAuthorizationRuleResourceId
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual $workspaceResourceId $policy.WorkspaceResourceId
		
		# Enable a new category in Diagnostic Settings.
		$diagnostics = Get-AzDiagnosticSetting -ResourceId $resourceId
		Assert-AreEqual 1 ($diagnostics).count
		$settingsName = ($diagnostics)[0].Name
		Set-AzDiagnosticSetting -ResourceId $resourceId -Enabled $True -Name $settingsName -Category SQLInsights
		
		# Disable log analytics auditing policy and verify it
		Set-AzSqlDatabaseAuditPolicy -LogAnalyticsTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-Null $policy.WorkspaceResourceId
		
		# Verify event hub auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify Diagnostic Settings were splitted.
		Assert-AreEqual 2 (Get-AzDiagnosticSetting -ResourceId $resourceId).count
		
		# Remove old Diagnostics
		Remove-AzDiagnosticSetting -ResourceId $resourceId -Name $settingsName
		# Verify log analytics auditing policy is Disabled.
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-Null $policy.WorkspaceResourceId
		
		# Verify event hub auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Disable event hub auditing policy and verify it.
		Set-AzSqlDatabaseAuditPolicy -EventHubTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		$policy = Get-AzSqlDatabaseAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName -DatabaseName $params.databaseName
		Assert-AreEqual "Disabled" $policy.EventHubTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-AreEqual 0 $policy.AuditAction.Length
		Assert-AreEqual "" $policy.PredicateExpression
		Assert-Null $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is Disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId
		
		# Verify Diagnostic Settings do not exist.
		Assert-AreEqual 0 (Get-AzDiagnosticSetting -ResourceId $resourceId).count
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}

<#
.SYNOPSIS
Tests that new diagnostic settings are created when needed while enabling or disabling policy.
#>
function Test-NewServerAuditPolicyDiagnosticsAreCreatedOnNeed
{
	# Setup
	$testSuffix = getAssetName
	Create-BlobAuditingTestEnvironment $testSuffix
	$params = Get-SqlBlobAuditingTestEnvironmentParameters $testSuffix
	$subscriptionId = (Get-AzContext).Subscription.Id
	$workspaceResourceId = "/subscriptions/" + $subscriptionId + "/resourcegroups/" + $params.rgname + "/providers/microsoft.operationalinsights/workspaces/" + $params.workspaceName
	$eventHubAuthorizationRuleResourceId = "/subscriptions/" + $subscriptionId + "/resourcegroups/" + $params.rgname + "/providers/microsoft.EventHub/namespaces/" + $params.eventHubNamespace + "/authorizationrules/RootManageSharedAccessKey"
	$resourceId = "/subscriptions/" + $subscriptionId + "/resourceGroups/" + $params.rgname + "/providers/Microsoft.Sql/servers/" + $params.serverName + "/databases/master"

	try
	{
		# Verify event hub auditing policy is disabled.
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Disabled" $policy.EventHubTargetState
		Assert-AreEqual 0 $policy.AuditActionGroup.Length
		Assert-Null $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace

		# Verify log analytics auditing policy is Disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId

		# Enable event hub auditing policy and verify it.
		Set-AzSqlServerAuditPolicy -EventHubTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -EventHubAuthorizationRuleResourceId $eventHubAuthorizationRuleResourceId
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace

		# Verify log analytics auditing policy is Disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId

		# Verify only one diagnostic settings exists.
		$diagnostics = Get-AzDiagnosticSetting -ResourceId $resourceId
		Assert-AreEqual 1 ($diagnostics).count (($diagnostics).count + "1")

		# Enable a new category in existing Diagnostic Settings.
		$settingsName = ($diagnostics)[0].Name
		Set-AzDiagnosticSetting -ResourceId $resourceId -Enabled $True -Name $settingsName -Category SQLInsights

		# Enable log analytics auditing policy and verify it
		Set-AzSqlServerAuditPolicy -LogAnalyticsTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -WorkspaceResourceId $workspaceResourceId
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Enabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-AreEqual $workspaceResourceId $policy.WorkspaceResourceId

		# Verify event hub auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify Diagnostic Settings were splitted.
		Assert-AreEqual 2 (Get-AzDiagnosticSetting -ResourceId $resourceId).count "2"
		
		# Remove old Diagnostics.
		Remove-AzDiagnosticSetting -ResourceId $resourceId -Name $settingsName
		
		# Verify only one diagnostic settings exists.
		$diagnostics = Get-AzDiagnosticSetting -ResourceId $resourceId
		Assert-AreEqual 1 ($diagnostics).count "3"
		
		# Enable a new category in Diagnostic Settings.
		$settingsName = ($diagnostics)[0].Name
		Set-AzDiagnosticSetting -ResourceId $resourceId -Enabled $True -Name $settingsName -Category SQLInsights
		
		# Verify log analytics auditing policy is enabled.
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Enabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-AreEqual $workspaceResourceId $policy.WorkspaceResourceId
		
		# Verify event hub auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Enable event hub auditing policy and verify it.
		Set-AzSqlServerAuditPolicy -EventHubTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -EventHubAuthorizationRuleResourceId $eventHubAuthorizationRuleResourceId
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual $workspaceResourceId $policy.WorkspaceResourceId
		
		# Verify Diagnostic Settings were splitted.
		Assert-AreEqual 2 (Get-AzDiagnosticSetting -ResourceId $resourceId).count "4"
		
		# Remove old Diagnostics.
		Remove-AzDiagnosticSetting -ResourceId $resourceId -Name $settingsName
		
		# Verify only one diagnostic settings exist.
		$diagnostics = Get-AzDiagnosticSetting -ResourceId $resourceId
		Assert-AreEqual 1 ($diagnostics).count "5"
		
		# Enable a new category in Diagnostic Settings
		$settingsName = ($diagnostics)[0].Name
		Set-AzDiagnosticSetting -ResourceId $resourceId -Enabled $True -Name $settingsName -Category SQLInsights
		# Verify event hub auditing settings is enabled.
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-AreEqual $workspaceResourceId $policy.WorkspaceResourceId
		
		# Disable event hub auditing policy and verify it.
		Set-AzSqlServerAuditPolicy -EventHubTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Disabled" $policy.EventHubTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-Null $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual $workspaceResourceId $policy.WorkspaceResourceId
		
		# Verify Diagnostic Settings were splitted.
		Assert-AreEqual 2 (Get-AzDiagnosticSetting -ResourceId $resourceId).count "6"
		
		# Remove old Diagnostics
		Remove-AzDiagnosticSetting -ResourceId $resourceId -Name $settingsName
		# Verify only one diagnostic settings exist.
		$diagnostics = Get-AzDiagnosticSetting -ResourceId $resourceId
		Assert-AreEqual 1 ($diagnostics).count "7"
		
		# Verify event hub auditing policy is disabled.
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Disabled" $policy.EventHubTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-Null $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual $workspaceResourceId $policy.WorkspaceResourceId
		
		# Enable event hub auditing policy and verify it.
		Set-AzSqlServerAuditPolicy -EventHubTargetState Enabled -ResourceGroupName $params.rgname -ServerName $params.serverName -EventHubAuthorizationRuleResourceId $eventHubAuthorizationRuleResourceId
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual $workspaceResourceId $policy.WorkspaceResourceId
		
		# Enable a new category in Diagnostic Settings.
		$diagnostics = Get-AzDiagnosticSetting -ResourceId $resourceId
		Assert-AreEqual 1 ($diagnostics).count "8"
		$settingsName = ($diagnostics)[0].Name
		Set-AzDiagnosticSetting -ResourceId $resourceId -Enabled $True -Name $settingsName -Category SQLInsights
		
		# Disable log analytics auditing policy and verify it
		Set-AzSqlServerAuditPolicy -LogAnalyticsTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-Null $policy.WorkspaceResourceId
		
		# Verify event hub auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify Diagnostic Settings were splitted.
		Assert-AreEqual 2 (Get-AzDiagnosticSetting -ResourceId $resourceId).count "9"
		
		# Remove old Diagnostics
		Remove-AzDiagnosticSetting -ResourceId $resourceId -Name $settingsName
		# Verify log analytics auditing policy is Disabled.
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-Null $policy.WorkspaceResourceId
		
		# Verify event hub auditing policy is enabled.
		Assert-AreEqual "Enabled" $policy.EventHubTargetState
		Assert-AreEqual $eventHubAuthorizationRuleResourceId $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Disable event hub auditing policy and verify it.
		Set-AzSqlServerAuditPolicy -EventHubTargetState Disabled -ResourceGroupName $params.rgname -ServerName $params.serverName
		$policy = Get-AzSqlServerAuditPolicy -ResourceGroupName $params.rgname -ServerName $params.serverName
		Assert-AreEqual "Disabled" $policy.EventHubTargetState
		Assert-AreEqual 3 $policy.AuditActionGroup.Length
		Assert-Null $policy.EventHubAuthorizationRuleResourceId
		Assert-Null $policy.EventHubNamespace
		
		# Verify log analytics auditing policy is Disabled.
		Assert-AreEqual "Disabled" $policy.LogAnalyticsTargetState
		Assert-Null $policy.WorkspaceResourceId
		
		# Verify Diagnostic Settings do not exist.
		Assert-AreEqual 0 (Get-AzDiagnosticSetting -ResourceId $resourceId).count
	}
	finally
	{
		# Cleanup
		Remove-BlobAuditingTestEnvironment $testSuffix
	}
}