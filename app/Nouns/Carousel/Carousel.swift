//
//  Carousel.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-10-13.
//

import Foundation
import SwiftUI

struct Carousel: UIViewControllerRepresentable {
  typealias UIViewControllerType = CarouselCollectionViewController
  
  @Binding var carouselSelection: CarouselSelection
  
  func makeUIViewController(context: Context) -> CarouselCollectionViewController {
    return CarouselCollectionViewController(carouselSelection: $carouselSelection)
  }
  
  func updateUIViewController(_ uiViewController: CarouselCollectionViewController, context: Context) {
    uiViewController.flowLayout.minimumLineSpacing = carouselSelection == .head ?  50 : 10
    uiViewController.flowLayout.minimumInteritemSpacing = carouselSelection == .head ? 50 : 10
    uiViewController.collectionView.collectionViewLayout.invalidateLayout()
    uiViewController.collectionView.reloadData()
    uiViewController.snapToClosestCell()
  }
}
