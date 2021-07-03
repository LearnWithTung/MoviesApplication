//
//  NowPlayingFeedViewController.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 02/07/2021.
//

import UIKit

public final class NowPlayingFeedViewController: UICollectionViewController, UICollectionViewDataSourcePrefetching {
    private var refreshController: NowPlayingRefreshController?
        
    var cellControllers = [NowPlayingItemController]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    convenience init(refreshController: NowPlayingRefreshController) {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.refreshController = refreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        refreshController?.refresh()
    }
    
    private func configureCollectionView() {
        collectionView.collectionViewLayout = createLayout(size: view.bounds.size)
        collectionView.refreshControl = refreshController?.view
        collectionView.register(NowPlayingCardFeedCell.self, forCellWithReuseIdentifier: "NowPlayingCardFeedCell")
        collectionView.prefetchDataSource = self
        collectionView.showsVerticalScrollIndicator = false
    }
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellControllers.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellController = cellControllers[indexPath.item]
        
        return cellController.view(collectionView, cellForItemAt: indexPath)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cancelImageLoad(at: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let cellController = cellControllers[indexPath.item]
            cellController.preload()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelImageLoad)
    }
    
    private func cancelImageLoad(at indexPath: IndexPath) {
        let cellController = cellControllers[indexPath.item]
        cellController.cancelLoadImageData()
    }

}

private extension NowPlayingFeedViewController {
    private func createLayout(isLandscape: Bool = false, size: CGSize) -> UICollectionViewLayout {
      return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnv) -> NSCollectionLayoutSection? in

        let leadingItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let leadingItem = NSCollectionLayoutItem(layoutSize: leadingItemSize)
        leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let trailingItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3))
        let trailingItem = NSCollectionLayoutItem(layoutSize: trailingItemSize)
        trailingItem.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let trailingLeftGroup = NSCollectionLayoutGroup.vertical(
          layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0)),
          subitem: trailingItem, count: 2
        )

        let trailingRightGroup = NSCollectionLayoutGroup.vertical(
          layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0)),
          subitem: trailingItem, count: 2
        )

        let fractionalHeight = isLandscape ? NSCollectionLayoutDimension.fractionalHeight(0.8) : NSCollectionLayoutDimension.fractionalHeight(0.4)
        let groupDimensionHeight: NSCollectionLayoutDimension = fractionalHeight

        let rightGroup = NSCollectionLayoutGroup.horizontal(
          layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupDimensionHeight),
          subitems: [leadingItem, trailingLeftGroup, trailingRightGroup]
        )

        let leftGroup = NSCollectionLayoutGroup.horizontal(
          layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupDimensionHeight),
          subitems: [trailingRightGroup, trailingLeftGroup, leadingItem]
        )

        let height = isLandscape ? size.height / 0.9 : size.height / 1.25
        let megaGroup = NSCollectionLayoutGroup.vertical(
          layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(height)),
          subitems: [rightGroup, leftGroup]
        )

        return NSCollectionLayoutSection(group: megaGroup)
      }
    }
}
