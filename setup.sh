#!/bin/bash

# Acquisitions API - Complete Setup Script
# This script sets up the entire DevOps ecosystem

set -e

echo "================================================"
echo "  Acquisitions API - DevOps Setup Script"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"

check_command() {
  if ! command -v $1 &> /dev/null; then
    echo -e "${YELLOW}⚠️  $1 is not installed${NC}"
    return 1
  fi
  echo -e "${GREEN}✓ $1${NC}"
  return 0
}

echo "Required tools:"
check_command "node" || echo "Install Node.js 22+"
check_command "npm" || echo "Install npm"
check_command "docker" || echo "Install Docker"
check_command "docker-compose" || echo "Install Docker Compose"

echo ""
echo "Optional for cloud deployment:"
check_command "kubectl" || echo "Install kubectl"
check_command "terraform" || echo "Install Terraform"
check_command "aws" || echo "Install AWS CLI"

echo ""
echo -e "${BLUE}Installing dependencies...${NC}"
npm install

echo ""
echo -e "${BLUE}Setting up environment...${NC}"

if [ ! -f .env ]; then
  cp .env.example .env
  echo -e "${GREEN}✓ Created .env file${NC}"
  echo -e "${YELLOW}  Please edit .env with your configuration${NC}"
else
  echo -e "${GREEN}✓ .env file already exists${NC}"
fi

if [ ! -f .env.test ]; then
  cat > .env.test << 'EOF'
NODE_ENV=test
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/acquisitions_test
JWT_SECRET=test-secret-key
LOG_LEVEL=error
EOF
  echo -e "${GREEN}✓ Created .env.test file${NC}"
else
  echo -e "${GREEN}✓ .env.test file already exists${NC}"
fi

echo ""
echo -e "${BLUE}Linting and formatting code...${NC}"
npm run lint:fix || true
npm run format || true

echo ""
echo -e "${BLUE}Running tests...${NC}"
npm run test || true

echo ""
echo -e "${BLUE}Building Docker image...${NC}"
npm run docker:build

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  Setup Complete! 🎉${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

echo "Next steps:"
echo ""
echo "1. Start development environment:"
echo "   npm run docker:up"
echo ""
echo "2. Run application:"
echo "   npm run dev"
echo ""
echo "3. View logs:"
echo "   npm run docker:logs"
echo ""
echo "4. Run tests:"
echo "   npm run test"
echo ""
echo "5. For Kubernetes deployment:"
echo "   make tf-init      # Setup Terraform"
echo "   make tf-apply     # Create AWS resources"
echo "   make k8s-deploy   # Deploy to Kubernetes"
echo ""
echo "📚 Documentation:"
echo "   - README.md   - Project overview"
echo "   - DEVOPS.md   - Detailed DevOps guide"
echo ""
echo "⚙️  Configuration:"
echo "   - Edit .env with your settings"
echo "   - Change JWT_SECRET for production!"
echo "   - Set up your database connection"
echo ""
echo "🚀 Production Deployment:"
echo "   git tag -a v1.0.0 -m 'Release v1.0.0'"
echo "   git push origin v1.0.0"
echo "   # GitHub Actions will automatically deploy"
echo ""
