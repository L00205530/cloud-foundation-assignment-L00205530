
$ErrorActionPreference = "Stop"

# Configuration
$Region = "eu-west-1"

$Stacks = @(
    "cf-static-website",
    "cf-three-tier"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " CloudFormation Assignment Cleanup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "The following AWS stacks will be deleted:"
foreach ($Stack in $Stacks) {
    Write-Host " - $Stack" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "WARNING: This operation is destructive." -ForegroundColor Red

$Confirmation = Read-Host "Type DELETE to continue"

if ($Confirmation -ne "DELETE") {
    Write-Host "Cleanup cancelled." -ForegroundColor Yellow
    exit 0
}

# Check AWS credentials
Write-Host "`nChecking AWS credentials..." -ForegroundColor Cyan

aws sts get-caller-identity --region $Region

if ($LASTEXITCODE -ne 0) {
    throw "AWS authentication failed. Cleanup cannot continue."
}

# Process each CloudFormation stack
foreach ($Stack in $Stacks) {

    Write-Host "`nProcessing stack: $Stack" -ForegroundColor Cyan

    # Check whether the stack exists
    $StackInfo = aws cloudformation describe-stacks `
        --stack-name $Stack `
        --region $Region `
        --output json 2>$null

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Stack $Stack does not exist or is not accessible. Skipping." -ForegroundColor Yellow
        continue
    }

    $StackData = $StackInfo | ConvertFrom-Json

    # Empty the static website S3 bucket before deleting its stack
    if ($Stack -eq "cf-static-website") {

        $Bucket = ($StackData.Stacks[0].Outputs |
            Where-Object { $_.OutputKey -eq "WebsiteBucketName" }).OutputValue

        if ($Bucket) {
            Write-Host "Emptying S3 bucket: $Bucket" -ForegroundColor Cyan

            aws s3 rm "s3://$Bucket" `
                --recursive `
                --region $Region

            if ($LASTEXITCODE -ne 0) {
                throw "Failed to empty S3 bucket $Bucket. Stack deletion stopped."
            }
        }
    }

    # Request CloudFormation stack deletion
    Write-Host "Deleting CloudFormation stack: $Stack" -ForegroundColor Yellow

    aws cloudformation delete-stack `
        --stack-name $Stack `
        --region $Region

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to request deletion of stack $Stack."
    }

    # Wait until deletion completes
    Write-Host "Waiting for stack deletion..." -ForegroundColor Cyan

    aws cloudformation wait stack-delete-complete `
        --stack-name $Stack `
        --region $Region

    if ($LASTEXITCODE -ne 0) {
        throw "Stack deletion did not complete successfully: $Stack"
    }

    Write-Host "Stack $Stack deleted successfully." -ForegroundColor Green
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host " Cleanup process completed." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
