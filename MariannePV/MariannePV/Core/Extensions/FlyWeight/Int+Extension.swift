//
//  Int+Extension.swift
//  MariannePV
//
//  Created by Roman Kolosov on 07.06.2021.
//

import Foundation

extension Int {

    // MARK: - Main VC

    // MARK: Picture collection view layout (Photo layout)

    static let numberOfColumns: Int = 2

    // MARK: - NetworkManager, MainVC

    static let nextPageAfterFirstToStartLoadingFrom: Int = 2

    // MARK: - UICollectionViewDataSourcePrefetching

    static let decrementToDefineStartLoading: Int = 6

    // MARK: - CollectionViewPhotoService

    static let imagesToKeepInRAMCache: Int = 21

}
