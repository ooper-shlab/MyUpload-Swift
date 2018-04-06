//
//  OOPFormUrlencoded.swift
//  MyUpload
//
//  Created by OOPer in cooperation with shlab.jp, on 2018/4/6.
//  See LICENSE.txt .
//

import Foundation

extension CharacterSet {
    static let formUrlencodedSafe = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._*")
}
open class OOPFormUrlencoded: OOPHttpContent {
    public static func serialize(_ value: String) -> String {
        //https://url.spec.whatwg.org/#concept-urlencoded-byte-serializer
        return value.addingPercentEncoding(withAllowedCharacters: .formUrlencodedSafe)!
            .replacingOccurrences(of: " ", with: "+")
    }
    public var serializer: (String)->String = OOPFormUrlencoded.serialize(_:)
    
    private var queryItems: [URLQueryItem] = []
    
    open var contentType: String {
        return "application/x-www-form-urlencoded"
    }
    
    open func generateBody() -> Data {
        return queryItems.map {item in
            serializer(item.name)
                + (item.value != nil ? "=" + serializer(item.value!): "")
        }
        .joined(separator: "&")
        .data(using: .utf8)!
    }
    
    ///Replaces the existing entries of the specified name with the new entry
    ///Or else adds new entry to the end of current items
    public func set<T: CustomStringConvertible>(_ value: T?, name: String) {
        if let index = queryItems.index(where: {$0.name == name}) {
            queryItems = queryItems.filter{$0.name != name}
            let queryItem = URLQueryItem(name: name, value: value?.description)
            queryItems.insert(queryItem, at: index)
        } else {
            add(value, name: name)
        }
    }
    
    ///Replaces the existing entries of the specified name with the new entry with case insensitive comparison
    ///Or else adds new entry to the end of current items
    public func setCaseInsensitive<T: CustomStringConvertible>(_ value: T?, name: String) {
        if let index = queryItems.index(where: {$0.name.caseInsensitiveCompare(name) == .orderedSame}) {
            queryItems = queryItems.filter{$0.name.caseInsensitiveCompare(name) != .orderedSame}
            let queryItem = URLQueryItem(name: name, value: value?.description)
            queryItems.insert(queryItem, at: index)
        } else {
            add(value, name: name)
        }
    }
    
    ///Get all entries of the specified name
    public func get(name: String) -> [URLQueryItem] {
        return queryItems.filter{$0.name == name}
    }
    
    ///Get all entries of the specified name with case insensitive comparison
    public func getCaseInsensitive(name: String) -> [URLQueryItem] {
        return queryItems.filter{$0.name.caseInsensitiveCompare(name) == .orderedSame}
    }
    
    ///Gets or sets of the value of the entry of the specified name
    ///When there are multiple entries for the name,
    /// returns the first entry for `get`, works the same as `set(_:name:)` for `set`
    public subscript(_ name: String) -> String? {
        get {
            if let item = get(name: name).first {
                return item.value
            } else {
                return nil
            }
        }
        set {
            set(newValue, name: name)
        }
    }

    ///Always adds new entry to the end of current items
    public func add<T: CustomStringConvertible>(_ value: T?, name: String) {
        let queryItem = URLQueryItem(name: name, value: value?.description)
        queryItems.append(queryItem)
    }
}
