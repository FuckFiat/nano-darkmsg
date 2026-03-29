#!/usr/bin/env python3
"""
NANO Steganography — Hide encrypted messages in images
LSB (Least Significant Bit) method
"""

import sys
from PIL import Image
import numpy as np
import base64
from pathlib import Path


def text_to_bits(text: str) -> list:
    """Convert text to binary list (UTF-8 encoded)"""
    bits = []
    # Encode to UTF-8 bytes first
    utf8_bytes = text.encode('utf-8')
    for byte in utf8_bytes:
        bits.extend([int(b) for b in format(byte, '08b')])
    return bits


def bits_to_text(bits: list) -> str:
    """Convert binary list back to text (UTF-8 decoded)"""
    # Convert bits to bytes
    byte_array = bytearray()
    for i in range(0, len(bits), 8):
        byte = bits[i:i+8]
        if len(byte) == 8:
            byte_array.append(int(''.join(map(str, byte)), 2))
    
    # Decode from UTF-8
    return byte_array.decode('utf-8')


def encode_message(image_path: str, message: str, output_path: str, password: str = None):
    """Hide encrypted message in image using LSB"""
    
    # Open image
    img = Image.open(image_path)
    img_array = np.array(img)
    
    # Flatten image data
    flat = img_array.flatten()
    
    # Encode to UTF-8 bytes first
    message_bytes = message.encode('utf-8')
    
    # Encode length first (32 bits = up to 4GB)
    byte_len = len(message_bytes)
    len_bits = format(byte_len, '032b')
    len_bits = [int(b) for b in len_bits]
    
    # Encode message bytes
    message_bits = []
    for byte in message_bytes:
        message_bits.extend([int(b) for b in format(byte, '08b')])
    
    all_bits = len_bits + message_bits
    
    # Check capacity
    max_bits = len(flat) // 3
    if len(all_bits) > max_bits:
        raise ValueError(f"Message too long! Max {(max_bits - 32) // 8} bytes for this image")
    
    # Encode in LSB
    for i, bit in enumerate(all_bits):
        flat[i * 3] = int(flat[i * 3]) & ~1 | bit
    
    # Reshape and save
    img_array = flat.reshape(img_array.shape)
    new_img = Image.fromarray(img_array.astype(np.uint8))
    new_img.save(output_path, format='PNG')
    
    print(f"✅ Message hidden in {output_path}")
    print(f"   Original: {Path(image_path).stat().st_size} bytes")
    print(f"   Output: {Path(output_path).stat().st_size} bytes")
    print(f"   Message length: {byte_len} bytes ({len(all_bits)} bits)")
    
    return True


def decode_message(image_path: str, password: str = None) -> str:
    """Extract hidden message from image"""
    
    # Open image
    img = Image.open(image_path)
    img_array = np.array(img)
    
    # Flatten
    flat = img_array.flatten()
    
    # Extract length first (32 bits)
    len_bits = []
    for i in range(32):
        len_bits.append(int(flat[i * 3]) & 1)
    
    message_len = int(''.join(map(str, len_bits)), 2)
    
    # Extract message
    message_bits = []
    for i in range(32, 32 + message_len * 8):
        message_bits.append(int(flat[i * 3]) & 1)
    
    # Convert to text
    text = bits_to_text(message_bits)
    
    return text


def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="NANO Steganography CLI")
    parser.add_argument('mode', choices=['encode', 'decode'], help='Mode')
    parser.add_argument('-i', '--input', required=True, help='Input image')
    parser.add_argument('-o', '--output', help='Output image (encode mode)')
    parser.add_argument('-m', '--message', help='Message to hide (encode mode)')
    parser.add_argument('-p', '--password', help='Password (optional)')
    parser.add_argument('-f', '--file', help='Read message from file')
    
    args = parser.parse_args()
    
    if args.mode == 'encode':
        if not args.message and not args.file:
            print("❌ Need --message or --file")
            sys.exit(1)
        
        message = args.message
        if args.file:
            message = Path(args.file).read_text()
        
        output = args.output or args.input.replace('.png', '_hidden.png')
        
        encode_message(args.input, message, output, args.password)
        
    elif args.mode == 'decode':
        try:
            message = decode_message(args.input, args.password)
            print(f"📤 Decoded message:\n{message}")
        except ValueError as e:
            print(f"❌ {e}")
            sys.exit(1)


if __name__ == "__main__":
    main()
