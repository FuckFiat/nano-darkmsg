//
//  CryptoManager.swift
//  NANO Dark Messenger
//
//  AES-256-GCM encryption using CryptoKit
//

import Foundation
import CryptoKit

class CryptoManager {
    static let shared = CryptoManager()
    
    private init() {}
    
    /// Encrypt message with AES-256-GCM
    func encrypt(plaintext: String, password: String) throws -> String {
        // Derive key from password using PBKDF2
        let salt = Data((0..<16).map { _ in UInt8.random(in: 0...255) })
        let key = deriveKey(password: password, salt: salt)
        
        // Create symmetric key
        let symmetricKey = SymmetricKey(data: key)
        
        // Encrypt with AES-GCM
        let plaintextData = Data(plaintext.utf8)
        let sealedBox = try AES.GCM.seal(plaintextData, using: symmetricKey)
        
        // Combine salt + nonce + ciphertext
        var combined = salt
        combined += sealedBox.nonce.withUnsafeBytes { Data($0) }
        combined += sealedBox.ciphertext
        
        // Return as base64
        return combined.base64EncodedString()
    }
    
    /// Decrypt message with AES-256-GCM
    func decrypt(ciphertext: String, password: String) throws -> String {
        // Decode base64
        guard let combined = Data(base64Encoded: ciphertext) else {
            throw CryptoError.invalidFormat
        }
        
        // Extract salt, nonce, ciphertext
        guard combined.count > 28 else {
            throw CryptoError.invalidFormat
        }
        
        let salt = combined.prefix(16)
        let nonceRange = 16..<28
        let ciphertextData = combined.suffix(from: 28)
        
        // Derive key
        let key = deriveKey(password: password, salt: salt)
        let symmetricKey = SymmetricKey(data: key)
        
        // Decrypt
        let nonce = try AES.GCM.Nonce(data: Data(combined[nonceRange]))
        let sealedBox = try AES.GCM.SealedBox(
            nonce: nonce,
            ciphertext: ciphertextData
        )
        
        let plaintextData = try AES.GCM.open(sealedBox, using: symmetricKey)
        
        guard let plaintext = String(data: plaintextData, encoding: .utf8) else {
            throw CryptoError.decryptionFailed
        }
        
        return plaintext
    }
    
    /// Derive 256-bit key from password using PBKDF2
    private func deriveKey(password: String, salt: Data) -> Data {
        let passwordData = Data(password.utf8)
        var derivedKey = Data(count: 32)
        
        derivedKey.withUnsafeMutableBytes { derivedKeyBytes in
            CCKeyDerivationPBKDF(
                CCPBKDFAlgorithm(kCCPBKDF2),
                password,
                passwordData.count,
                (salt as NSData).bytes,
                salt.count,
                CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512),
                100000,
                derivedKeyBytes.bindMemory(to: UInt8.self).baseAddress!,
                32
            )
        }
        
        return derivedKey
    }
    
    /// Generate X25519 keypair for key exchange
    func generateKeyPair() -> (privateKey: Data, publicKey: Data) {
        let privateKey = Curve25519.KeyAgreement.PrivateKey()
        let publicKey = privateKey.publicKey
        
        return (
            privateKey.rawRepresentation,
            publicKey.rawRepresentation
        )
    }
    
    /// Derive shared secret using X25519
    func deriveSharedSecret(privateKey: Data, publicKey: Data) throws -> Data {
        let privateKey = try Curve25519.KeyAgreement.PrivateKey(rawRepresentation: privateKey)
        let publicKey = try Curve25519.KeyAgreement.PublicKey(rawRepresentation: publicKey)
        
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
        
        // Derive symmetric key from shared secret using HKDF
        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data(),
            sharedInfo: Data(),
            outputByteCount: 32
        )
        
        return symmetricKey.withUnsafeBytes { Data($0) }
    }
}

enum CryptoError: LocalizedError {
    case invalidFormat
    case decryptionFailed
    case keyDerivationFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat: return "Invalid encrypted message format"
        case .decryptionFailed: return "Failed to decrypt message (wrong password?)"
        case .keyDerivationFailed: return "Failed to derive key"
        }
    }
}
