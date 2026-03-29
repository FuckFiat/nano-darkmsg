//
//  Data+Hex.swift
//  NANO Dark Messenger
//
//  Hex encoding helper
//

import Foundation

extension Data {
    func hexEncodedString() -> String {
        map { String(format: "%02hhx", $0) }.joined()
    }
}

extension String {
    func hexToData() -> Data? {
        var data = Data(capacity: count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            var byte = UInt8(byteString, radix: 16)!
            data.append(&byte, count: 1)
        }
        
        return data
    }
}
