//
//  GraphQL.swift
//  
//
//  Created by Ziad Tamim on 01.10.21.
//

import Foundation
import Combine
import Apollo
import ApolloWebSocket

protocol GraphQL {
  func fetch<T: GraphQLQuery>(_ query: T) -> AnyPublisher<T.Data, Error>
  func subscription() -> AnyPublisher<Data, Error>
}

enum GraphError: Error {
  case errors(_ errors: [GraphQLError])
  case emptyResponse
  case retrieveError(Error)
}

public class ApolloGraphQL: GraphQL {
  private(set) var apollo: ApolloClient
  
  public init(url: URL) {
    self.apollo = ApolloClient(url: url)
  }
  
  func fetch<T>(_ query: T) -> AnyPublisher<T.Data, Error> where T: GraphQLQuery {
    let future = Future<T.Data, Error> { promise in
      self.apollo.fetch(query: query) { result in
        if let errors = try? result.get().errors {
          promise(.failure(GraphError.errors(errors)))
          return
        }
        
        do {
          guard let data = try result.get().data else {
            promise(.failure(GraphError.emptyResponse))
            return
          }
          promise(.success(data))
        } catch let error {
          promise(.failure(GraphError.retrieveError(error)))
        }
      }
    }
    
    return future.eraseToAnyPublisher()
  }
  
  func subscription() -> AnyPublisher<Data, Error> {
    return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
  }
}
