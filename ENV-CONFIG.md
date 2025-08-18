# VProfile Environment Configuration

This document explains how to configure the VProfile application using environment variables for Docker and Kubernetes deployments.

## Environment Variables

The application now supports the following environment variables:

### Database Configuration
- `DB_HOST` - Database host (default: vprodb)
- `DB_PORT` - Database port (default: 3306)
- `DB_NAME` - Database name (default: accounts)
- `DB_USERNAME` - Database username (default: root)
- `DB_PASSWORD` - Database password (default: vprodbpass)

### Memcached Configuration
- `MEMCACHED_ACTIVE_HOST` - Active Memcached host (default: vprocache01)
- `MEMCACHED_ACTIVE_PORT` - Active Memcached port (default: 11211)
- `MEMCACHED_STANDBY_HOST` - Standby Memcached host (default: 127.0.0.2)
- `MEMCACHED_STANDBY_PORT` - Standby Memcached port (default: 11211)

### RabbitMQ Configuration
- `RABBITMQ_HOST` - RabbitMQ host (default: vpromq01)
- `RABBITMQ_PORT` - RabbitMQ port (default: 5672)
- `RABBITMQ_USERNAME` - RabbitMQ username (default: guest)
- `RABBITMQ_PASSWORD` - RabbitMQ password (default: guest)

### Elasticsearch Configuration
- `ELASTICSEARCH_HOST` - Elasticsearch host (default: localhost)
- `ELASTICSEARCH_PORT` - Elasticsearch port (default: 9300)
- `ELASTICSEARCH_CLUSTER` - Elasticsearch cluster name (default: vprofile)
- `ELASTICSEARCH_NODE` - Elasticsearch node name (default: vprofilenode)

### Spring Security Configuration
- `SPRING_SECURITY_USER_NAME` - Admin username (default: admin_vp)
- `SPRING_SECURITY_USER_PASSWORD` - Admin password (default: admin_vp)
- `SPRING_SECURITY_USER_ROLES` - Admin roles (default: ADMIN)

### Application Configuration
- `MAX_FILE_SIZE` - Maximum file upload size (default: 128KB)
- `MAX_REQUEST_SIZE` - Maximum request size (default: 128KB)
- `LOGGING_LEVEL_SECURITY` - Security logging level (default: DEBUG)
- `LOGGING_LEVEL_HIBERNATE` - Hibernate logging level (default: OFF)
- `SHOW_SQL` - Show SQL queries (default: false)
- `FORMAT_SQL` - Format SQL queries (default: false)

## Docker Deployment

### Using .env file
1. Copy the `.env` file to your project root
2. Modify the values as needed
3. Run: `docker-compose up -d`

### Using environment variables directly
```bash
docker-compose up -d \
  -e DB_PASSWORD=mysecretpassword \
  -e RABBITMQ_PASSWORD=myrabbitmqpassword
```

### Override specific services
```bash
# Override database password only
DB_PASSWORD=newsecretpass docker-compose up -d vprodb

# Override multiple variables
DB_PASSWORD=newdbpass RABBITMQ_PASSWORD=newmqpass docker-compose up -d
```

## Kubernetes Deployment

### 1. Deploy Secrets and ConfigMap
```bash
kubectl apply -f k8s/secrets-configmap.yaml
```

### 2. Deploy Supporting Services
```bash
kubectl apply -f k8s/supporting-services.yaml
```

### 3. Deploy Application
```bash
kubectl apply -f k8s/vprofile-app-deployment.yaml
```

### Managing Secrets

#### Creating Custom Secrets
```bash
# Create database secret
kubectl create secret generic db-credentials \
  --from-literal=username=myuser \
  --from-literal=password=mypassword

# Create RabbitMQ secret
kubectl create secret generic rabbitmq-credentials \
  --from-literal=username=myrabbituser \
  --from-literal=password=myrabbitpass
```

#### Updating Secrets
```bash
# Update existing secret
kubectl patch secret vprofile-secrets -p='{"data":{"db-password":"bmV3cGFzc3dvcmQ="}}'

# Or delete and recreate
kubectl delete secret vprofile-secrets
kubectl apply -f k8s/secrets-configmap.yaml
```

#### Using External Secret Management
For production environments, consider using:
- **AWS Secrets Manager** with External Secrets Operator
- **HashiCorp Vault** with Vault Agent
- **Azure Key Vault** with Secret Store CSI Driver
- **Google Secret Manager** with Secret Manager CSI Driver

### Example External Secrets Configuration (AWS)
```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secrets-manager
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets-sa
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: vprofile-db-secret
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
    kind: SecretStore
  target:
    name: vprofile-secrets
    creationPolicy: Owner
  data:
  - secretKey: db-password
    remoteRef:
      key: vprofile/database
      property: password
```

## Security Best Practices

### 1. Secrets Management
- Never commit secrets to version control
- Use different credentials for different environments
- Rotate credentials regularly
- Use strong, unique passwords

### 2. Environment-Specific Configuration
```bash
# Development
DB_PASSWORD=devpassword

# Staging
DB_PASSWORD=stagingpassword

# Production
DB_PASSWORD=complexproductionpassword
```

### 3. RBAC for Kubernetes Secrets
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-secrets
subjects:
- kind: ServiceAccount
  name: vprofile-app
  namespace: default
roleRef:
  kind: Role
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

## Monitoring and Troubleshooting

### Check Environment Variables in Running Container
```bash
# Docker
docker exec -it vproapp env | grep -E "(DB_|RABBITMQ_|MEMCACHED_)"

# Kubernetes
kubectl exec -it deployment/vprofile-app -- env | grep -E "(DB_|RABBITMQ_|MEMCACHED_)"
```

### Verify Secret Values
```bash
# Kubernetes - decode secret values
kubectl get secret vprofile-secrets -o jsonpath='{.data.db-password}' | base64 -d
```

### Common Issues
1. **Base64 encoding issues**: Ensure no trailing newlines when encoding secrets
2. **Environment variable precedence**: Docker Compose `.env` < `environment` section < command line `-e`
3. **Kubernetes secret updates**: Pods need restart to pick up updated secrets
4. **Connection failures**: Verify service names match environment variables

## Migration Guide

### From Hardcoded to Environment Variables
1. **Backup your current configuration**
2. **Update application.properties** with environment variable placeholders
3. **Test with Docker Compose** using the provided `.env` file
4. **Deploy to Kubernetes** using the provided manifests
5. **Verify all services** are connecting properly

### Rollback Plan
If issues occur, you can quickly revert by:
1. Restoring the original `application.properties`
2. Using the original `docker-compose.yml`
3. Rolling back Kubernetes deployments: `kubectl rollout undo deployment/vprofile-app`
