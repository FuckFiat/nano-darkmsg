//
//  ContentView.swift
//  NANO Dark Messenger
//
//  Main UI: Encrypt/Decrypt messages
//

import SwiftUI
import CryptoKit

struct ContentView: View {
    @State private var message: String = ""
    @State private var password: String = ""
    @State private var encryptedText: String = ""
    @State private var isEncrypted: Bool = false
    @State private var showingShareSheet: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Message input
                TextEditor(text: $message)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .frame(height: 150)
                    .placeholder(when: message.isEmpty) {
                        Text("Enter message to encrypt...")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 15)
                    }
                
                // Password field
                SecureField("Shared secret password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                // Action buttons
                HStack(spacing: 15) {
                    Button(action: encryptMessage) {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Encrypt")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: decryptMessage) {
                        HStack {
                            Image(systemName: "lock.open.fill")
                            Text("Decrypt")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                
                // Result
                if !encryptedText.isEmpty {
                    TextEditor(text: $encryptedText)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .frame(height: 200)
                        .font(.system(.caption, design: .monospaced))
                    
                    Button(action: { showingShareSheet = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("🌑 NANO DarkMsg")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: generateKeyPair) {
                        Image(systemName: "key")
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [encryptedText])
            }
        }
    }
    
    func encryptMessage() {
        guard !message.isEmpty, !password.isEmpty else { return }
        
        // TODO: Implement AES-256-GCM encryption
        // For now, simple base64 encoding as placeholder
        if let data = message.data(using: .utf8) {
            encryptedText = "NANO:ENCRYPTED:" + data.base64EncodedString()
            isEncrypted = true
        }
    }
    
    func decryptMessage() {
        guard !encryptedText.isEmpty, !password.isEmpty else { return }
        
        // TODO: Implement AES-256-GCM decryption
        if encryptedText.hasPrefix("NANO:ENCRYPTED:") {
            let base64String = encryptedText.replacingOccurrences(of: "NANO:ENCRYPTED:", with: "")
            if let data = Data(base64Encoded: base64String),
               let decrypted = String(data: data, encoding: .utf8) {
                message = decrypted
                isEncrypted = false
            }
        }
    }
    
    func generateKeyPair() {
        // TODO: Generate X25519 keypair for key exchange
        print("Generate keypair tapped")
    }
}

// Placeholder modifier
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// Share sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ContentView()
}
