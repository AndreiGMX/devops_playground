"""
Test script for the Hex to RGB Converter API
"""
from main import HexColorRequest, hex_to_rgb


def test_hex_to_rgb():
    """Test the hex_to_rgb function with various inputs."""
    print("=" * 50)
    print("Testing valid hex codes:")
    print("=" * 50)
    
    test_cases = [
        "#FF5733",
        "FF5733",
        "00FF00",
        "#0000FF",
        "FFFFFF",
        "000000"
    ]

    for hex_code in test_cases:
        try:
            # Test with validation
            color = HexColorRequest(hex_code=hex_code)
            rgb = hex_to_rgb(color.hex_code)
            print(f"Hex: {hex_code:8} -> RGB: {rgb} -> rgb({rgb[0]}, {rgb[1]}, {rgb[2]})")
        except Exception as e:
            print(f"Hex: {hex_code:8} -> Error: {e}")

    print("\n" + "=" * 50)
    print("Testing invalid hex codes:")
    print("=" * 50)

    invalid_cases = [
        "GGGGGG",  # Invalid characters
        "FFF",     # Too short
        "FFFFFFF", # Too long
        "XYZ123",  # Invalid characters
    ]

    for hex_code in invalid_cases:
        try:
            color = HexColorRequest(hex_code=hex_code)
            rgb = hex_to_rgb(color.hex_code)
            print(f"Hex: {hex_code:8} -> RGB: {rgb}")
        except Exception as e:
            print(f"Hex: {hex_code:8} -> Error: {type(e).__name__}")
    
    print("\n" + "=" * 50)
    print("All tests completed!")
    print("=" * 50)


if __name__ == "__main__":
    test_hex_to_rgb()

