//
//  ResponseInterface+Extensions.swift
//  NetworkKit iOS
//
//  Created by Jacob Sikorski on 2019-02-21.
//  Copyright © 2019 Jacob Sikorski. All rights reserved.
//

import Foundation

public extension ResponseInterface where T == Data? {
    
    /// Attempt to unwrap the response data.
    ///
    /// - Returns: The unwrapped object
    func unwrapData() throws -> Data {
        // Check if we have the data we need
        guard let unwrappedData = data else {
            throw SerializationError.unexpectedEmptyResponse
        }
        
        return unwrappedData
    }
    
    /// Attempt to deserialize the response data into a JSON string.
    ///
    /// - Returns: The decoded object
    func decodeString(encoding: String.Encoding = .utf8) throws -> String {
        let data = try unwrapData()
        
        // Attempt to deserialize the object.
        guard let string = String(data: data, encoding: encoding) else {
            throw SerializationError.failedToDecodeResponseData(cause: nil)
        }
        
        return string
    }
    
    /// Attempt to Decode the response data into a Decodable object.
    ///
    /// - Returns: The decoded object
    func decode<D: Decodable>(_ type: D.Type, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .rfc3339) throws  -> D {
        let data = try self.unwrapData()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        
        do {
            // Attempt to deserialize the object.
            return try decoder.decode(D.self, from: data)
        } catch {
            // Wrap this error so that we're controlling the error type and return a safe message to the user.
            throw SerializationError.failedToDecodeResponseData(cause: error)
        }
    }
}

public extension ResponseInterface where Self.T == Data? {
    func debug() {
        print("===========================================")
        printRequest()
        print("-------------------------------------------")
        printResponse()
        print("===========================================")
    }
    
    func printRequest() {
        print("REQUEST [\(urlRequest.httpMethod!)] \(urlRequest.url!)")
        
        if let headersString = urlRequest.allHTTPHeaderFields?.map({ "    \($0): \($1)" }).joined(separator: "\n") {
            print("Headers:\n\(headersString)")
        }
        
        if let body = urlRequest.httpBody {
            if let json = String(data: body, encoding: .utf8) {
                print("Body: \(json)")
            } else {
                print("Body: [Not JSON]")
            }
        }
    }
    
    func printResponse() {
        print("RESPONSE [\(urlRequest.httpMethod!)] (\(statusCode.rawValue)) \(urlRequest.url!)")
        
        let headersString = httpResponse.allHeaderFields.map({ "    \($0): \($1)" }).joined(separator: "\n")
        print("Headers:\n\(headersString)")
        
        if data != nil {
            do {
                let json = try decodeString(encoding: .utf8)
                print("Body: \(json)")
            } catch {
                print("Body: \(error)")
            }
        }
    }
}
