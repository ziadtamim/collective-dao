//
//  CarouselCollectionViewController.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-10-13.
//

import UIKit
import SwiftUI

enum ScrollDirection {
  case left
  case right
}

enum ScrollContext {
  case freescroll
  case iterate(direction: ScrollDirection)
  case stop
}

class CarouselCollectionViewController: UICollectionViewController {
  let items: Int = 20
  
  private var indexOfCellBeforeDragging: Int? = 0
  var endedCell: IndexPath?
  
  var context: ScrollContext = .freescroll
  @Binding var carouselSelection: CarouselSelection
  
  private var setInsets: Bool = false
  
  private var flowLayout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    return layout
  }()
  
  init(carouselSelection: Binding<CarouselSelection>) {
    self._carouselSelection = carouselSelection
    
    super.init(collectionViewLayout: flowLayout)
    self.collectionView?.layer.borderColor = UIColor.systemBlue.cgColor
    self.collectionView?.layer.borderWidth = 2.0
    self.collectionView?.showsHorizontalScrollIndicator = false
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    guard !setInsets else { return }
    let inset = (collectionView!.frame.width - 200) / 2
    self.collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
    setInsets = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Register cell classes
    self.collectionView?.register(NounPartCollectionViewCell.self, forCellWithReuseIdentifier: NounPartCollectionViewCell.reuseIdentifier)
  }
  
  private func indexOfMajorCell() -> Int? {
    let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
    let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
    let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint)
    return visibleIndexPath?.item
  }
}

// MARK: UICollectionViewDataSource
extension CarouselCollectionViewController {
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NounPartCollectionViewCell.reuseIdentifier, for: indexPath) as? NounPartCollectionViewCell else { return UICollectionViewCell() }
    cell.layer.borderWidth = 2.5
    cell.layer.borderColor = UIColor.red.cgColor
    
    return cell
  }
}

// MARK: UICollectionViewDelegateFlowLayout
extension CarouselCollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 200, height: collectionView.frame.height)
  }
}

// MARK: UIScrollViewDelegate
extension CarouselCollectionViewController {
  override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
      indexOfCellBeforeDragging = indexOfMajorCell()
  }

  override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let iterateThreshold = 0.2
    let freeScrollThreshold = 1.9
    
    let xVelocity = abs(velocity.x)
    
    if xVelocity > freeScrollThreshold {
      context = .freescroll
    } else if xVelocity > iterateThreshold {
      context = .iterate(direction: velocity.x > 0 ? .right : .left)
      
      guard let startIndex = indexOfCellBeforeDragging else { return }
      targetContentOffset.pointee = scrollView.contentOffset
      
      let endIndex = (velocity.x > 0 ? ScrollDirection.right : ScrollDirection.left) == ScrollDirection.right ? min(startIndex + 1, items - 1) : max(startIndex - 1, 0)
      UIView.animate(withDuration: 0.3, animations: { [weak self] in
        self?.collectionViewLayout.collectionView?.scrollToItem(at: IndexPath(item: endIndex, section: 0), at: .centeredHorizontally, animated: true)
      })
    } else {
      context = .stop
      guard let indexOfMajorCell = self.indexOfMajorCell() else { return }

      let indexPath = IndexPath(row: indexOfMajorCell, section: 0)

      UIView.animate(withDuration: 0.3, animations: { [weak self] in
        self?.collectionViewLayout.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
      })
      return
    }
  }
  
  override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
  }
  
  override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    switch context {
    case .freescroll, .stop:
      guard let indexOfMajorCell = self.indexOfMajorCell() else { return }

      let indexPath = IndexPath(row: indexOfMajorCell, section: 0)

      UIView.animate(withDuration: 0.3, animations: { [weak self] in
        self?.collectionViewLayout.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
      })
    default:
      break
    }
  }
}

class NounPartCollectionViewCell: UICollectionViewCell {
  static let reuseIdentifier = "NounPartCell"

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.image = UIImage(named: R.image.glasses.name)
    return imageView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  private func setupViews() {
    print("Setup Views")
    backgroundColor = .clear
    addSubview(imageView)
    
    NSLayoutConstraint.activate([
      imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
      imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
      imageView.heightAnchor.constraint(equalToConstant: 200),
      imageView.widthAnchor.constraint(equalToConstant: 200)
    ])
  }
}
