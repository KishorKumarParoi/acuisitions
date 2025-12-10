# DevOps Documentation

## Project Structure

```
acquisitions/
├── .github/workflows/          # GitHub Actions CI/CD workflows
│   ├── ci.yml                 # Testing and building
│   └── cd.yml                 # Deployment pipeline
├── k8s/                       # Kubernetes manifests
│   ├── deployment.yaml        # App deployment
│   ├── service.yaml          # Service configuration
│   ├── configmap.yaml        # Environment configuration
│   ├── namespace.yaml        # Kubernetes namespace
│   ├── serviceaccount.yaml   # Service account
│   └── ingress.yaml          # Ingress configuration
├── terraform/                # Infrastructure as Code
│   ├── main.tf              # EKS cluster, VPC, networking
│   ├── variables.tf         # Terraform variables
│   └── outputs.tf           # Terraform outputs
├── src/                      # Application source code
│   └── __tests__/           # Jest test files
├── Dockerfile               # Multi-stage Docker build
├── docker-compose.yml       # Local development environment
├── prometheus.yml           # Prometheus configuration
├── jest.config.js          # Jest testing configuration
├── jest.setup.js           # Jest setup file
└── package.json            # Dependencies and scripts
```

## Getting Started

### Prerequisites

- Docker & Docker Compose
- Node.js 22+
- kubectl
- Terraform
- AWS CLI
- Git

### Local Development Setup

1. **Clone the repository**
```bash
git clone https://github.com/KishorKumarParoi/acquisitions.git
cd acquisitions
```

2. **Install dependencies**
```bash
npm install
```

3. **Setup environment variables**
```bash
cp .env.example .env
# Edit .env with your values
```

4. **Start with Docker Compose**
```bash
npm run docker:up
```

This will start:
- API on http://localhost:3001
- PostgreSQL on localhost:5432
- Redis on localhost:6379
- Prometheus on http://localhost:9090
- Grafana on http://localhost:3000

5. **Run tests**
```bash
npm run test
npm run test:watch      # Watch mode
npm run test:coverage   # Coverage report
```

6. **Development server**
```bash
npm run dev
```

## Docker

### Build Image
```bash
npm run docker:build
# or
docker build -t acquisitions-api:latest .
```

### Run Container
```bash
docker run -p 3001:3001 acquisitions-api:latest
```

### Docker Compose
```bash
# Start all services
npm run docker:up

# View logs
npm run docker:logs

# Stop all services
npm run docker:down
```

## Kubernetes

### Prerequisites

- EKS cluster running
- kubectl configured
- Docker image pushed to ECR

### Create Kubernetes Resources

1. **Create namespace**
```bash
kubectl apply -f k8s/namespace.yaml
```

2. **Create secrets**
```bash
kubectl create secret generic acquisitions-secrets \
  -n acquisitions \
  --from-literal=DATABASE_URL="postgresql://..." \
  --from-literal=JWT_SECRET="your-secret" \
  --from-literal=ARCJET_KEY="your-key"
```

3. **Deploy application**
```bash
npm run k8s:deploy
# or
kubectl apply -f k8s/
```

4. **Check deployment status**
```bash
kubectl rollout status deployment/acquisitions-api -n acquisitions
```

5. **View logs**
```bash
npm run k8s:logs
# or
kubectl logs -f deployment/acquisitions-api -n acquisitions
```

### Scale Replicas
```bash
kubectl scale deployment acquisitions-api --replicas=5 -n acquisitions
```

### Delete Deployment
```bash
npm run k8s:delete
```

## Terraform

### Prerequisites

- AWS credentials configured
- S3 bucket for Terraform state
- DynamoDB table for state locking

### Initialize

```bash
npm run tf:init
```

### Plan Infrastructure

```bash
npm run tf:plan
```

### Apply Infrastructure

```bash
npm run tf:apply
```

### Outputs

After applying, get cluster information:
```bash
cd terraform
terraform output configure_kubectl
```

Use the output to configure kubectl:
```bash
aws eks update-kubeconfig --region us-east-1 --name acquisitions-prod
```

### Destroy Infrastructure

```bash
npm run tf:destroy
```

## CI/CD Pipeline

### GitHub Actions Workflows

#### CI Workflow (.github/workflows/ci.yml)
Triggered on push/PR to main or develop:
1. Runs linter (ESLint)
2. Runs tests with coverage
3. Builds and pushes Docker image
4. Scans image with Trivy
5. Uploads coverage to Codecov

#### CD Workflow (.github/workflows/cd.yml)
Triggered on version tags (v*):
1. Deploys to Kubernetes
2. Runs smoke tests
3. Applies Terraform changes

### Secrets Required in GitHub

Set these in repository settings:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Testing

### Jest Configuration

- Test environment: Node.js
- Test files: `src/**/__tests__/**/*.test.js`
- Coverage threshold: 70%
- Test timeout: 10 seconds

### Run Tests

```bash
npm run test              # Run all tests
npm run test:watch      # Watch mode
npm run test:coverage   # Generate coverage
npm run test:ci         # CI mode
```

### Test Files

- `src/__tests__/auth.test.js` - Authentication tests
- `src/__tests__/users.test.js` - User CRUD tests

### Coverage Report

```bash
npm run test:coverage
open coverage/lcov-report/index.html
```

## Monitoring

### Prometheus

- URL: http://localhost:9090
- Scrapes metrics every 15 seconds
- Data stored in `prometheus_data` volume

### Grafana

- URL: http://localhost:3000
- Default credentials: admin/admin
- Add Prometheus data source
- Import dashboards

### Application Metrics

Add metrics endpoints to your app:
```javascript
import prometheus from 'prom-client';

app.get('/metrics', (req, res) => {
  res.set('Content-Type', prometheus.register.contentType);
  res.end(prometheus.register.metrics());
});
```

## Logging

### Winston Logger

Logs are stored in `logs/` directory:
- `logs/error.log` - Error logs only
- `logs/combined.log` - All logs

### Log Levels

- error
- warn
- info
- http
- debug

Change log level via environment variable:
```
LOG_LEVEL=debug
```

## Environment Variables

See `.env.example` for all available variables.

### Critical Variables

- `DATABASE_URL` - PostgreSQL connection string
- `JWT_SECRET` - JWT signing secret (change in production!)
- `ARCJET_KEY` - Rate limiting and security

## Production Checklist

- [ ] Update JWT_SECRET to secure random value
- [ ] Configure DATABASE_URL to production database
- [ ] Set NODE_ENV=production
- [ ] Enable HTTPS/TLS
- [ ] Setup CloudFlare or CDN
- [ ] Configure DNS
- [ ] Setup monitoring and alerting
- [ ] Enable database backups
- [ ] Configure log aggregation
- [ ] Setup rate limiting
- [ ] Enable CORS for allowed origins
- [ ] Implement API versioning
- [ ] Setup automated testing
- [ ] Configure auto-scaling policies

## Troubleshooting

### Docker Issues

```bash
# Remove all containers and volumes
docker-compose down -v

# Rebuild from scratch
docker-compose up --build
```

### Kubernetes Issues

```bash
# Check pod status
kubectl get pods -n acquisitions

# Describe pod for errors
kubectl describe pod <pod-name> -n acquisitions

# Delete and recreate deployment
kubectl delete deployment acquisitions-api -n acquisitions
kubectl apply -f k8s/deployment.yaml
```

### Database Connection Issues

```bash
# Test PostgreSQL connection
psql $DATABASE_URL -c "SELECT 1"

# Check database migrations
npm run db:migrate
```

### Test Failures

```bash
# Run specific test file
npm test -- auth.test.js

# Run tests with debug output
DEBUG=* npm test

# Update snapshots
npm test -- -u
```

## Performance Optimization

1. **Node Caching**: Implement Redis caching
2. **Database Indexing**: Add proper indexes
3. **API Rate Limiting**: Use Arcjet
4. **Image Optimization**: Use Docker multi-stage builds
5. **Horizontal Scaling**: Configure K8s autoscaling
6. **Load Balancing**: Use K8s load balancer

## Security Hardening

1. **Network Policies**: Configure Kubernetes network policies
2. **RBAC**: Implement role-based access control
3. **Secret Management**: Use AWS Secrets Manager
4. **Image Scanning**: Enable Trivy scanning
5. **OWASP**: Follow OWASP security guidelines
6. **Helmet**: Enable security headers
7. **Input Validation**: Validate all inputs with Zod

## Support

For issues and questions:
- GitHub Issues: [Repository Issues](https://github.com/KishorKumarParoi/acquisitions/issues)
- Email: support@acquisitions.com
