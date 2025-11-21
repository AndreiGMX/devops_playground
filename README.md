# DevOps Playground

## Table of Contents

- [🚀 What is This Project?](#-what-is-this-project)
- [📱 The Application](#-the-application)
- [🎯 Why This App for DevOps?](#-why-this-app-for-devops)
- [🛤️ Learning Journey](#️-learning-journey)
- [📚 What You'll Learn](#-what-youll-learn)
- [📖 Documentation](#-documentation)
- [🏁 Getting Started](#-getting-started)
- [☁️ Cloud Deployment (AWS EKS + Kubernetes)](#️-cloud-deployment-aws-eks--kubernetes)
- [📚 Architecture & Technologies](#-architecture--technologies)
- [🌟 Current Status](#-current-status)
- [🤝 Contributing](#-contributing)
- [📝 License](#-license)

## 🚀 What is This Project?

**DevOps Playground** is a hands-on learning platform designed to teach you DevOps practices from the ground up. This project uses a simple but complete web application as the foundation to learn real-world DevOps tools and workflows.

## 📱 The Application

At its core, this is a **Hex to RGB Color Converter** web application consisting of:

### Backend (FastAPI)
- **Technology**: Python with FastAPI framework
- **Purpose**: RESTful API that converts hexadecimal color codes to RGB values
- **Features**:
  - Accepts hex color codes (e.g., `#FF5733`)
  - Returns RGB values in multiple formats
  - Input validation
  - Auto-generated API documentation (Swagger UI)
  - CORS enabled for frontend integration

### Frontend (HTML/JavaScript)
- **Technology**: Simple HTML with vanilla JavaScript
- **Purpose**: User-friendly interface to interact with the color conversion API
- **Features**:
  - Input field for hex color codes
  - Real-time color preview
  - Display of RGB values

## 🎯 Why This App for DevOps?

This application is intentionally simple to keep the focus on **DevOps practices** rather than complex application logic. It's the perfect starting point because:

1. **It's Complete**: Has both frontend and backend components
2. **It's Simple**: Easy to understand, so you focus on DevOps, not debugging code
3. **It's Practical**: Real REST API that can be containerized, orchestrated, and deployed
4. **It's Scalable**: Perfect for learning CI/CD, containerization, orchestration, and cloud deployment

## 🛤️ Learning Journey

This playground follows a progressive roadmap (see `ROADMAP.md`) that takes you through:

1. **Phase 1**: Containerization with Docker & Docker Compose
2. **Phase 2**: Continuous Integration (CI) with GitHub Actions
3. **Phase 3**: Infrastructure as Code (IaC) with Terraform
4. **Phase 4**: Continuous Deployment (CD) to cloud infrastructure
5. **Phase 5**: Kubernetes orchestration and advanced DevOps practices

## 📚 What You'll Learn

Through this playground, you'll gain hands-on experience with:

- **Docker**: Containerizing applications
- **Docker Compose**: Multi-container orchestration
- **GitHub Actions**: Automated CI/CD pipelines
- **Terraform**: Infrastructure as Code
- **AWS/Cloud**: Deploying to cloud infrastructure
- **Kubernetes**: Container orchestration at scale
- **Security**: Best practices for DevOps security
- **Monitoring**: Application and infrastructure monitoring

## 📖 Documentation

- `backend/README.md` - Detailed backend API documentation
- `ROADMAP.md` - Complete DevOps learning roadmap
- `backend/QUICKSTART.md` - Quick reference for running the backend

## 🏁 Getting Started

### ✅ Prerequisites

- **Local:** Docker & Docker Compose
- **Cloud:** An AWS account and a GitHub repository

### ⚡ Quick Start (Local Development)

#### Option A — Docker Compose (recommended)

```bash
# Clone the repo
git clone https://github.com/AndreiGMX/devops_playground.git
cd devops_playground

# Build and start services
docker-compose up --build
```

- Frontend: `http://localhost:8080`
- Backend API (Swagger): `http://localhost:8000/docs`

#### Option B — Run services locally (Python venv)

```bash
# Backend
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python main.py

# Frontend (in a new terminal)
cd frontend
python3 -m http.server 8080
```

### ☁️ Cloud Deployment (AWS EKS + Kubernetes)

- This repository supports a full GitOps-style deployment to AWS using Terraform + GitHub Actions.

#### Step A — Configure GitHub Actions secrets

- In your GitHub repository go to: Settings → Secrets and variables → Actions, then add:

   - `AWS_ACCESS_KEY_ID` — your AWS access key
   - `AWS_SECRET_ACCESS_KEY` — your AWS secret key

- (Required AWS permissions: EC2, EKS, IAM, VPC)

#### Step B — Provision infrastructure (Terraform)

- Automated Provisioning: The infrastructure pipeline detects changes specifically in the `/terraform` directory.

- To create or update infrastructure (VPC, EKS cluster, IAM roles), simply push changes to the `/terraform` folder on the main branch.

- The workflow will automatically run terraform apply.

- Note: First-time setup takes approx. 10–20 minutes.

#### Step C — Deploy application (CI/CD)

- Push a change to `main` (or merge a PR). The CI workflow is now optimized with smart path filtering:
   - **Targeted Triggers:** The workflow executes automatically when changes are detected specifically in the `/backend` or `/frontend` directories.
   - **Conditional Builds:** By analyzing the full git history diff, the pipeline determines exactly which component changed. It will only build and push the Docker image for the modified component (Backend or Frontend) to `ghcr.io`, saving time and resources.
- The CD workflow updates kubeconfig, applies manifests from `/kubernetes`, and restarts deployments to pull new images.
- After deployment, check the CD workflow logs for the **Get Ingress Address** step to find your Load Balancer URL.

#### Step D — Cleanup

- To avoid AWS charges, run the **Destroy Terraform Infrastructure** workflow from the Actions tab.

### 📚 Architecture & Technologies

- **IaC:** Terraform (EKS, VPC, IAM)
- **Orchestration:** Kubernetes (Deployments, Services, Ingress)
- **Ingress:** AWS ALB (Application Load Balancer) Controller
- **CI/CD:** GitHub Actions
- **Registry:** GitHub Container Registry (`ghcr.io`)

### 🌟 Current Status

- Phase Completed: ✅ Phase 5 — Kubernetes

We have a cloud-native pipeline from local development to automated infrastructure provisioning and deployment:

- ✅ Containerized: Dockerfiles for frontend and backend
- ✅ CI: Automated build & test workflows (with conditional builds & path filtering)
- ✅ IaC: Terraform scripts to create EKS and networking
- ✅ CD: GitHub Actions apply Kubernetes manifests
- ✅ Ingress: ALB-managed traffic entry

### 🤝 Contributing

This is a learning project — contributions welcome:

- Fork the repository
- Experiment with Helm charts or ArgoCD
- Open issues for questions or suggestions

### 📝 License

This project is intended for educational purposes.
