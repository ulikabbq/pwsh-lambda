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

$querystring = $input_object.queryStringParameters

write-host "this is the querystring: $querystring"

if ($querystring.recycle -ne $null) {
    write-host "this is a recycle operation"
    $value = $querystring.recycle
    write-host "this is the value $value"
}

if ($querystring.test -ne $null) {
    write-host "this is a test operation"
    $value = $querystring.test
    write-host "this is the value $value"
}

@{
    'statusCode' = 200;
    'body' = $input_object;
    'headers' = @{'Content-Type' = 'application/json'}
}

