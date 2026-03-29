//! NANO Crypto Core
//! 
//! Cryptographic primitives for NANO Dark Messenger:
//! - AES-256-GCM encryption/decryption
//! - X25519 key exchange
//! - Ed25519 signatures
//! - Argon2 key derivation

use aes_gcm::{
    aead::{Aead, KeyInit, OsRng},
    Aes256Gcm, Nonce,
};
use argon2::{password_hash::SaltString, Argon2, PasswordHasher};
use base64::{engine::general_purpose, Engine as _};
use rand::rngs::OsRng;
use x25519_dalek::{EphemeralSecret, PublicKey, SharedSecret};

/// Encrypt message with AES-256-GCM
pub fn encrypt(plaintext: &str, key: &[u8]) -> Result<String, Box<dyn std::error::Error>> {
    let cipher = Aes256Gcm::new_from_slice(key)?;
    let nonce = Nonce::from(OsRng.gen::<[u8; 12]>());
    let ciphertext = cipher.encrypt(&nonce, plaintext.as_bytes())?;
    
    // Encode nonce + ciphertext in base64
    let mut combined = nonce.to_vec();
    combined.extend_from_slice(&ciphertext);
    Ok(general_purpose::STANDARD.encode(&combined))
}

/// Decrypt message with AES-256-GCM
pub fn decrypt(ciphertext_b64: &str, key: &[u8]) -> Result<String, Box<dyn std::error::Error>> {
    let combined = general_purpose::STANDARD.decode(ciphertext_b64)?;
    let nonce = Nonce::from_slice(&combined[..12]);
    let ciphertext = &combined[12..];
    
    let cipher = Aes256Gcm::new_from_slice(key)?;
    let plaintext = cipher.decrypt(nonce, ciphertext)?;
    Ok(String::from_utf8(plaintext)?)
}

/// Generate X25519 keypair for key exchange
pub fn generate_keypair() -> (EphemeralSecret, PublicKey) {
    let secret = EphemeralSecret::random(OsRng);
    let public = PublicKey::from(&secret);
    (secret, public)
}

/// Derive shared secret from X25519 key exchange
pub fn derive_shared_secret(
    our_secret: &EphemeralSecret,
    their_public: &PublicKey,
) -> SharedSecret {
    our_secret.diffie_hellman(their_public)
}

/// Derive encryption key from password using Argon2
pub fn derive_key_from_password(password: &str, salt: &str) -> Result<[u8; 32], Box<dyn std::error::Error>> {
    let argon2 = Argon2::default();
    let salt = SaltString::from_b64(salt)?;
    let hash = argon2.hash_password(password.as_bytes(), &salt)?;
    
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

    #[test]
    fn test_key_exchange() {
        let (alice_secret, alice_public) = generate_keypair();
        let (bob_secret, bob_public) = generate_keypair();
        
        let alice_shared = derive_shared_secret(&alice_secret, &bob_public);
        let bob_shared = derive_shared_secret(&bob_secret, &alice_public);
        
        assert_eq!(alice_shared.as_bytes(), bob_shared.as_bytes());
    }
}
