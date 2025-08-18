# Build and Push to Azure Container Registry
# Usage: .\build-and-push-acr.ps1 -AcrName "your-acr-name"

param(
    [Parameter(Mandatory=$true)]
    [string]$AcrName
)

$LoginServer = "${AcrName}.azurecr.io"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Building and Pushing VProfile Images to ACR" -ForegroundColor Cyan
Write-Host "ACR Login Server: $LoginServer" -ForegroundColor Yellow
Write-Host "===============================================" -ForegroundColor Cyan

# Login to ACR (already logged in)
Write-Host "[INFO] Using existing ACR login..." -ForegroundColor Green

Write-Host "[INFO] Building and tagging VProfile Database image..." -ForegroundColor Green
docker build -t vprofiledb:clean -f Docker-files/db/Dockerfile Docker-files/db/
docker tag vprofiledb:clean "${LoginServer}/vprofiledb:latest"

Write-Host "[INFO] Building and tagging VProfile Application image..." -ForegroundColor Green
docker build -t vprofileapp:clean -f Docker-files/app/Dockerfile.multistage .
docker tag vprofileapp:clean "${LoginServer}/vprofileapp:latest"

Write-Host "[INFO] Building and tagging VProfile Web image..." -ForegroundColor Green
docker build -t vprofileweb:clean -f Docker-files/web/Dockerfile Docker-files/web/
docker tag vprofileweb:clean "${LoginServer}/vprofileweb:latest"

Write-Host "[INFO] Pushing images to Azure Container Registry..." -ForegroundColor Green
Write-Host "Pushing Database image..." -ForegroundColor Yellow
docker push "${LoginServer}/vprofiledb:latest"

Write-Host "Pushing Application image..." -ForegroundColor Yellow
docker push "${LoginServer}/vprofileapp:latest"

Write-Host "Pushing Web image..." -ForegroundColor Yellow
docker push "${LoginServer}/vprofileweb:latest"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Push Complete!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Images pushed to ACR:" -ForegroundColor Yellow
Write-Host "  - ${LoginServer}/vprofiledb:latest" -ForegroundColor White
Write-Host "  - ${LoginServer}/vprofileapp:latest" -ForegroundColor White
Write-Host "  - ${LoginServer}/vprofileweb:latest" -ForegroundColor White

Write-Host ""
Write-Host "Next: Create Container Instances in Azure Portal using these images!" -ForegroundColor Green
