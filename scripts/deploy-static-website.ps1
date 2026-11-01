
$ErrorActionPreference = "Stop"

# Configuration
$Region = "eu-west-1"
$StackName = "cf-static-website"
$TemplateFile = ".\infra\static-website.yaml"
$WebsiteDirectory = ".\website"

Write-Host "Deploying static website CloudFormation stack..." -ForegroundColor Cyan

# Deploy CloudFormation stack
aws cloudformation deploy `
    --template-file $TemplateFile `
    --stack-name $StackName `
    --region $Region

if ($LASTEXITCODE -ne 0) {
    throw "CloudFormation deployment failed."
}

# Retrieve stack outputs
$Outputs = aws cloudformation describe-stacks `
    --stack-name $StackName `
    --region $Region `
    --query "Stacks[0].Outputs" `
    --output json | ConvertFrom-Json

if ($LASTEXITCODE -ne 0) {
    throw "Unable to retrieve CloudFormation outputs."
}

$Bucket = ($Outputs | Where-Object OutputKey -eq "WebsiteBucketName").OutputValue
$DistributionId = ($Outputs | Where-Object OutputKey -eq "CloudFrontDistributionId").OutputValue
$WebsiteURL = ($Outputs | Where-Object OutputKey -eq "WebsiteURL").OutputValue

if (-not $Bucket -or -not $DistributionId -or -not $WebsiteURL) {
    throw "One or more required CloudFormation outputs are missing."
}

# Upload website files to S3
Write-Host "Uploading website files to S3..." -ForegroundColor Cyan

aws s3 sync $WebsiteDirectory "s3://$Bucket/" --region $Region

if ($LASTEXITCODE -ne 0) {
    throw "S3 upload failed."
}

# Wait for CloudFront distribution deployment
Write-Host "Waiting for CloudFront distribution..." -ForegroundColor Cyan

aws cloudfront wait distribution-deployed `
    --id $DistributionId

if ($LASTEXITCODE -ne 0) {
    throw "CloudFront deployment wait failed."
}

# Invalidate CloudFront cache
Write-Host "Creating CloudFront invalidation..." -ForegroundColor Cyan

aws cloudfront create-invalidation `
    --distribution-id $DistributionId `
    --paths "/*"

if ($LASTEXITCODE -ne 0) {
    throw "CloudFront invalidation failed."
}

Write-Host ""
Write-Host "Static website deployment completed!" -ForegroundColor Green
Write-Host "S3 Bucket: $Bucket"
Write-Host "CloudFront Distribution: $DistributionId"
Write-Host "Website URL: $WebsiteURL"
