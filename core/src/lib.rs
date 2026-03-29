//! NANO Crypto Core
//! 
//! Cryptographic primitives for NANO Dark Messenger:
//! - AES-256-GCM encryption/decryption
//! - X25519 key exchange
//! - Ed25519 signatures
//! - Argon2 key derivation

pub mod key_exchange;

use aes_gcm::{
    aead::{Aead, KeyInit},
    Aes256Gcm, Nonce,
};
use argon2::{password_hash::SaltString, Argon2, PasswordHasher};
use base64::{engine::general_purpose, Engine as _};
use rand::{rngs::OsRng, Rng};
use x25519_dalek::{EphemeralSecret, PublicKey};

/// Encrypt message with AES-256-GCM
pub fn encrypt(plaintext: &str, key: &[u8]) -> Result<String, anyhow::Error> {
    let cipher = Aes256Gcm::new_from_slice(key).map_err(|e| anyhow::anyhow!("Key error: {}", e))?;
    let nonce = Nonce::from(OsRng.gen::<[u8; 12]>());
    let ciphertext = cipher.encrypt(&nonce, plaintext.as_bytes()).map_err(|e| anyhow::anyhow!("Encrypt failed: {}", e))?;
    
    // Encode nonce + ciphertext in base64
    let mut combined = nonce.to_vec();
    combined.extend_from_slice(&ciphertext);
    Ok(general_purpose::STANDARD.encode(&combined))
}

/// Decrypt message with AES-256-GCM
pub fn decrypt(ciphertext_b64: &str, key: &[u8]) -> Result<String, anyhow::Error> {
    let combined = general_purpose::STANDARD.decode(ciphertext_b64).map_err(|e| anyhow::anyhow!("Decode failed: {}", e))?;
    let nonce = Nonce::from_slice(&combined[..12]);
    let ciphertext = &combined[12..];
    
    let cipher = Aes256Gcm::new_from_slice(key).map_err(|e| anyhow::anyhow!("Key error: {}", e))?;
    let plaintext = cipher.decrypt(nonce, ciphertext).map_err(|e| anyhow::anyhow!("Decrypt failed: {}", e))?;
    Ok(String::from_utf8(plaintext).map_err(|e| anyhow::anyhow!("UTF8 error: {}", e))?)
}

/// Derive encryption key from password using Argon2
pub fn derive_key_from_password(password: &str, salt: &str) -> Result<[u8; 32], anyhow::Error> {
    let argon2 = Argon2::default();
    let salt = SaltString::from_b64(salt).map_err(|e| anyhow::anyhow!("Invalid salt: {}", e))?;
    let hash = argon2.hash_password(password.as_bytes(), &salt).map_err(|e| anyhow::anyhow!("Hash failed: {}", e))?;
    
    // Take first 32 bytes of hash
    let mut key = [0u8; 32];
    if let Some(hash_bytes) = hash.hash {
        key.copy_from_slice(&hash_bytes.as_bytes()[..32]);
    }
    Ok(key)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_encrypt_decrypt() {
        let key = [42u8; 32];
        let message = "Hello, NANO!";
        
        let encrypted = encrypt(message, &key).unwrap();
        let decrypted = decrypt(&encrypted, &key).unwrap();
        
        assert_eq!(message, decrypted);
    }
}
