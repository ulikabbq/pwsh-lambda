param (
    [Parameter(Mandatory = $True)]
    [string]$script,
    [Parameter(Mandatory = $True)]
    [string]$function_name,
    [Parameter(Mandatory = $True)]
    [string]$iam_role,    
    [Parameter(Mandatory = $True)]
    [string]$region

)

Install-Module -Name AWSPowerShell.NetCore -AllowClobber -Force
Install-Module AWSLambdaPSCore -Scope CurrentUser -force

Import-Module AWSPowershell.NetCore
$src_dir = (get-item env:CODEBUILD_SRC_DIR).Value

Publish-AWSPowerShellLambda -ScriptPath $src_dir\$script -Name $function_name -IAMRoleArn $iam_role -Region $region
