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

## 🏗️ Project Structure

> [!IMPORTANT]
> **This project has been split into multiple repositories.**

This repository (**devops_playground**) is now dedicated to **GitOps, Infrastructure, and Helm Charts**. The application source code has been moved to separate repositories to simulate a real-world microservices environment.

### 🔗 Repositories

| Component | Repository URL | Description |
|-----------|----------------|-------------|
| **Infrastructure** | [Current Repo](https://github.com/AndreiGMX/devops_playground) | Terraform, Helm Charts, GitOps Workflows |
| **Backend** | [devops_playground_backend](https://github.com/AndreiGMX/devops_playground_backend.git) | FastAPI Application Source Code |
| **Frontend** | [devops_playground_frontend](https://github.com/AndreiGMX/devops_playground_frontend.git) | HTML/JS Frontend Source Code |

### 🔄 CI/CD Workflow
1. **Development**: Changes are pushed to the Backend or Frontend repositories.
2. **CI**: Each repo has its own CI pipeline that builds and pushes Docker images to GHCR.
3. **CD (Flux CD)**: Flux CD automatically monitors GHCR for new images and updates deployments on the EKS cluster without manual intervention.

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

#### Step C — Deploy application (Flux CD)

**Initial Setup:**

1. **Configure kubectl:**
   ```bash
   # Update kubeconfig to connect to your EKS cluster
   aws eks update-kubeconfig --region eu-north-1 --name my-app-cluster
   ```
   
   > **Note**: Since your GHCR images are public, no authentication secret is required.

2. **Apply Flux Manifests:**
   ```bash
   # Apply all Flux CD manifests
   kubectl apply -f flux/sources/
   kubectl apply -f flux/releases/
   kubectl apply -f flux/image-automation/
   ```

3. **Verify Flux Installation:**
   ```bash
   # Check Flux components
   kubectl get pods -n flux-system
   
   # Check if HelmRelease is ready
   kubectl get helmrelease -n flux-system
   
   # Check application pods
   kubectl get pods -n devops-playground
   ```

**Automated Deployments:**

Once set up, Flux CD will:
- Monitor GHCR for new backend/frontend images every minute
- Automatically update the HelmRelease manifest when new images are detected
- Commit the changes back to this repository
- Deploy the updated application to the cluster

You can monitor the automation:
```bash
# Watch image repositories
kubectl get imagerepository -n flux-system

# Watch for image updates
kubectl logs -n flux-system deployment/image-reflector-controller -f

# Check the ingress URL
kubectl get ingress -n devops-playground
```

#### Step D — Cleanup

- To avoid AWS charges, run the **Destroy Terraform Infrastructure** workflow from the Actions tab.

### 📚 Architecture & Technologies

- **IaC:** Terraform (EKS, VPC, IAM)
- **Orchestration:** Kubernetes (Helm Charts, Deployments, Services, Ingress)
- **GitOps:** Flux CD (Automated image updates and deployments)
- **Ingress:** AWS ALB (Application Load Balancer) Controller
- **CI:** GitHub Actions (in backend/frontend repos)
- **Registry:** GitHub Container Registry (`ghcr.io`)

### 🌟 Current Status

- Phase Completed: ✅ Phase 5 — Kubernetes + GitOps

We have a cloud-native GitOps pipeline from local development to automated infrastructure provisioning and deployment:

- ✅ Containerized: Dockerfiles for frontend and backend
- ✅ CI: Automated build & test workflows in separate repos
- ✅ IaC: Terraform scripts to create EKS and networking
- ✅ GitOps: Flux CD for automated deployments and image updates
- ✅ Helm: Umbrella chart structure with subcharts
- ✅ Ingress: ALB-managed traffic entry

### 🤝 Contributing

This is a learning project — contributions welcome:

- Fork the repository
- Experiment with Flux CD configurations or Helm charts
- Open issues for questions or suggestions

### 📝 License

This project is intended for educational purposes.
