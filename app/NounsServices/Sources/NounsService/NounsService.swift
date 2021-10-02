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
    
    private let web3 = Web3(rpcURL: "https://mainnet.infura.io/v3/2abc0ffe9968475ab1858dfdf9d0365a")
    
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
        guard let nounId = try? EthereumAddress(hex: nounId, eip55: true) else { return }
        print("id: \(nounId)")
        do {
            let contract = web3.eth.Contract(type: NounsDescriptor.self, address: nounId)
            let seedBigUInt: [BigUInt] = seed.map { BigUInt($0) }
            
            firstly {
                contract.accessories().call()
            }.done { count in
                guard let value = count[""] as? Data else { return }
                let string = value.toHexString()
                print("String: \(string)")
            }.catch { error in
                print("error: \(error)")
            }
            
        } catch let error {
            print("Error: \(error)")
        }
    }
}

extension Data {
    func hexEncodedString() -> String {
        let format = "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}

class NounsDescriptor: GenericERC721Contract {
    func generateSVG(seed: [BigUInt]) -> SolidityInvocation {
        let constructor = SolidityConstantFunction(name: "generateSVGImage", inputs: [SolidityFunctionParameter(name: "seed", type: .tuple([SolidityType.type(.uint(bits: 48)), SolidityType.type(.uint(bits: 48)), SolidityType.type(.uint(bits: 48)), SolidityType.type(.uint(bits: 48)), SolidityType.type(.uint(bits: 48))]), components: nil)], outputs: [SolidityFunctionParameter.init(name: "", type: .string, components: nil)], handler: self)
        let values = SolidityTuple(seed.map { SolidityWrappedValue(value: $0, type: .type(.uint(bits: 48))) })
        return constructor.invoke(values)
    }
    
    func getBodyCount() -> SolidityInvocation {
        let constructor = SolidityConstantFunction(name: "bodyCount", outputs: [SolidityFunctionParameter.init(name: "", type: .uint256, components: nil)], handler: self)
        return constructor.invoke()
    }
    
    func accessories() -> SolidityInvocation {
        let constructor = SolidityConstantFunction(name: "accessories", inputs: [SolidityFunctionParameter(name: "", type: .uint256, components: nil)], outputs: [SolidityFunctionParameter.init(name: "", type: .bytes(length: nil), components: nil)], handler: self)
        return constructor.invoke(BigUInt(2))
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
