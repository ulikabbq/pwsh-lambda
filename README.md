# pwsh lambda terraform module
This is a module to build a pwsh lambda function with an aws codepipeline/codebuild project and a load balancer to execute the lambda.

This is meant to be an example to get you started. Based on your script, you may need different IAM permissions and you probably do not want a load balancer per lambda function. 

## prerequisite 
This module is configured to work with a github repository and therefore a github token is required as an environment variable. https://www.terraform.io/docs/providers/aws/r/codepipeline.html

### mac 
`export GITHUB_TOKEN=xyz`

### windows 
`$env:GITHUB_TOKEN="xyz"`

## example usage of the module 
```
module "lambda_pwsh" {
  source = "git@github.com:ulikabbq/pwsh-lambda.git?ref=master//tf"

  name   = "ulikamodule" // a unique name for the lambda function
  region = "us-east-1"   // region for the lambda 
  script = "test.ps1"    // name of the pwsh script to turn into a lambda function 
  owner  = "ulikabbq"    // owner/username for the github account that is associated with the token used 
  repo   = "pwsh-lambda" // name of the github repo 
  branch = "master"      // name of the branch used for the codepipeline 
}

output "dns_name" {
    value = "${module.lambda_pwsh.alb_dns}"
}
```

Take the output dns name and paste it in your browser of choice. this will execute the test lambda function, now add `/test`. You can also look at the logs in cloudwatch to troubleshoot any execution issues. Use `write-host` inside your script for logging to cloudwatch. 