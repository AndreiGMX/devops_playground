from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, validator
from typing import Tuple
import re

app = FastAPI(title="Hex to RGB Converter API")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)


class HexColorRequest(BaseModel):
    hex_code: str

    @validator('hex_code')
    def validate_hex_code(cls, v):
        # Remove '#' if present
        v = v.strip()
        if v.startswith('#'):
            v = v[1:]

        # Validate hex code format
        if not re.match(r'^[0-9A-Fa-f]{6}$', v):
            raise ValueError('Invalid hex color code. Must be 6 hexadecimal characters (with or without #)')

        return v


class RGBColorResponse(BaseModel):
    hex_code: str
    rgb: Tuple[int, int, int]
    rgb_string: str


def hex_to_rgb(hex_code: str) -> Tuple[int, int, int]:
    """Convert hex color code to RGB tuple."""
    # Remove '#' if present
    hex_code = hex_code.lstrip('#')

    # Convert to RGB
    r = int(hex_code[0:2], 16)
    g = int(hex_code[2:4], 16)
    b = int(hex_code[4:6], 16)

    return (r, g, b)


@app.get("/")
async def root():
    """Root endpoint with API information."""
    return {
        "message": "Hex to RGB Converter API",
        "version": "1.0.0",
        "endpoints": {
            "/convert": "POST - Convert hex color to RGB",
            "/convert/{hex_code}": "GET - Convert hex color to RGB via URL",
            "/health": "GET - Health check endpoint"
        }
    }


@app.get("/health")
async def health():
    """Health check endpoint."""
    return {"status": "healthy"}


@app.post("/convert", response_model=RGBColorResponse)
async def convert_hex_to_rgb(color: HexColorRequest):
    """
    Convert a hex color code to RGB.

    - **hex_code**: Hex color code (with or without #)

    Example: #FF5733 or FF5733
    """
    try:
        rgb = hex_to_rgb(color.hex_code)
        return RGBColorResponse(
            hex_code=f"#{color.hex_code.upper()}",
            rgb=rgb,
            rgb_string=f"rgb({rgb[0]}, {rgb[1]}, {rgb[2]})"
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/convert/{hex_code}", response_model=RGBColorResponse)
async def convert_hex_to_rgb_get(hex_code: str):
    """
    Convert a hex color code to RGB via GET request.

    - **hex_code**: Hex color code (with or without #)

    Example: /convert/FF5733 or /convert/%23FF5733
    """
    try:
        # Validate hex code
        color = HexColorRequest(hex_code=hex_code)
        rgb = hex_to_rgb(color.hex_code)

        return RGBColorResponse(
            hex_code=f"#{color.hex_code.upper()}",
            rgb=rgb,
            rgb_string=f"rgb({rgb[0]}, {rgb[1]}, {rgb[2]})"
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

