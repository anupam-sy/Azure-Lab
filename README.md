# Azure-Lab
This repository contains PowerShell scripts related to different usecases of Azure.

## Prerequisite:
Powershell version must be 5.1 or greater. To check the powersehll version, use the following command.

	$PSVersionTable.PSVersion

Az module must be installed on your system. Az runs on Windows PowerShell 5.1 and PowerShell Core (cross-platform). To check which versions of the module you have installed, use below commands.

	Get-InstalledModule -Name "Az*" (or) Get-Module -Name *Az.* -ListAvailable

To install Az module with global scope, you must have administrator rights else install for user scope only.

	For Global Scope: Install-Module -Name Az -AllowClobber
	For User Scope: Install-Module -Name Az -AllowClobber -Scope CurrentUser

## Execution:
To run the script, go to command prompt and then run the following command:

	powershell -file <script_name_with_complete_path>

## References:

> https://petri.com/azure-az-module-for-windows-powershell-core-and-cloud-shell-replaces-azurerm
