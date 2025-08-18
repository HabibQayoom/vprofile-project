# 🚀 VProfile - Zero Installation Deployment

## No Maven, No Java, No Problem! 

Just Docker Desktop is all you need.

## 🎯 One-Command Deployment

```powershell
.\deploy.ps1
```

That's it! This script will:
1. ✅ Build the Java application using Docker
2. ✅ Create all Docker images  
3. ✅ Start all services with health checks
4. ✅ Wait for everything to be ready
5. ✅ Show you the URLs to access

## 🌐 Application URLs

After deployment completes:

- **Main Application**: http://localhost
- **Direct Tomcat**: http://localhost:8080  
- **RabbitMQ Management**: http://localhost:15672

## 🔐 Default Credentials

- **Application Login**: admin_vp / admin_vp
- **RabbitMQ**: guest / guest

## 🛠️ Alternative Methods

### Method 1: Build First, Then Run
```powershell
# Build using Maven in Docker
.\docker-build.ps1

# Then start services
docker-compose up -d
```

### Method 2: Multi-stage Build
```powershell
# Build and run with multi-stage Dockerfile
docker-compose -f docker-compose.build.yml up -d --build
```

### Method 3: Manual Maven in Docker
```powershell
# Build WAR file using Maven Docker container
docker run --rm -v "${PWD}:/usr/src/app" -v "${env:USERPROFILE}\.m2:/root/.m2" -w /usr/src/app maven:latest mvn clean package -DskipTests

# Then run normally
docker-compose up -d
```

## 📋 Useful Commands

```powershell
# Check running containers
docker ps

# View logs
docker-compose logs vproapp

# Stop everything
docker-compose down

# Remove everything including data
docker-compose down -v

# Check application logs
docker logs vproapp
```

## 🐛 Troubleshooting

If something goes wrong:

1. **Check Docker is running**: Make sure Docker Desktop is started
2. **Check logs**: `docker-compose logs [service-name]`
3. **Free up ports**: Make sure ports 80, 3306, 5672, 8080, 11211 are free
4. **Restart**: `docker-compose down && docker-compose up -d`

## 🏗️ What's Happening Behind the Scenes

The deployment:
1. Uses Maven Docker image to build your Java application
2. Creates a MySQL database with pre-loaded data
3. Sets up Memcached for caching
4. Configures RabbitMQ for messaging
5. Deploys your app in Tomcat
6. Sets up Nginx as reverse proxy

All without installing anything locally except Docker! 🎉
