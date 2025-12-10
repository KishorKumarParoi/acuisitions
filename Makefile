.PHONY: help install dev test lint format docker-build docker-up docker-down k8s-deploy k8s-delete tf-init tf-plan tf-apply tf-destroy clean

help:
	@echo "Acquisitions DevOps Makefile"
	@echo ""
	@echo "Development:"
	@echo "  make install          Install dependencies"
	@echo "  make dev              Start development server"
	@echo "  make test             Run tests"
	@echo "  make test-watch       Run tests in watch mode"
	@echo "  make test-coverage    Generate coverage report"
	@echo "  make lint             Run ESLint"
	@echo "  make lint-fix         Fix ESLint issues"
	@echo "  make format           Format code with Prettier"
	@echo ""
	@echo "Docker:"
	@echo "  make docker-build     Build Docker image"
	@echo "  make docker-up        Start Docker Compose"
	@echo "  make docker-down      Stop Docker Compose"
	@echo "  make docker-logs      View Docker logs"
	@echo ""
	@echo "Kubernetes:"
	@echo "  make k8s-deploy       Deploy to Kubernetes"
	@echo "  make k8s-delete       Delete from Kubernetes"
	@echo "  make k8s-logs         View Kubernetes logs"
	@echo "  make k8s-describe     Describe pods"
	@echo ""
	@echo "Terraform:"
	@echo "  make tf-init          Initialize Terraform"
	@echo "  make tf-plan          Plan Terraform changes"
	@echo "  make tf-apply         Apply Terraform changes"
	@echo "  make tf-destroy       Destroy Terraform resources"
	@echo ""
	@echo "Utilities:"
	@echo "  make clean            Clean up temporary files"
	@echo "  make setup            Complete setup"

install:
	npm install

dev:
	npm run dev

test:
	npm run test

test-watch:
	npm run test:watch

test-coverage:
	npm run test:coverage

lint:
	npm run lint

lint-fix:
	npm run lint:fix

format:
	npm run format

docker-build:
	npm run docker:build

docker-up:
	npm run docker:up

docker-down:
	npm run docker:down

docker-logs:
	npm run docker:logs

k8s-deploy:
	npm run k8s:deploy

k8s-delete:
	npm run k8s:delete

k8s-logs:
	npm run k8s:logs

k8s-describe:
	kubectl describe pod -n acquisitions

tf-init:
	npm run tf:init

tf-plan:
	npm run tf:plan

tf-apply:
	npm run tf:apply

tf-destroy:
	npm run tf:destroy

clean:
	rm -rf node_modules coverage dist build logs .turbo .next .env.local

setup: install lint-fix format docker-up test
	@echo "Setup complete!"

.SILENT: help
