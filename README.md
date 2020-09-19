# PowerShell-Lab
This repository contains PowerShell scripts related to different usecases.

Prerequisite:
-------------
1) Powershell version must be 5.1 or greater. To check the powersehll version,
use the following command:

	$PSVersionTable.PSVersion

2) Execution policy of the user (thru which you want to execute the script) must
be set to unrestricted for the uninterrupted execution. To check the execution 
policy, run the following command in powershell terminal:

	get-executionpolicy -list

To define/set the execution policy to unrestricted, Run the following command in
powershell window:

	set-executionpolicy unrestricted

Execution:
----------
To run the script, go to command prompt and then run the following command:

	powershell -file <script_name_with_complete_path>
