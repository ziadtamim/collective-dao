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
import ApolloSQLite

protocol GraphQL {
  func fetch<T: GraphQLQuery>(_ subscription: T) -> AnyPublisher<T.Data, Error>
  func subscription<T: GraphQLSubscription>(_ query: T) -> AnyPublisher<T.Data, Error>
}

enum GraphError: Error {
  case errors(_ errors: [GraphQLError])
  case emptyResponse
  case retrieveError(Error)
}

public class ApolloGraphQL: GraphQL {
  let url: URL
  let websocketURL: URL
  
  private lazy var store: ApolloStore = {
    let documentsPath = NSSearchPathForDirectoriesInDomains(
      .documentDirectory,
      .userDomainMask,
      true).first!
    let documentsURL = URL(fileURLWithPath: documentsPath)
    let sqliteFileURL = documentsURL.appendingPathComponent("nouns_test.sqlite")
    
    guard let cache = try? SQLiteNormalizedCache(fileURL: sqliteFileURL) else {
      // If SQLite fails for whatever reason (file corrupt, deleted), default to memory cache
      return ApolloStore(cache: InMemoryNormalizedCache())
    }
    
    let store = ApolloStore(cache: cache)
    return store
  }()
  
  /// A web socket transport to use for subscriptions
  private lazy var webSocketTransport: WebSocketTransport = {
    let request = URLRequest(url: websocketURL)
    let webSocketClient = WebSocket(request: request)
    return WebSocketTransport(websocket: webSocketClient, store: store)
  }()
  
  /// An HTTP transport to use for queries and mutations
  private lazy var httpTransport: RequestChainNetworkTransport = {
    return RequestChainNetworkTransport(interceptorProvider: DefaultInterceptorProvider(store: store), endpointURL: url)
  }()
  
  /// A split network transport to allow the use of both of the above
  /// transports through a single `NetworkTransport` instance.
  private lazy var splitNetworkTransport = SplitNetworkTransport(
    uploadingNetworkTransport: self.httpTransport,
    webSocketNetworkTransport: self.webSocketTransport
  )
  
  private(set) lazy var apollo: ApolloClient = ApolloClient(networkTransport: splitNetworkTransport, store: store)
  
  public init(httpURL: URL, websocketURL: URL) {
    self.url = httpURL
    self.websocketURL = websocketURL
    
    self.apollo.cacheKeyForObject = { $0["id"] }
  }
  
  func fetch<T>(_ query: T) -> AnyPublisher<T.Data, Error> where T: GraphQLQuery {
    let subject = PassthroughSubject<T.Data, Error>()
    
    self.apollo.fetch(query: query, cachePolicy: .returnCacheDataAndFetch) { result in
      if let errors = try? result.get().errors {
        subject.send(completion: .failure(GraphError.errors(errors)))
        return
      }
      
      do {
        guard let data = try result.get().data else {
          subject.send(completion: .failure(GraphError.emptyResponse))
          return
        }
        subject.send(data)
      } catch let error {
        subject.send(completion: .failure(GraphError.retrieveError(error)))
      }
    }
    
    return subject.eraseToAnyPublisher()
  }
  
  func subscription<T>(_ subscription: T) -> AnyPublisher<T.Data, Error> where T: GraphQLSubscription {
    let subject = PassthroughSubject<T.Data, Error>()

    self.apollo.subscribe(subscription: subscription) { result in
      if let errors = try? result.get().errors {
        subject.send(completion: .failure(GraphError.errors(errors)))
        return
      }
      
      do {
        guard let data = try result.get().data else {
          subject.send(completion: .failure(GraphError.emptyResponse))
          return
        }
        subject.send(data)
      } catch let error {
        subject.send(completion: .failure(GraphError.retrieveError(error)))
      }
    }
    
    return subject.eraseToAnyPublisher()
  }
}
