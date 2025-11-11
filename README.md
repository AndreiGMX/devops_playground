# DevOps Playground

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

## 🏁 Getting Started

### Prerequisites
- Python 3.10+
- Docker (optional for local development, required for DevOps learning)
- Git and GitHub account

### Quick Start (Local Development)

1. **Clone the repository**
   ```bash
   git clone https://github.com/AndreiGMX/devops_playground.git
   cd devops_playground
   ```

2. **Run the backend**
   ```bash
   cd backend
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   python main.py
   ```
   Backend will be available at `http://localhost:8000`

3. **Open the frontend**
   ```bash
   # In a new terminal
   cd frontend
   # Open index.html in your browser or use a simple HTTP server
   python3 -m http.server 8080
   ```
   Frontend will be available at `http://localhost:8080`

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

## 🌟 Current Status

**Branch**: phase2_CI  
**Current Focus**: Implementing Continuous Integration with GitHub Actions

## 🤝 Contributing

This is a learning project! Feel free to:
- Fork the repository
- Experiment with different DevOps tools
- Share your improvements
- Create issues for questions or suggestions

## 📝 License

This project is designed for educational purposes.

---

**Ready to start your DevOps journey?** Check out the `ROADMAP.md` file and begin with Phase 1! 🚀
