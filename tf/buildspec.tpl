version: 0.2

phases:
  build:
    commands:
      - pwsh -c ./publish_lambda.ps1 -script ${script} -function_name ${name} -iam_role ${iam_role} -region ${region}