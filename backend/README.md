# Hex to RGB Converter API

A FastAPI backend service that converts hex color codes to RGB color combinations.

## Features

- Convert hex color codes to RGB values
- Support for both POST and GET requests
- Input validation for hex codes
- Automatic API documentation (Swagger UI)
- Returns RGB as tuple and formatted string

## Setup

### 1. Create and activate virtual environment

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment (macOS/Linux)
source venv/bin/activate

# Activate virtual environment (Windows)
# venv\Scripts\activate
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

## Running the API

```bash
# Using uvicorn directly
uvicorn main:app --reload

# Or run the main.py file
python main.py
```

The API will be available at: `http://localhost:8000`

## API Documentation

Once the server is running, you can access:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## API Endpoints

### 1. Root Endpoint
```
GET /
```
Returns API information and available endpoints.

### 2. Convert Hex to RGB (POST)
```
POST /convert
Content-Type: application/json

{
  "hex_code": "#FF5733"
}
```

**Response:**
```json
{
  "hex_code": "#FF5733",
  "rgb": [255, 87, 51],
  "rgb_string": "rgb(255, 87, 51)"
}
```

### 3. Convert Hex to RGB (GET)
```
GET /convert/{hex_code}
```

**Example:**
```
GET /convert/FF5733
```

**Response:**
```json
{
  "hex_code": "#FF5733",
  "rgb": [255, 87, 51],
  "rgb_string": "rgb(255, 87, 51)"
}
```

## Examples

### Using curl (POST)
```bash
curl -X POST "http://localhost:8000/convert" \
  -H "Content-Type: application/json" \
  -d '{"hex_code": "#FF5733"}'
```

### Using curl (GET)
```bash
curl "http://localhost:8000/convert/FF5733"
```

### Using Python requests
```python
import requests

# POST request
response = requests.post(
    "http://localhost:8000/convert",
    json={"hex_code": "#FF5733"}
)
print(response.json())

# GET request
response = requests.get("http://localhost:8000/convert/FF5733")
print(response.json())
```

## Input Format

The hex color code can be provided:
- With or without the `#` prefix
- In uppercase or lowercase
- Must be exactly 6 hexadecimal characters (0-9, A-F)

Valid examples:
- `#FF5733`
- `FF5733`
- `ff5733`
- `#ff5733`

## Error Handling

The API validates input and returns appropriate error messages:

```json
{
  "detail": "Invalid hex color code. Must be 6 hexadecimal characters (with or without #)"
}
```

