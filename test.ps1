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
}

if ($task -eq 'test') {
    write-host "this is a test operation"
    $path = pwd
    $s = Read-S3Object -BucketName rmarlow -Key environment.config -File $path/environment.config
    write-host "$s"
    write-host "this is the value $path"
    Read-S3Object -BucketName rmarlow -Key environment.config -File $path/environment.config
    $t = ls 
    write-host "$t" 

    [xml]$input_path = gc "$path/environment.config" 

    $buildversion = $input_path.configuration.appSettings.add | Where-Object {$_.key -eq "BuildVersion"}

    [int]$num = $buildversion.value

    $num++

    $buildversion.Value = "$num"

    $input_path.Save("$path/environment.config")

    Write-S3Object -BucketName rmarlow -Key environment.config -File $path/environment.config


}

@{
    'statusCode' = 200;
    'body' = "executing $task on $item";
    'headers' = @{'Content-Type' = 'text/plain'}
}

