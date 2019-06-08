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

  name   = "ulikamodule"
  region = "us-east-1"
  script = "test.ps1"
  owner  = "ulikabbq"
  repo   = "pwsh-lambda"
  branch = "master"
}

output "dns_name" {
    value = "${module.lambda_pwsh.alb_dns}"
}
```

take the output dns name and paste it in your browser of choice. this will execute the test lambda function. you can also look at the logs in cloudwatch. 