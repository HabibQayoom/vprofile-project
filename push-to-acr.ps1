# Azure Container Registry Push Script (No CLI Required)
# Replace these with your actual ACR details

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Building and Pushing to Azure Container Registry" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Your ACR details (UPDATE THESE!)
$registryLoginServer = "vprofileacr.azurecr.io"  # Replace with your ACR login server
$registryUsername = "vprofileacr"                 # Replace with your ACR username
$registryPassword = "YOUR_ACR_PASSWORD"           # Replace with your ACR password

Write-Host "[INFO] Logging into ACR using Docker..." -ForegroundColor Green
docker login $registryLoginServer -u $registryUsername -p $registryPassword

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to login to ACR" -ForegroundColor Red
    exit 1
}

Write-Host "[INFO] Building VProfile Database image..." -ForegroundColor Green
docker build -t "$registryLoginServer/vprofiledb:latest" -f Docker-files/db/Dockerfile Docker-files/db/

Write-Host "[INFO] Building VProfile Application image..." -ForegroundColor Green
docker build -t "$registryLoginServer/vprofileapp:latest" -f Docker-files/app/Dockerfile.multistage .

Write-Host "[INFO] Building VProfile Web image..." -ForegroundColor Green
docker build -t "$registryLoginServer/vprofileweb:latest" -f Docker-files/web/Dockerfile Docker-files/web/

Write-Host "[INFO] Pushing Database image..." -ForegroundColor Green
docker push "$registryLoginServer/vprofiledb:latest"

Write-Host "[INFO] Pushing Application image..." -ForegroundColor Green
docker push "$registryLoginServer/vprofileapp:latest"

Write-Host "[INFO] Pushing Web image..." -ForegroundColor Green
docker push "$registryLoginServer/vprofileweb:latest"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "All images pushed successfully!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Images available at:" -ForegroundColor Yellow
Write-Host "  - $registryLoginServer/vprofiledb:latest" -ForegroundColor White
Write-Host "  - $registryLoginServer/vprofileapp:latest" -ForegroundColor White
Write-Host "  - $registryLoginServer/vprofileweb:latest" -ForegroundColor White
Write-Host ""
Write-Host "Next: Create Container Groups in Azure Portal" -ForegroundColor Green
