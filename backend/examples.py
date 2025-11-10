"""
Example usage of the Hex to RGB Converter API

This file demonstrates how to use the API from Python code.
"""

import requests
import json

# Base URL for the API
BASE_URL = "http://localhost:8000"

def example_post_request():
    """Example of using POST request to convert hex to RGB"""
    print("\n1. POST Request Example")
    print("-" * 50)

    # Example hex colors
    hex_colors = ["#FF5733", "#00FF00", "#0000FF", "FFFFFF"]

    for hex_code in hex_colors:
        response = requests.post(
            f"{BASE_URL}/convert",
            json={"hex_code": hex_code}
        )

        if response.status_code == 200:
            data = response.json()
            print(f"Input:  {hex_code}")
            print(f"Output: {data['rgb_string']}")
            print(f"RGB Tuple: {data['rgb']}")
            print()
        else:
            print(f"Error converting {hex_code}: {response.json()}")
            print()


def example_get_request():
    """Example of using GET request to convert hex to RGB"""
    print("\n2. GET Request Example")
    print("-" * 50)

    # Example hex colors
    hex_colors = ["FF5733", "00FF00", "0000FF", "FFFFFF"]

    for hex_code in hex_colors:
        response = requests.get(f"{BASE_URL}/convert/{hex_code}")

        if response.status_code == 200:
            data = response.json()
            print(f"Input:  {hex_code}")
            print(f"Output: {data['rgb_string']}")
            print(f"RGB Tuple: {data['rgb']}")
            print()
        else:
            print(f"Error converting {hex_code}: {response.json()}")
            print()


def example_error_handling():
    """Example of error handling with invalid hex codes"""
    print("\n3. Error Handling Example")
    print("-" * 50)

    # Invalid hex colors
    invalid_colors = ["GGGGGG", "FFF", "FFFFFFF", "XYZ123"]

    for hex_code in invalid_colors:
        response = requests.post(
            f"{BASE_URL}/convert",
            json={"hex_code": hex_code}
        )

        print(f"Input: {hex_code}")
        if response.status_code == 200:
            print(f"Unexpected success: {response.json()}")
        else:
            print(f"Expected error: {response.json()['detail']}")
        print()


def example_batch_conversion():
    """Example of converting multiple colors in batch"""
    print("\n4. Batch Conversion Example")
    print("-" * 50)

    # Common color palette
    color_palette = {
        "Red": "#FF0000",
        "Green": "#00FF00",
        "Blue": "#0000FF",
        "Yellow": "#FFFF00",
        "Cyan": "#00FFFF",
        "Magenta": "#FF00FF",
        "White": "#FFFFFF",
        "Black": "#000000",
        "Orange": "#FF5733",
        "Purple": "#9B59B6"
    }

    results = {}
    for color_name, hex_code in color_palette.items():
        response = requests.post(
            f"{BASE_URL}/convert",
            json={"hex_code": hex_code}
        )

        if response.status_code == 200:
            data = response.json()
            results[color_name] = data['rgb_string']

    print("Color Palette Conversion Results:")
    print(json.dumps(results, indent=2))


def main():
    """Main function to run all examples"""
    print("=" * 50)
    print("Hex to RGB Converter API - Usage Examples")
    print("=" * 50)
    print("\nMake sure the API server is running at http://localhost:8000")
    print("You can start it with: ./run.sh or python main.py")

    try:
        # Check if server is running
        response = requests.get(BASE_URL)
        if response.status_code == 200:
            print("\n✓ API Server is running!")

            # Run examples
            example_post_request()
            example_get_request()
            example_error_handling()
            example_batch_conversion()

    except requests.exceptions.ConnectionError:
        print("\n✗ Error: Could not connect to API server")
        print("Please start the server first with: ./run.sh or python main.py")
        return

    print("\n" + "=" * 50)
    print("Examples completed!")
    print("=" * 50)


if __name__ == "__main__":
    main()

