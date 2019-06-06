# PowerShell script file to be executed as a AWS Lambda function.
#
# When executing in Lambda the following variables will be predefined.
#   $LambdaInput - A PSObject that contains the Lambda function input data.
#   $LambdaContext - An Amazon.Lambda.Core.ILambdaContext object that contains information about the currently running Lambda environment.
#
# The last item in the PowerShell pipeline will be returned as the result of the Lambda function.
#
# To include PowerShell modules with your Lambda function, like the AWSPowerShell.NetCore module, add a "#Requires" statement
# indicating the module and version.

#Requires -Modules @{ModuleName='AWSPowerShell.NetCore';ModuleVersion='3.3.509.0'}

# Uncomment to send the input event to CloudWatch Logs
Write-Host (ConvertTo-Json -InputObject $LambdaInput -Compress -Depth 5)

$info = (ConvertTo-Json -InputObject $LambdaInput -Compress -Depth 5)

write-host "this is the info: $info" 

$input_object = $info | convertfrom-json
write-host "this is the input object: $input_object"

$path = $input_object.path -split "/"

$task = $path[2]
$item = $path[3]

write-host "this is the task: $task and this is the item: $item"

#if there is no task defined just exit 
if ($task -eq $null) {
@{
    'statusCode' = 200;
    'body' = 'exit';
    'headers' = @{'Content-Type' = 'text/plain'}
}
exit}

if ($task -eq 'recycle') {
    write-host "this is a recycle operation"
    $value = $item
    write-host "this is the value $value"
    $message = "recycled $item"
}

if ($task -eq 'env') {
    write-host "this is a env operation"
    $env_file = Read-S3Object -BucketName rmarlow -Key environment.config -File /tmp/environment.config
    Read-S3Object -BucketName rmarlow -Key environment.config -File /tmp/environment.config

    [xml]$input_path = gc "/tmp/environment.config" 
    $buildversion = $input_path.configuration.appSettings.add | Where-Object {$_.key -eq "BuildVersion"}
    [int]$num = $buildversion.value
    $num++
    $buildversion.Value = "$num"
    $input_path.Save("/tmp/environment.config")

    Write-S3Object -BucketName rmarlow -Key environment.config -File /tmp/environment.config

    $message = "ran the environment config"
}

@{
    'statusCode' = 200;
    'body' = "$message";
    'headers' = @{'Content-Type' = 'text/plain'}
}

