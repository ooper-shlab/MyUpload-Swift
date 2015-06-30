//
//  OOPFormMultipart.swift
//  MyUpload
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/4/22.
//  See LICENSE.txt .
//

import UIKit

extension NSMutableData {
    private func append(string: String) {
        string.withCString {ptr in
            self.appendBytes(ptr, length: string.utf8.count)
        }
    }
}

private enum OOPFormPart {
    case Text(name: String, text: String)
    case Binary(name: String, data: NSData, filename: String, contentType: String)
}

public class OOPFormMultipart {
    private var parts = [OOPFormPart]()
    
    public let boundary = NSUUID().UUIDString
    
    public var contentType: String {
        return "multipart/form-data; boundary=\"\(boundary)\""
    }
    
    private func add(part: OOPFormPart) {
        parts.append(part)
    }
    
    public func addText(text: String, name: String) {
        add(.Text(name: name, text: text))
    }
    
    public func add<T: CustomStringConvertible>(value: T, name: String) {
        add(.Text(name: name, text: value.description))
    }
    
    public func addImageAsJPEG(image: UIImage, name: String, filename: String, compressionQuality: CGFloat = 0.2) {
        let data = UIImageJPEGRepresentation(image, compressionQuality)!
        add(.Binary(name: name, data: data, filename: filename, contentType: "image/jpeg"))
    }
    
    public func addImageAsPNG(image: UIImage, name: String, filename: String) {
        let data = UIImagePNGRepresentation(image)!
        add(.Binary(name: name, data: data, filename: filename, contentType: "image/png"))
    }
    
    public func addBinary(data: NSData, name: String, filename: String, contentType: String) {
        add(.Binary(name: name, data: data, filename: filename, contentType: contentType))
    }
    
    private func generateBody() -> NSData {
        let bodyData = NSMutableData()
        
        for part in parts {
            bodyData.append("--\(boundary)\r\n") // start of part
            switch part {
            case let .Binary(name, data, filename, contentType):
                // part headers for files
                bodyData.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
                bodyData.append("Content-Type: \(contentType)\r\n")
                bodyData.append("\r\n") // empty line declares end of part header
                bodyData.appendData(data) // part body
            case let .Text(name, text):
                // part headers for text
                bodyData.append("Content-Disposition: form-data; name=\"\(name)\"\"\r\n")
                bodyData.append("\r\n") // empty line declares end of part header
                bodyData.append(text) // part body
            }
            bodyData.append("\r\n") // end of part body
        }
        
        bodyData.append("--\(boundary)--") // end of all parts
        
        return bodyData
    }
}

extension NSMutableURLRequest {
    func setMultipart(multipart: OOPFormMultipart) {
        self.HTTPMethod = "POST"
        self.HTTPBody = multipart.generateBody()
        self.addValue(multipart.contentType, forHTTPHeaderField: "Content-Type")
    }
}
