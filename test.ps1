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

$query = $LambdaInput.multiValueQueryStringParameters.test

write-host "this is the info detail: $query" 

$result = [PSCustomObject]@{
    test = 'test'
    CharLength = '123'
} | ConvertTo-Json

write-host "this is the result: $result" 

@{
    'statusCode' = 200;
    'body' = $query;
    'headers' = @{'Content-Type' = 'application/json'}
}

