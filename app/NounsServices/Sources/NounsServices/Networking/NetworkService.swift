//
//  Networking.swift
//  
//
//  Created by Ziad Tamim on 01.10.21.
//

import Foundation
import Combine

public protocol Networking: AnyObject {
    func data(for request: NetworkRequest) -> AnyPublisher<Data, URLError>
}

public class URLSessionNetworkService: Networking {
    private var urlSession: URLSession
    
    public init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    public func data(for request: NetworkRequest) -> AnyPublisher<Data, URLError> {
        urlSession.dataTaskPublisher(for: URLRequest(for: request))
            .map(\.data)
            .eraseToAnyPublisher()
    }
}
