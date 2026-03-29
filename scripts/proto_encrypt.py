#!/usr/bin/env python3
"""
NANO Dark Messenger — Prototype Encrypt/Decrypt
Quick prototype for testing crypto flows before Rust implementation.

Usage:
    python3 proto_encrypt.py --encrypt --password "secret123" --input message.txt
    python3 proto_encrypt.py --decrypt --password "secret123" --input message.enc
"""

import argparse
import base64
import hashlib
import os
import sys
from pathlib import Path

try:
    from cryptography.hazmat.primitives.ciphers.aead import AESGCM
    from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
    from cryptography.hazmat.primitives import hashes
    from cryptography.hazmat.backends import default_backend
except ImportError:
    print("❌ Install cryptography: pip3 install cryptography")
    sys.exit(1)


def derive_key(password: str, salt: bytes) -> bytes:
    """Derive 256-bit key from password using PBKDF2-HMAC-SHA512"""
    kdf = PBKDF2HMAC(
        algorithm=hashes.SHA512(),
        length=32,
        salt=salt,
        iterations=100_000,
        backend=default_backend(),
    )
    return kdf.derive(password.encode())


def encrypt_file(input_path: str, password: str, output_path: str = None):
    """Encrypt file with AES-256-GCM"""
    input_file = Path(input_path)
    if not output_path:
        output_path = str(input_file) + ".enc"
    
    # Generate random salt and nonce
    salt = os.urandom(16)
    nonce = os.urandom(12)
    
    # Derive key
    key = derive_key(password, salt)
    
    # Read and encrypt
    with open(input_file, 'rb') as f:
        plaintext = f.read()
    
    aesgcm = AESGCM(key)
    ciphertext = aesgcm.encrypt(nonce, plaintext, None)
    
    # Write: salt + nonce + ciphertext
    with open(output_path, 'wb') as f:
        f.write(salt + nonce + ciphertext)
    
    print(f"✅ Encrypted: {input_path} → {output_path}")
    print(f"   Salt: {salt.hex()}")
    return output_path


def decrypt_file(input_path: str, password: str, output_path: str = None):
    """Decrypt file with AES-256-GCM"""
    input_file = Path(input_path)
    if not output_path:
        output_path = str(input_file).replace('.enc', '')
        if output_path == str(input_file):
            output_path = str(input_file) + ".dec"
    
    # Read: salt + nonce + ciphertext
    with open(input_file, 'rb') as f:
        data = f.read()
    
    salt = data[:16]
    nonce = data[16:28]
    ciphertext = data[28:]
    
    # Derive key
    key = derive_key(password, salt)
    
    # Decrypt
    aesgcm = AESGCM(key)
    try:
        plaintext = aesgcm.decrypt(nonce, ciphertext, None)
    except Exception as e:
        print(f"❌ Decryption failed: {e}")
        print("   Wrong password or corrupted file!")
        sys.exit(1)
    
    with open(output_path, 'wb') as f:
        f.write(plaintext)
    
    print(f"✅ Decrypted: {input_path} → {output_path}")
    return output_path


def encrypt_message(message: str, password: str) -> str:
    """Encrypt text message and return base64"""
    salt = os.urandom(16)
    nonce = os.urandom(12)
    key = derive_key(password, salt)
    
    aesgcm = AESGCM(key)
    ciphertext = aesgcm.encrypt(nonce, message.encode(), None)
    
    # Encode: salt + nonce + ciphertext
    combined = salt + nonce + ciphertext
    return base64.b64encode(combined).decode()


def decrypt_message(encoded: str, password: str) -> str:
    """Decrypt base64 message"""
    try:
        combined = base64.b64decode(encoded)
    except Exception as e:
        raise ValueError(f"Invalid base64: {e}")
    
    salt = combined[:16]
    nonce = combined[16:28]
    ciphertext = combined[28:]
    
    key = derive_key(password, salt)
    aesgcm = AESGCM(key)
    plaintext = aesgcm.decrypt(nonce, ciphertext, None)
    
    return plaintext.decode()


def main():
    parser = argparse.ArgumentParser(
        description="🌑 NANO Dark Messenger — Prototype Encrypt/Decrypt",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  Encrypt file:
    python3 proto_encrypt.py -e -p "mypassword" -i secret.txt
  
  Decrypt file:
    python3 proto_encrypt.py -d -p "mypassword" -i secret.txt.enc
  
  Encrypt message:
    python3 proto_encrypt.py --encrypt-msg -p "mypassword" -m "Hello!"
  
  Decrypt message:
    python3 proto_encrypt.py --decrypt-msg -p "mypassword" -c "BASE64..."
        """
    )
    
    parser.add_argument('-e', '--encrypt', action='store_true', help='Encrypt file')
    parser.add_argument('-d', '--decrypt', action='store_true', help='Decrypt file')
    parser.add_argument('--encrypt-msg', action='store_true', help='Encrypt message')
    parser.add_argument('--decrypt-msg', action='store_true', help='Decrypt message')
    parser.add_argument('-p', '--password', required=True, help='Password')
    parser.add_argument('-i', '--input', help='Input file path')
    parser.add_argument('-o', '--output', help='Output file path')
    parser.add_argument('-m', '--message', help='Message to encrypt')
    parser.add_argument('-c', '--ciphertext', help='Base64 ciphertext to decrypt')
    
    args = parser.parse_args()
    
    try:
        if args.encrypt:
            if not args.input:
                print("❌ --input required for encryption")
                sys.exit(1)
            encrypt_file(args.input, args.password, args.output)
        
        elif args.decrypt:
            if not args.input:
                print("❌ --input required for decryption")
                sys.exit(1)
            decrypt_file(args.input, args.password, args.output)
        
        elif args.encrypt_msg:
            if not args.message:
                print("❌ --message required")
                sys.exit(1)
            encoded = encrypt_message(args.message, args.password)
            print(f"🔐 Encrypted:\n{encoded}")
        
        elif args.decrypt_msg:
            if not args.ciphertext:
                print("❌ --ciphertext required")
                sys.exit(1)
            message = decrypt_message(args.ciphertext, args.password)
            print(f"🔓 Decrypted:\n{message}")
        
        else:
            parser.print_help()
    
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
