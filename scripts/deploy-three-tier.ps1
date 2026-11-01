
$ErrorActionPreference = "Stop"

# Configuration
$Region = "eu-west-1"
$StackName = "cf-three-tier"
$TemplateFile = ".\infra\three-tier.yaml"

Write-Host "Deploying three-tier CloudFormation architecture..." -ForegroundColor Cyan

# Deploy CloudFormation stack
aws cloudformation deploy `
    --template-file $TemplateFile `
    --stack-name $StackName `
    --region $Region

if ($LASTEXITCODE -ne 0) {
    throw "CloudFormation deployment failed."
}

Write-Host "CloudFormation deployment completed." -ForegroundColor Green

# Retrieve stack outputs
$Outputs = aws cloudformation describe-stacks `
    --stack-name $StackName `
    --region $Region `
    --query "Stacks[0].Outputs" `
    --output json | ConvertFrom-Json

if ($LASTEXITCODE -ne 0) {
    throw "Unable to retrieve CloudFormation outputs."
}

# Display deployment information
Write-Host "`nThree-tier architecture outputs:" -ForegroundColor Cyan

foreach ($Output in $Outputs) {
    Write-Host "$($Output.OutputKey): $($Output.OutputValue)"
}
