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
    private let jsonDecoder: JSONDecoder
    
    public init(graphQL: GraphQL = GraphQL(), jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.graphQL = graphQL
        self.jsonDecoder = jsonDecoder
    }
    
    public func fetchNouns() -> AnyPublisher<Page<[Noun]>, Error> {
        guard let url = nounsSubgraphURL else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        let operation = GraphQL.Operation(
          url: url,
          query: """
                    {
                      nouns {
                        id
                        seed {
                          background
                          body
                          accessory
                          head
                          glasses
                        }
                        owner {
                          id
                        }
                      }
                    }
                """
        )
        
        return graphQL.query(operation)
            .decode(type: Page<[Noun]>.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
     
}

private extension NounsService {
    
    var nounsSubgraphURL: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.thegraph.com"
        urlComponents.path = "/subgraphs/name/nounsdao/nouns-subgraph"
        return urlComponents.url
    }
}
