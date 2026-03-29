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
    @State private var showingQRScanner: Bool = false
    @State private var showingQRCode: Bool = false
    @State private var publicKeyQR: UIImage?
    @State private var scannedKey: String = ""
    
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
                
                // Key exchange buttons
                HStack(spacing: 15) {
                    Button(action: { showingQRScanner = true }) {
                        HStack {
                            Image(systemName: "qrcode.viewfinder")
                            Text("Scan Key")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: showMyQR) {
                        HStack {
                            Image(systemName: "qrcode")
                            Text("My Key")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.indigo)
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
                    Menu {
                        Button(action: generateKeyPair) {
                            Label("Generate Keys", systemImage: "key")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [encryptedText])
            }
            .sheet(isPresented: $showingQRScanner) {
                QRCodeScannerView(onCodeScanned: { code in
                    scannedKey = code
                    print("Scanned key: \(code)")
                })
            }
            .sheet(isPresented: $showingQRCode) {
                if let qrImage = publicKeyQR {
                    VStack {
                        Text("My Public Key")
                            .font(.headline)
                            .padding()
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .scaledToFit()
                        Button("Done") {
                            showingQRCode = false
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    func showMyQR() {
        let crypto = CryptoManager.shared
        let (_, publicKey) = crypto.generateKeyPair()
        publicKeyQR = QRCodeGenerator.generateQRCode(from: publicKey.hexEncodedString())
        showingQRCode = true
    }
    
    func encryptMessage() {
        guard !message.isEmpty, !password.isEmpty else { return }
        
        do {
            let crypto = CryptoManager.shared
            encryptedText = try crypto.encrypt(plaintext: message, password: password)
            isEncrypted = true
        } catch {
            encryptedText = "❌ Error: \(error.localizedDescription)"
        }
    }
    
    func decryptMessage() {
        guard !encryptedText.isEmpty, !password.isEmpty else { return }
        
        do {
            let crypto = CryptoManager.shared
            message = try crypto.decrypt(ciphertext: encryptedText, password: password)
            isEncrypted = false
        } catch {
            message = "❌ Error: \(error.localizedDescription)"
        }
    }
    
    func generateKeyPair() {
        let crypto = CryptoManager.shared
        let (privateKey, publicKey) = crypto.generateKeyPair()
        print("🔑 Private Key: \(privateKey.hexEncodedString())")
        print("🔑 Public Key: \(publicKey.hexEncodedString())")
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
