//
//  JSONRequest.swift
//  NetworkKit iOS
//
//  Created by Jacob Sikorski on 2018-12-02.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation
import Alamofire
import MapCodableKit

public struct JSONRequest: Request {
    public let parameterEncoding: ParameterEncoding = JSONEncoding.default
    
    public var method: HTTPMethod
    public var path:   String
    public var queryItems: [URLQueryItem]
    public var headers: [String: String]
    public var httpBody: Data?
    
    public init(method: HTTPMethod, path: String, queryItems: [URLQueryItem] = [], headers: [String: String] = [:]) {
        self.method = method
        self.path = path
        self.queryItems = queryItems
        self.headers = [:]
        
        if method.requiresBody {
            self.headers["Content-Type"] = "application/json"
        }
        
        for (key, value) in headers {
            self.headers[key] = value
        }
    }
    
    mutating public func setHTTPBody<T: MapEncodable>(mapEncodable: T, options: JSONSerialization.WritingOptions = []) throws {
        self.httpBody = try mapEncodable.jsonData(options: options)
    }
    
    mutating public func setHTTPBody<T: Encodable>(encodable: T) throws {
        self.httpBody = try JSONEncoder().encode(encodable)
    }
    
    mutating public func setHTTPBody(jsonString: String, encoding: String.Encoding = .utf8) {
        self.httpBody = jsonString.data(using: encoding)
    }
    
    mutating public func setHTTPBody(jsonObject: [String: Any?], options: JSONSerialization.WritingOptions = []) throws {
        self.httpBody = try JSONSerialization.data(withJSONObject: jsonObject, options: options)
    }
    
    // Convenience method.
    mutating public func setHTTPBody<T: MapEncodable>(_ encodable: T) throws {
        try setHTTPBody(mapEncodable: encodable)
    }
    
    mutating public func setHTTPBody<T: Encodable>(_ encodable: T) throws {
        try setHTTPBody(encodable: encodable)
    }
}
