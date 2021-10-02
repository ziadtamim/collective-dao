//
//  NounsService.swift
//  
//
//  Created by Ziad Tamim on 02.10.21.
//

import Foundation
import Combine

import Web3
import Web3PromiseKit
import Web3ContractABI

public class NounsService {
    private let graphQL: GraphQL
    private let jsonDecoder: JSONDecoder
    
    static let infuraKey = "2abc0ffe9968475ab1858dfdf9d0365a"
    static let contract = "0x0Cfdb3Ba1694c2bb2CFACB0339ad7b1Ae5932B63"
    
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
    
    public func generateSVG(_ nounId: String, seed: [Int]) {
        guard let nounId = EthereumAddress(hexString: nounId) else { return }
        let web3 = Web3(rpcURL: "https://mainnet.infura.io/v3/\(NounsService.infuraKey)")
    
        do {
            let contract = web3.eth.Contract(type: NounsContract.self, address: nounId)
            contract.generateSVG(seed: seed).call { results, error in
                print("Results: \(results)")
                print("Error: \(error)")
                print("---")
            }
            
        } catch let error {
            print("Error: \(error)")
        }
    }
}

class NounsContract: GenericERC721Contract {
    func generateSVG(seed: [Int]) -> SolidityInvocation {
        let constructor = SolidityConstantFunction(name: "generateSVGImage", inputs: [SolidityFunctionParameter(name: "seed", type: .tuple([SolidityType.int]), components: nil)], outputs: [SolidityFunctionParameter.init(name: "", type: .string, components: nil)], handler: Handler())
        return constructor.invoke(seed)
    }
}

class Handler: SolidityFunctionHandler {
    var address: EthereumAddress?
    
    func call(_ call: EthereumCall, outputs: [SolidityFunctionParameter], block: EthereumQuantityTag, completion: @escaping ([String : Any]?, Error?) -> Void) {
        //
    }
    
    func send(_ transaction: EthereumTransaction, completion: @escaping (EthereumData?, Error?) -> Void) {
        //
    }
    
    func estimateGas(_ call: EthereumCall, completion: @escaping (EthereumQuantity?, Error?) -> Void) {
        //
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
