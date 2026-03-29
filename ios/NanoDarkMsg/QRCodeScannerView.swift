//
//  QRCodeScannerView.swift
//  NANO Dark Messenger
//
//  QR code scanner for key exchange
//

import SwiftUI
import AVFoundation

struct QRCodeScannerView: UIViewControllerRepresentable {
    let onCodeScanned: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: QRCodeScannerView
        
        init(_ parent: QRCodeScannerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            
            if let qrCode = detectQRCode(in: info) {
                parent.onCodeScanned(qrCode)
                parent.dismiss()
            }
            
            picker.dismiss(animated: true)
        }
        
        private func detectQRCode(in info: [UIImagePickerController.InfoKey: Any]) -> String? {
            guard let image = info[.originalImage] as? UIImage,
                  let ciImage = CIImage(image: image) else { return nil }
            
            let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                      context: nil,
                                      options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
            
            let features = detector?.features(in: ciImage)
            let qrCodeFeature = features?.first as? CIQRCodeFeature
            
            return qrCodeFeature?.messageString
        }
    }
}

// QR Code generator
struct QRCodeGenerator {
    static func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            
            if let output = filter.outputImage {
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let scaledImage = output.transformed(by: transform)
                
                return UIImage(ciImage: scaledImage)
            }
        }
        
        return nil
    }
}

#Preview {
    QRCodeScannerView(onCodeScanned: { code in
        print("Scanned: \(code)")
    })
}
