//
//  PhotoLayout.swift
//  MariannePictureViewer
//
//  Created by Roman Kolosov on 05.06.2021.
//

import UIKit

class PhotoLayout: UICollectionViewLayout {

    // MARK: - Private Properties

    private let cellHeight: CGFloat = .pictureCellHeight
    private let columnsCount: Int = .numberOfColumns

    private var totalCellHeight: CGFloat = 0.0
    private var cachedAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
}

// MARK: - Callback Functions to Override

extension PhotoLayout {

    override func prepare() {
        super.prepare()
        self.cachedAttributes = [:]

        guard let collectionView = self.collectionView else { return }

        let itemsCount = collectionView.numberOfItems(inSection: 0)
        guard itemsCount > 0 else { return }

        let bigCellWidth = collectionView.bounds.size.width
        let smallCellWidth = ceil(collectionView.bounds.size.width / CGFloat(self.columnsCount))

        var lastX: CGFloat = 0
        var lastY: CGFloat = 0

        for index in 0..<itemsCount {
            let indexPath = IndexPath(item: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

            let isBigCell = (index + 1 ) % (self.columnsCount + 1) == 0

            if isBigCell {
                attributes.frame = CGRect(x: 0,
                                          y: lastY,
                                          width: bigCellWidth,
                                          height: self.cellHeight)
                lastY += self.cellHeight
            } else {
                attributes.frame = CGRect(x: lastX,
                                          y: lastY,
                                          width: smallCellWidth,
                                          height: self.cellHeight)

                let isLastColumn = (index + 2) % (self.columnsCount + 1) == 0 ||
                    index == itemsCount - 1

                if isLastColumn {
                    lastX = 0
                    lastY += self.cellHeight
                } else {
                    lastX += smallCellWidth
                }
            }
            cachedAttributes[indexPath] = attributes
        }
        self.totalCellHeight = lastY
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        cachedAttributes.values.filter { attributes in
            rect.intersects(attributes.frame)
        }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cachedAttributes[indexPath]
    }

    override var collectionViewContentSize: CGSize {
        CGSize(width: self.collectionView?.bounds.size.width ?? 0, height: self.totalCellHeight)
    }
}
