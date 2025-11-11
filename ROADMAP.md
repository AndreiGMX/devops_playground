# DevOps Playground Roadmap (FastAPI + HTML)

This is a step-by-step roadmap to take your project from a local folder to a fully automated, cloud-native application running on Kubernetes, deployed with Terraform and GitHub Actions.

## Phase 1: Containerize & Orchestrate (Local)

**Goal:** Run your entire multi-container app on your local machine with one command.

1.  **Backend Dockerfile (in `/backend`):**
    * Create a `Dockerfile` in your `/backend` folder.
    * Use an official `python:3.10-slim` image.
    * Copy your `requirements.txt` first, then run `pip install -r requirements.txt` (this caches the layer).
    * Copy the rest of your backend code.
    * Use `CMD` to run `uvicorn`: `CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]`.

2.  **Frontend Dockerfile (in `/frontend`):**
    * Create a `Dockerfile` in your `/frontend` folder.
    * Use the official `nginx:alpine` image.
    * `COPY` your `index.html` file into `/usr/share/nginx/html/`.

3.  **Docker Compose (in project root):**
    * Create a `docker-compose.yml` in the root `devops_playground` folder.
    * Define two services: `backend` and `frontend`.
    * `backend`: Use `build: ./backend`. Expose port `8000:8000`.
    * `frontend`: Use `build: ./frontend`. Expose port `8080:80` (so you access it on `http://localhost:8080`).

> **Success Milestone:** You can run `docker-compose up --build` and your app works at `http://localhost:8080`.

---

## Phase 2: Continuous Integration (CI)

**Goal:** Automatically build and test your Docker images every time you push code to GitHub.

1.  **Create CI Workflow:**
    * Create the file `.github/workflows/ci.yml`.
    * **Trigger:** Set it to `on: [push]`.

2.  **Define CI Jobs:**
    * **`lint-and-test`:**
        * `actions/checkout`
        * `actions/setup-python`
        * `pip install -r backend/requirements.txt`
        * (Optional but good) Run a linter like `flake8` or a test framework like `pytest`.
    * **`build-docker-images`:**
        * `actions/checkout`
        * `docker/setup-buildx-action` (to set up Docker build tools).
        * Run `docker build -f backend/Dockerfile ./backend` to confirm it builds.
        * Run `docker build -f frontend/Dockerfile ./frontend` to confirm it builds.

3.  **Store Images in a Registry:**
    * This is the most important part of CI.
    * Log in to **GitHub Container Registry (ghcr.io)** using `docker/login-action`.
    * Build *and push* your images. Tag them with the GitHub SHA (commit hash) for uniqueness (e.g., `:${{ github.sha }}`).
        * `docker push ghcr.io/YOUR_USERNAME/devops-playground-backend:${{ github.sha }}`
        * `docker push ghcr.io/YOUR_USERNAME/devops-playground-frontend:${{ github.sha }}`

> **Success Milestone:** When you push to GitHub, an Action runs, builds your images, and pushes them to `ghcr.io` tagged with a unique commit ID.

---

## Phase 3: Infrastructure as Code (Terraform)

**Goal:** Stop creating servers by hand. Define your infrastructure in code. We'll start simple: **one VM**.

1.  **Choose a Cloud:**
    * We will use **AWS** (Amazon Web Services).
    * Generate an **AWS Access Key ID** and **Secret Access Key** for a user with EC2 permissions.
    * Add them to your repo's **GitHub Secrets** (e.g., `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`).

2.  **Write Your First Terraform File:**
    * Create a `/terraform` folder.
    * Inside, create `main.tf`.
    * Define the `provider "aws"`.
    * Define one resource: a single VM (`aws_instance`), using a simple `t2.micro` or `t3.micro` instance type. You'll also need to define its AMI (e.g., Ubuntu) and a security group that allows SSH (port 22) and HTTP (port 8080).
    * Use a `user_data` script (cloud-init) to automatically install `docker` and `docker-compose` on the instance when it's created.

3.  **Integrate with GitHub Actions:**
    * Create a new workflow, `.github/workflows/infra.yml`, that runs *manually* (`on: [workflow_dispatch]`).
    * Configure your AWS credentials using `aws-actions/configure-aws-credentials`.
    * Use `hashicorp/setup-terraform`.
    * Add steps to run `terraform init`, `terraform plan`, and `terraform apply -auto-approve`.

> **Success Milestone:** You can click a button in GitHub ("Run workflow") and Terraform automatically creates a new **AWS EC2 instance** that has Docker installed.

---

## Phase 4: Continuous Deployment (CD)

**Goal:** Automatically deploy your app to the VM you just created.

1.  **Create a "Production" Compose File:**
    * On your server, you need a `docker-compose.prod.yml`. This file will *not* use `build`. It will use the `image` you pushed to `ghcr.io`.
    * **Example service:**
        ```yaml
        services:
          backend:
            image: ghcr.io/YOUR_USERNAME/devops-playground-backend:latest
            # ...
        ```
        *(Note: Using a specific tag from Phase 2 is better than `latest`, but `latest` is simpler to start).*

2.  **Create CD Workflow:**
    * Create `.github/workflows/cd.yml`.
    * **Trigger:** Set this to run *after* the `ci.yml` (Phase 2) successfully completes on the `main` branch.
    * **Job:** `deploy-to-vm`
        * Store your EC2 instance's IP, SSH username (`ubuntu` or `ec2-user`), and SSH private key in **GitHub Secrets**.
        * Use an "SSH" action (e.g., `appleboy/ssh-action`).
        * The SSH action will log into your VM and run:
            1.  `docker-compose -f docker-compose.prod.yml pull` (to get the new images).
            2.  `docker-compose -f docker-compose.prod.yml up -d` (to restart the app).

> **Success Milestone:** You push code, CI builds and pushes the image, and CD automatically deploys that new image to your live EC2 server.

---

## Phase 5: The Final Goal (Kubernetes)

**Goal:** Evolve from a single-VM deployment to a resilient, scalable Kubernetes cluster.

1.  **Evolve Your Terraform (IaC):**
    * Modify your `/terraform/main.tf` file.
    * **Delete** the `aws_instance` resource.
    * **Add** an `aws_eks_cluster` resource and its required dependencies (like IAM roles and a VPC). This is significantly more complex than the EC2 instance, so follow a guide for the "EKS" Terraform module.
    * This tells Terraform to create an entire managed K8s cluster (EKS) instead of one VM. Run your `infra.yml` workflow to apply this.

2.  **Learn Kubernetes Manifests:**
    * Create a `/kubernetes` folder in your repo.
    * **`backend-deployment.yml`:** Create a `Deployment` object. It will define "I want 2 copies (replicas) of my `backend` image running."
    * **`backend-service.yml`:** Create a `Service` object. This gives your backend `Deployment` a single, stable network name (e.g., `backend-service`).
    * **`frontend-deployment.yml`:** A `Deployment` for your NGINX `frontend` image.
    * **`ingress.yml`:** This is the key. Create an `Ingress` object (you'll need to install an Ingress Controller like `aws-load-balancer-controller` on your cluster). This is the "smart router" that will create an AWS Application Load Balancer (ALB). You'll configure it to:
        * Route requests for `/api/*` to your `backend-service`.
        * Route requests for `/` (everything else) to your `frontend-service`.
        * *(This requires your `index.html` to fetch from `/api/data`)*

3.  **Evolve Your CD Workflow (The Final Step):**
    * Modify your `.github/workflows/cd.yml` workflow.
    * **Throw away the SSH action.** We don't SSH into Kubernetes clusters.
    * **Add steps to:**
        1.  Install `kubectl` (the K8s command-line tool).
        2.  Configure AWS credentials (like in Phase 3).
        3.  Fetch K8s credentials from your EKS cluster using the AWS CLI: `aws eks update-kubeconfig --name YOUR_CLUSTER_NAME`.
        4.  Run `kubectl apply -f kubernetes/` to send your YAML files to the cluster.
        5.  Run `kubectl rollout restart deployment/backend-deployment` to force it to pull the new image.

> **Final Success Milestone:** You push a backend code change. GitHub Actions builds the image, and your CD pipeline tells Kubernetes to deploy it. EKS performs a "rolling update" with zero downtime. You have successfully built a full, production-grade, cloud-native pipeline on AWS.