//
//  NetworkRequest.swift
//  
//
//  Created by Ziad Tamim on 01.10.21.
//

import Foundation

public protocol NetworkRequest {
    var url: URL { get }
}

public struct NetworkDataRequest: NetworkRequest {
    public var url: URL
    public var httpMethod: HTTPMethod
    public var httpBody: Data?
    
    init(url: URL, httpMethod: HTTPMethod = .get, httpBody: Data?) {
        self.url = url
        self.httpMethod = httpMethod
        self.httpBody = httpBody
    }
}

extension URLRequest {
    
    public init(for request: NetworkRequest) {
        var urlRequest = URLRequest(url: request.url)
        if let dataRequest = request as? NetworkDataRequest {
            if case .post(let contentType) = dataRequest.httpMethod, contentType == .json {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            urlRequest.httpMethod = dataRequest.httpMethod.description
            urlRequest.httpBody = dataRequest.httpBody
        }
        
        self = urlRequest
    }
}
