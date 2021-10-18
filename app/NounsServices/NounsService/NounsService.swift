//
//  NounsService.swift
//  
//
//  Created by Ziad Tamim on 02.10.21.
//

import Foundation
import Combine

public class NounsService {
  private let graphQL: GraphQL
  
  public init(httpURL: URL, websocketURL: URL) {
    let graphQL = ApolloGraphQL(httpURL: httpURL, websocketURL: websocketURL)
    self.graphQL = graphQL
  }
  
  public func fetchNouns() -> AnyPublisher<NounsListQuery.Data, Error> {
    let query = NounsListQuery()
    return graphQL.fetch(query)
  }
  
  public func subscribeToAuctions() -> AnyPublisher<LatestAuctionSubscription.Data, Error> {
    let subscription = LatestAuctionSubscription()
    return graphQL.subscription(subscription)
  }
}

public extension NounsService {
  
  static let nounsSubgraphURL: URL? = {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "api.thegraph.com"
    urlComponents.path = "/subgraphs/name/nounsdao/nouns-subgraph"
    return urlComponents.url
  }()
  
  static let nounsWebsocketURL: URL? = {
    var urlComponents = URLComponents()
    urlComponents.scheme = "wss"
    urlComponents.host = "api.thegraph.com"
    urlComponents.path = "/subgraphs/name/nounsdao/nouns-subgraph"
    return urlComponents.url
  }()
}
