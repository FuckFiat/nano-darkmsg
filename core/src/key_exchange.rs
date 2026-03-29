//! NANO Key Exchange Module
//! 
//! X25519 ECDH key exchange with QR code support

use x25519_dalek::{EphemeralSecret, PublicKey};
use rand::rngs::OsRng;
use base64::{engine::general_purpose, Engine as _};
use serde::{Serialize, Deserialize};

/// NANO Key Exchange Package
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct KeyExchangePackage {
    pub version: u8,
    pub public_key: String, // Base64 encoded
    pub fingerprint: String, // Short fingerprint for verification
    pub timestamp: u64,
}

impl KeyExchangePackage {
    /// Create new key exchange package from public key
    pub fn from_public_key(public_key: &PublicKey) -> Self {
        let pk_bytes = public_key.as_bytes();
        let fingerprint = Self::generate_fingerprint(pk_bytes);
        
        KeyExchangePackage {
            version: 1,
            public_key: general_purpose::STANDARD.encode(pk_bytes),
            fingerprint,
            timestamp: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
        }
    }
    
    /// Generate short fingerprint (8 chars) for manual verification
    fn generate_fingerprint(pk_bytes: &[u8; 32]) -> String {
        use sha2::{Digest, Sha256};
        let hash = Sha256::digest(pk_bytes);
        // Use uppercase hex
        hex::encode_upper(&hash[..4])
    }
    
    /// Parse public key from package
    pub fn to_public_key(&self) -> Result<PublicKey, Box<dyn std::error::Error>> {
        let pk_bytes = general_purpose::STANDARD.decode(&self.public_key)?;
        let mut pk_array = [0u8; 32];
        pk_array.copy_from_slice(&pk_bytes[..32]);
        Ok(PublicKey::from(pk_array))
    }
    
    /// Export as QR-compatible string
    pub fn to_qr_string(&self) -> Result<String, Box<dyn std::error::Error>> {
        let json = serde_json::to_string(self)?;
        Ok(format!("NANO:{}", json))
    }
    
    /// Import from QR string
    pub fn from_qr_string(qr_data: &str) -> Result<Self, Box<dyn std::error::Error>> {
        if !qr_data.starts_with("NANO:") {
            return Err("Invalid NANO QR format".into());
        }
        let json = qr_data.trim_start_matches("NANO:");
        Ok(serde_json::from_str(json)?)
    }
}

/// Generate new X25519 keypair
pub fn generate_keypair() -> (EphemeralSecret, PublicKey) {
    let secret = EphemeralSecret::random_from_rng(OsRng);
    let public = PublicKey::from(&secret);
    (secret, public)
}

/// Derive shared secret (takes ownership of secret)
pub fn derive_shared_secret(
    our_secret: EphemeralSecret,
    their_public: &PublicKey,
) -> [u8; 32] {
    let shared = our_secret.diffie_hellman(their_public);
    *shared.as_bytes()
}

/// Complete key exchange - returns shared secret
pub fn perform_key_exchange(
    our_secret: EphemeralSecret,
    their_package: &KeyExchangePackage,
) -> Result<[u8; 32], Box<dyn std::error::Error>> {
    let their_public = their_package.to_public_key()?;
    Ok(derive_shared_secret(our_secret, &their_public))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_key_exchange() {
        // Alice generates keypair
        let (alice_secret, alice_public) = generate_keypair();
        let alice_package = KeyExchangePackage::from_public_key(&alice_public);
        
        // Bob generates keypair
        let (bob_secret, bob_public) = generate_keypair();
        let bob_package = KeyExchangePackage::from_public_key(&bob_public);
        
        // Both derive shared secret (move secrets)
        let alice_shared = perform_key_exchange(alice_secret, &bob_package).unwrap();
        let bob_shared = perform_key_exchange(bob_secret, &alice_package).unwrap();
        
        // Secrets must match
        assert_eq!(alice_shared, bob_shared);
        println!("✅ Shared secret: {}", hex::encode(&alice_shared));
    }

    #[test]
    fn test_qr_export_import() {
        let (_, public) = generate_keypair();
        let package = KeyExchangePackage::from_public_key(&public);
        
        // Export to QR string
        let qr_string = package.to_qr_string().unwrap();
        println!("📱 QR String: {}", qr_string);
        
        // Import back
        let imported = KeyExchangePackage::from_qr_string(&qr_string).unwrap();
        
        assert_eq!(package.fingerprint, imported.fingerprint);
        assert_eq!(package.public_key, imported.public_key);
    }

    #[test]
    fn test_fingerprint() {
        let (_, public) = generate_keypair();
        let package = KeyExchangePackage::from_public_key(&public);
        
        println!("🔑 Fingerprint: '{}' (len={})", package.fingerprint, package.fingerprint.len());
        println!("   Chars: {:?}", package.fingerprint.chars().collect::<Vec<_>>());
        
        // Fingerprint should be 8 hex chars
        assert_eq!(package.fingerprint.len(), 8);
        assert!(package.fingerprint.chars().all(|c| c.is_ascii_hexdigit()), "Not all hex");
    }
}
