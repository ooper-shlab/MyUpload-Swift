//
//  OOPFormMultipart.swift
//  MyUpload
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/4/22.
//  See LICENSE.txt .
//

import UIKit

extension Data {
    fileprivate mutating func append(_ string: String) {
        self.append(string.data(using: .utf8)!)
    }
}

private enum OOPFormPart {
    case text(name: String, text: String)
    case binary(name: String, data: Data, filename: String, contentType: String)
}

public enum OOPFormImageFormat: String {
    case jpeg = "image/jpeg"
    case png = "image/png"
}

open class OOPFormMultipart: OOPHttpContent {
    private var parts = [OOPFormPart]()
    
    open let boundary = UUID().uuidString
    
    open var contentType: String {
        return "multipart/form-data; boundary=\"\(boundary)\""
    }
    
    private func add(_ part: OOPFormPart) {
        parts.append(part)
    }
    
    open func add<T: CustomStringConvertible>(_ value: T, name: String) {
        add(.text(name: name, text: value.description))
    }
    
    open func add(_ image: UIImage, format: OOPFormImageFormat, name: String, filename: String, compressionQuality: CGFloat = 0.2) {
        let data: Data
        switch format {
        case .jpeg:
            data = UIImageJPEGRepresentation(image, compressionQuality)!
        case .png:
            data = UIImagePNGRepresentation(image)!
        }
        add(.binary(name: name, data: data, filename: filename, contentType: format.rawValue))
    }
    
    open func add(_ data: Data, name: String, filename: String, contentType: String) {
        add(.binary(name: name, data: data, filename: filename, contentType: contentType))
    }
    
    public func generateBody() -> Data {
        var bodyData = Data()
        
        for part in parts {
            bodyData.append("--\(boundary)\r\n") // start of part
            switch part {
            case let .binary(name, data, filename, contentType):
                // part headers for files
                bodyData.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
                bodyData.append("Content-Type: \(contentType)\r\n")
                bodyData.append("\r\n") // empty line declares end of part header
                bodyData.append(data) // part body
            case let .text(name, text):
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
