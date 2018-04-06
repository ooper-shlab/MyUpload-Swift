//
//  OOPHttpContent.swift
//  MyUpload
//
//  Created by OOPer in cooperation with shlab.jp, on 2018/4/6.
//  See LICENSE.txt .
//

import Foundation

public protocol OOPHttpContent {
    var contentType: String {get}
    func generateBody() -> Data
}

extension URLRequest {
    public mutating func set(_ content: OOPHttpContent) {
        self.httpBody = content.generateBody()
        self.addValue(content.contentType, forHTTPHeaderField: "Content-Type")
    }
}
