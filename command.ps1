#Generic function to check variables in dRMM PowerShell script
#@param $site_variable: the value of the site/account level variable to check
#@param $script_variable: the value of the script level variable to check
#@param $exit_if_missing: set to $true is variable is required to finish the script
#@param $exit_message: message to output if script is erroring out
#@param $warning_message: message to output if script has variable related error but will continue
#@param $default: default value to return
function Get-dRMMVariable {
    [cmdletbinding()]
    Param($site_variable,
    $script_variable,
    [boolean]$exit_if_missing = $true,
    $exit_message,
    $warning_message,
    $default)

    #Check to see if NO variable value has been passed as either account, site or script level
    If ($null -eq $site_variable -and $null -eq $script_variable) {
        #If no variable has been passed and this is mandatory, exit
        if ($exit_if_missing) {
            $exitcode = 1
            dRMM-ExitScript -exitcode $exitcode -results $exit_message
        } else {
            #Otherwise throw a warning and carry on
            if (!($null -eq $warning_message)) { Write-output $warning_message}
            
            #Return a default value if set
            If (!($null -eq $default)) { return $default }
        }
    }

    #Check to see if the script level variable is set to 0, indicating that a site/acct level variable should be used
    #but site/account level variable is missing
    If ($script_variable -eq 0 -and $null -eq $site_variable) {
        #If no variable has been passed and this is mandatory, exit
        if ($exit_if_missing) {
            $exitcode = 1
            Exit-dRMMScript -exitcode $exitcode -results $exit_message
        } else {
            #Otherwise throw a warning and carry on
            if (!($null -eq $warning_message)) { Write-output $warning_message}
        }
    }

    #Finally, we should have tested for all other options above. Return script_variable, if set, otherwise
    #return the site/acct variable
    If (!($script_variable -eq 0)) {
        return $script_variable
    } else {
        return $site_variable
    }

} #End function

#Generic function to gracefully exit dRMM PowerShell script
#@param exitcode: mandatory, code to exit with; 0=success, 1=failure
#@param results: string or integer to pass back to dRMM for results of script
#@param diagnostics: additional information to pass back to dRMM for results of script
function Exit-dRMMScript {
    [cmdletbinding()]
    Param([Parameter(Mandatory=$true)]$exitcode, $results, $diagnostics)

    #Output results
    Write-Output "<-Start Result->"
    Write-Output "Result=$results"
    Write-Output "<-End Result->"

    #Output diagnostics, if they exist
    if (!($null -eq $diagnostics)) {
        Write-Output "<-Start Diagnostics->"
        Write-Output "Result=$diagnostics"
        Write-Output "<-End Result->"
    }

    exit $exitcode

} #End function

#Generic function to set dRMM UDF
#@param udf_number: mandatory, UDF number to set
#@param udf_value: mandatory, value to set UDF to
function Set-dRMM-UDF {
    Param([Parameter(Mandatory=$true)]$udf_number, $udf_value)
    REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\CentraStage /v "Custom$udf_number" /t REG_SZ /d "$udf_value" /f
}

#Dump all the environmental variables to stdout, usually only for debugging
if ($env:drmm_dump_env_vars -eq "true") {
    Get-ChildItem variable:$env | ForEach-Object {
        Write-Output $_
    }
}

########################################
##### Begin custom script section ######
########################################

#Check to see if we are in test mode, usually for for local for dev
If (!($env:test -eq "true")) {

    #Get variables
    $max_number = Get-dRMMVariable -site_variable $env:max_random_number -script_variable $env:script_max_random_number -exit_if_missing $true -warning "Max number not set, abandoning script" -default "10"
    $max_number = [int]$max_number + 1 #technically, we don't return this number, ever, so we have to increment it by 1
    Write-Output "Max number is $max_number"
    $udf_number = Get-dRMMVariable -site_variable $env:site_udf_number -script_variable $env:script_udf_number -exit_if_missing $true -warning_message "UDF not set, exiting script"
    Write-Output "UDF_number is $udf_number"

} else {

    #We're in test mode, manually set variables
    $max_number = 4
    $udf_number = 29

}

# Do things
$random_number = Get-Random $max_number
Write-Output "Random number is $random_number"
Set-dRMM-UDF -udf_number $udf_number -udf_value $random_number

#Exit with success, to exit with failure use $exitcode = 1
$exitcode = 0

Exit-dRMMScript -exitcode $exitcode -results "Success!" -diagnostics "We set $udf_number to $random_number"