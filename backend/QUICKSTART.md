# Quick Start Guide

## Setup (First Time Only)

1. **Activate the virtual environment:**
   ```bash
   source venv/bin/activate
   ```

2. **Verify installation:**
   ```bash
   pip list | grep fastapi
   ```

## Running the Server

### Option 1: Using the run script
```bash
./run.sh
```

### Option 2: Using uvicorn directly
```bash
source venv/bin/activate
uvicorn main:app --reload
```

### Option 3: Using Python
```bash
source venv/bin/activate
python main.py
```

## Accessing the API

- **API Server:** http://localhost:8000
- **Interactive Docs (Swagger UI):** http://localhost:8000/docs
- **Alternative Docs (ReDoc):** http://localhost:8000/redoc

## Quick Test

Once the server is running, open a new terminal and try:

```bash
# Test with curl (POST)
curl -X POST "http://localhost:8000/convert" \
  -H "Content-Type: application/json" \
  -d '{"hex_code": "#FF5733"}'

# Test with curl (GET)
curl "http://localhost:8000/convert/FF5733"
```

Expected response:
```json
{
  "hex_code": "#FF5733",
  "rgb": [255, 87, 51],
  "rgb_string": "rgb(255, 87, 51)"
}
```

## Running Examples

```bash
# First, start the server in one terminal
./run.sh

# Then in another terminal, run the examples
source venv/bin/activate
python examples.py
```

## Testing the Conversion Function

```bash
source venv/bin/activate
python test_api.py
```

## Deactivate Virtual Environment

When you're done:
```bash
deactivate
```

