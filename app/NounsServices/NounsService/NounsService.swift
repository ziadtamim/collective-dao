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
  
  public init(graphURL: URL) {
    self.graphQL = ApolloGraphQL(url: graphURL)
  }
  
  public func fetchNouns() -> AnyPublisher<NounsListQuery.Data, Error> {
    let query = NounsListQuery()
    return graphQL.fetch(query)
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
}
