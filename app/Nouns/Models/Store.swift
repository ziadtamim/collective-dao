//
//  Store.swift
//  Nouns
//
//  Created by Ziad Tamim on 01.10.21.
//

import Foundation
import Combine
import NounsServices

final class Store {
  private let nounsService: NounsService
  private var subscriptions = Set<AnyCancellable>()
  
  init(nounsService: NounsService = NounsService()) {
    self.nounsService = nounsService
  }
  
  func fetchNouns() {
    nounsService.fetchNouns()
      .sink { completion in
        print(completion)
      } receiveValue: { page in
        print(page)
      }
      .store(in: &subscriptions)
  }
}
