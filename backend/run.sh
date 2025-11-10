#!/bin/bash
# Script to run the FastAPI application

# Activate virtual environment
source venv/bin/activate

# Run the application
echo "Starting FastAPI Hex to RGB Converter..."
echo "Server will be available at: http://localhost:8000"
echo "API Documentation at: http://localhost:8000/docs"
echo ""
uvicorn main:app --host 0.0.0.0 --port 8000 --reload

