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
        
        let contract = web3.eth.Contract(type: NounsDescriptor.self, address: nounId)
        
        guard let function = contract.generateSVG(seed: seed.map { UInt32($0) }) else { return }
        firstly {
            function.call()
        }.done { svg in
            guard let value = svg[""] as? String else { return }
            print("String: \(value)")
        }.catch { error in
            print("error: \(error)")
        }
    }
}

class NounsDescriptor: GenericERC721Contract {
    func generateSVG(seed: [UInt32]) -> SolidityInvocation? {
        guard let type = SolidityType("tuple", subTypes: [UInt48Type, UInt48Type, UInt48Type, UInt48Type, UInt48Type]) else { return nil }
        let constructor = SolidityConstantFunction(name: "generateSVGImage",
                                                   inputs: [SolidityFunctionParameter(name: "seed",
                                                                                      type: type,
                                                                                      components: [SolidityFunctionParameter(name: "background", type: UInt48Type, components: nil),
                                                                                                   SolidityFunctionParameter(name: "body", type: UInt48Type, components: nil),
                                                                                                   SolidityFunctionParameter(name: "accessory", type: UInt48Type, components: nil),
                                                                                                   SolidityFunctionParameter(name: "head", type: UInt48Type, components: nil),
                                                                                                   SolidityFunctionParameter(name: "glasses", type: UInt48Type, components: nil)])],
                                                   outputs: [SolidityFunctionParameter.init(name: "",
                                                                                            type: .string,
                                                                                            components: nil)],
                                                   handler: self)
        
        let values = SolidityTuple(seed.map { SolidityWrappedValue(value: $0, type: UInt48Type) })
        let invocation = constructor.invoke(values)
        return invocation
    }
    
    func getBodyCount() -> SolidityInvocation {
        let constructor = SolidityConstantFunction(name: "bodyCount", outputs: [SolidityFunctionParameter.init(name: "", type: .uint256, components: nil)], handler: self)
        let invocation = constructor.invoke()
        return invocation
    }
    
    func accessories() -> SolidityInvocation {
        let constructor = SolidityConstantFunction(name: "accessories", inputs: [SolidityFunctionParameter(name: "", type: .uint256, components: nil)], outputs: [SolidityFunctionParameter.init(name: "", type: .bytes(length: nil), components: nil)], handler: self)
        return constructor.invoke(2)
    }
}

public let UInt48Type = SolidityType.type(.uint(bits: 48)) // I don't think this actually does anything to convert to 48bit integers

extension BigUInt {
    func as48Bit() -> SolidityWrappedValue {
        return SolidityWrappedValue(value: self, type: UInt48Type)
    }
    
    func wrapped() -> SolidityWrappedValue {
        return SolidityWrappedValue(value: self, type: .uint)
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
