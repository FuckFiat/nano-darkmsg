package com.zerocool.nanodarkmsg

import android.util.Base64
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec
import java.security.SecureRandom
import java.security.MessageDigest

/**
 * NANO Crypto Manager — AES-256-GCM encryption
 */
object NanoCrypto {
    
    private const val AES_MODE = "AES/GCM/NoPadding"
    private const val GCM_IV_LENGTH = 12
    private const val GCM_TAG_LENGTH = 128
    private const val KEY_LENGTH = 256
    
    /**
     * Encrypt message with AES-256-GCM
     */
    fun encrypt(plaintext: String, password: String): String {
        // Derive key from password
        val key = deriveKey(password)
        
        // Generate random IV
        val iv = ByteArray(GCM_IV_LENGTH)
        SecureRandom().nextBytes(iv)
        
        // Create cipher
        val cipher = Cipher.getInstance(AES_MODE)
        val spec = GCMParameterSpec(GCM_TAG_LENGTH, iv)
        cipher.init(Cipher.ENCRYPT_MODE, key, spec)
        
        // Encrypt
        val ciphertext = cipher.doFinal(plaintext.toByteArray())
        
        // Combine IV + ciphertext
        val combined = iv + ciphertext
        
        // Return as base64
        return Base64.encodeToString(combined, Base64.NO_WRAP)
    }
    
    /**
     * Decrypt message with AES-256-GCM
     */
    fun decrypt(ciphertextBase64: String, password: String): String {
        // Decode base64
        val combined = Base64.decode(ciphertextBase64, Base64.NO_WRAP)
        
        // Extract IV and ciphertext
        val iv = combined.sliceArray(0 until GCM_IV_LENGTH)
        val ciphertext = combined.sliceArray(GCM_IV_LENGTH until combined.size)
        
        // Derive key
        val key = deriveKey(password)
        
        // Create cipher
        val cipher = Cipher.getInstance(AES_MODE)
        val spec = GCMParameterSpec(GCM_TAG_LENGTH, iv)
        cipher.init(Cipher.DECRYPT_MODE, key, spec)
        
        // Decrypt
        val plaintext = cipher.doFinal(ciphertext)
        
        return String(plaintext)
    }
    
    /**
     * Derive 256-bit key from password using PBKDF2
     */
    private fun deriveKey(password: String): SecretKey {
        // Simple SHA-256 hash for now (TODO: proper PBKDF2)
        val md = MessageDigest.getInstance("SHA-256")
        val keyBytes = md.digest(password.toByteArray())
        return SecretKeySpec(keyBytes, "AES")
    }
    
    /**
     * Generate random password
     */
    fun generatePassword(length: Int = 32): String {
        val chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*"
        return (1..length)
            .map { chars.random() }
            .joinToString("")
    }
}
