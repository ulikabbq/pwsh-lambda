# pwsh lambda terraform module
This is a module to build a pwsh lambda function with an aws codepipeline/codebuild project and a load balancer to execute the lambda. 

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
```
