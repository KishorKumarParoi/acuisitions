# Acquisitions API - Complete DevOps Setup

A production-ready Node.js Express API with complete DevOps infrastructure including Docker, Kubernetes, Terraform, CI/CD, and comprehensive testing.

## 🚀 Features

### Application
- ✅ Express.js REST API
- ✅ PostgreSQL with Drizzle ORM
- ✅ JWT Authentication with refresh tokens
- ✅ User CRUD operations
- ✅ Role-based access control (RBAC)
- ✅ Input validation with Zod
- ✅ Winston logger
- ✅ Arcjet rate limiting and security

### DevOps & Infrastructure
- ✅ Docker with multi-stage builds
- ✅ Docker Compose for local development
- ✅ Kubernetes manifests (EKS ready)
- ✅ Terraform Infrastructure as Code
- ✅ GitHub Actions CI/CD
- ✅ Prometheus & Grafana monitoring
- ✅ ECR image registry
- ✅ S3 Terraform state management

### Testing & Quality
- ✅ Jest testing framework
- ✅ Supertest for integration tests
- ✅ 70% code coverage threshold
- ✅ ESLint & Prettier
- ✅ Trivy image scanning

## 📋 Prerequisites

- Node.js 22+
- Docker & Docker Compose
- kubectl
- Terraform
- AWS CLI (for cloud deployment)
- Git

## 🏃 Quick Start

### Local Development

1. **Clone and setup**
```bash
git clone https://github.com/KishorKumarParoi/acquisitions.git
cd acquisitions
npm install
```

2. **Configure environment**
```bash
cp .env.example .env
# Edit .env with your values
```

3. **Start with Docker Compose**
```bash
npm run docker:up
```

Services running:
- API: http://localhost:3001
- PostgreSQL: localhost:5432
- Redis: localhost:6379
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000

4. **Run tests**
```bash
npm run test
```

## 🐳 Docker

### Build Image
```bash
make docker-build
# or
docker build -t acquisitions-api:latest .
```

### Run Locally
```bash
make docker-up       # Start all services
make docker-logs     # View logs
make docker-down     # Stop services
```

### Image Details
- Base: Node.js 22 Alpine (lightweight)
- Multi-stage build (optimized size)
- Non-root user (security)
- Health checks included
- Proper signal handling

## ☸️ Kubernetes

### Deploy to EKS

1. **Create cluster** (via Terraform or AWS Console)

2. **Configure kubectl**
```bash
aws eks update-kubeconfig --name acquisitions-prod --region us-east-1
```

3. **Create secrets**
```bash
kubectl create secret generic acquisitions-secrets \
  -n acquisitions \
  --from-literal=DATABASE_URL="postgresql://..." \
  --from-literal=JWT_SECRET="secret-key" \
  --from-literal=ARCJET_KEY="key"
```

4. **Deploy**
```bash
make k8s-deploy
```

5. **Monitor**
```bash
kubectl get pods -n acquisitions
kubectl logs -f deployment/acquisitions-api -n acquisitions
```

### Kubernetes Features
- 3 replicas with pod anti-affinity
- Rolling updates (1 surge, 0 unavailable)
- Resource limits and requests
- Liveness and readiness probes
- ConfigMap for configuration
- Secrets for sensitive data

## 🏗️ Infrastructure as Code (Terraform)

### Initialize
```bash
make tf-init
```

Creates:
- AWS EKS cluster
- VPC with public/private subnets
- NAT Gateway for private subnets
- Internet Gateway
- Security groups
- ECR repository
- IAM roles and policies

### Plan Changes
```bash
make tf-plan
```

### Apply Infrastructure
```bash
make tf-apply
```

### Outputs
```bash
cd terraform
terraform output configure_kubectl
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflows

#### CI Pipeline (on push/PR)
1. ESLint validation
2. Jest tests + coverage
3. Docker build and push
4. Trivy security scan

#### CD Pipeline (on version tag)
1. Deploy to Kubernetes
2. Run smoke tests
3. Apply Terraform changes

**Deploy Steps**

1. Create and push a version tag:
```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

## 🧪 Testing

### Run Tests
```bash
make test              # Run all tests
make test-watch       # Watch mode
make test-coverage    # Coverage report
```

### Test Coverage
- Threshold: 70%
- Test files: `src/__tests__/**/*.test.js`

View coverage report:
```bash
npm run test:coverage
open coverage/lcov-report/index.html
```

## 📊 Monitoring

### Prometheus
- URL: http://localhost:9090
- Scrapes metrics every 15 seconds

### Grafana
- URL: http://localhost:3000
- Default: admin / admin

## 📦 Available Commands

```bash
# Development
npm run dev              # Start dev server
npm start               # Start production server

# Testing
npm test                # Run tests
npm run test:watch     # Watch mode
npm run test:coverage  # Coverage report

# Linting & Formatting
npm run lint           # Run ESLint
npm run lint:fix       # Fix issues
npm run format         # Format with Prettier

# Docker
npm run docker:build   # Build image
npm run docker:up      # Start compose
npm run docker:down    # Stop compose

# Kubernetes
npm run k8s:deploy     # Deploy
npm run k8s:delete     # Delete

# Terraform
npm run tf:init        # Initialize
npm run tf:plan        # Plan changes
npm run tf:apply       # Apply changes
```

Or use Makefile:
```bash
make help              # Show all commands
```

## 📜 Documentation

See [DEVOPS.md](./DEVOPS.md) for detailed DevOps documentation.

## 📜 License

ISC License

## 👨‍💻 Author

**Kishor Kumar Paroi**
- GitHub: [@KishorKumarParoi](https://github.com/KishorKumarParoi)

---

**Version**: 1.0.0
