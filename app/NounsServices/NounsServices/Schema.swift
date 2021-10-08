//
//  Page.swift
//  Nouns
//
//  Created by Ziad Tamim on 02.10.21.
//

import Foundation

public struct Page<T> {
    public let data: T
}

extension Page: Decodable where T == [Noun] {
    
    private enum DataCodingKeys: String, CodingKey {
        case data
    }
    
    private enum NounsCodingKeys: String, CodingKey {
        case nouns
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DataCodingKeys.self)
        let data = try container.nestedContainer(keyedBy: NounsCodingKeys.self, forKey: .data)
        self.data = try data.decode(T.self, forKey: .nouns)
    }
}

public struct Noun: Decodable {
    public let id: String
    public let owner: Owner
}

public struct Owner: Decodable {
    public let id: String
}
