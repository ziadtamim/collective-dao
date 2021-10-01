//
//  GraphQL.swift
//  
//
//  Created by Ziad Tamim on 01.10.21.
//

import Foundation
import Combine

public class GraphQL {
    
    public struct Operation: Encodable {
        public let url: URL
        public let query: String
        
        public init(url: URL, query: String) {
            self.url = url
            self.query = query
        }
        
        private enum CodingKeys: String, CodingKey {
            case query
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(query, forKey: .query)
        }
    }
    
    private let networkService: Networking
    
    public init(networkService: Networking = URLSessionNetworkService()) {
        self.networkService = networkService
    }
    
    public func query(_ operation: Operation) -> AnyPublisher<Data, Error> {
        do {
            let request = NetworkDataRequest(
                url: operation.url,
                httpMethod: .post(contentType: .json),
                httpBody: try JSONEncoder().encode(operation)
            )
            return networkService.data(for: request)
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
            
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
