//
//  CollectionViewPhotoService.swift
//  MariannePictureViewer
//
//  Created by Roman Kolosov on 05.06.2021.
//
// CollectionViewPhotoService is to manage loading an image from the Network by its URL
// or from RAM/SSD cache if it is present there, also to store an image in RAM/SSD cache if it is not there

import UIKit
import OSLog

class CollectionViewPhotoService {

    // MARK: - Private properties

    // Image SSD cache files dirrectory to create with pathName
    private static let pathName: String = {
        let pathName = "images"
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            else { return pathName }

        let url = cachesDirectory.appendingPathComponent(pathName, isDirectory: true)

        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return pathName
    }()
    // Image RAM cache dictionary
    private var images = [String: UIImage]()

    // Image SSD cache files life time (in sec.)
    private let cacheLifeTime: TimeInterval = 1 * 60 * 60
    // Container to refresh
    private let container: UICollectionView

    // MARK: - Initializers

    init(container: UICollectionView) {
        self.container = container
    }

    // MARK: - Public methods

    func getImage(atIndexPath indexPath: IndexPath, byUrl url: String) -> UIImage? {
        var image: UIImage?

        if let uncachedImage = images[url] {
            Logger.viewCycle.debug("\(url) : RAM cache used")
            image = uncachedImage
        } else if let uncachedImage = getImageFromFileCache(url: url) {
            Logger.viewCycle.debug("\(url) : SDD cache file used")
            image = uncachedImage
        } else {
            Logger.viewCycle.debug("\(url) : Network load")
            // Place placeholder image while the image is loading from the Network
            image = UIImage(named: "loadingBarSmile")
            // Load the image by its url from the Network and save it to cache
            loadImage(atIndexPath: indexPath, byUrl: url)
        }
        return image
    }

    // MARK: - Private methods

    // MARK: Image from Network load method

    private func loadImage(atIndexPath indexPath: IndexPath, byUrl url: String) {
        guard let imageURL = URL(string: url) else { return }

        // MARK: TO DO: isLoading = true
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: imageURL) else {
                // MARK: TO DO: isLoading = false
                return
            }
            guard let image = UIImage(data: data) else { return }

            DispatchQueue.main.async { [weak self] in
                self?.images[url] = image
                self?.container.reloadItems(at: [indexPath])
                // MARK: TO DO: isLoading = false
            }
            self.saveImageToFileCache(url: url, image: image)
        }
    }

    // MARK: Image SSD file cache methods

    // Get an image cache file path basing on its url
    private func getFilePath(url: String) -> String? {
        guard let cashesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            else { return nil }

        let hashName = url.split(separator: "/").last ?? "default"
        return cashesDirectory.appendingPathComponent(CollectionViewPhotoService.pathName + "/" + hashName).path
    }

    private func saveImageToFileCache(url: String, image: UIImage) {
        guard let fileLocalyPath = getFilePath(url: url),
              let data = image.pngData()
            else { return }

        FileManager.default.createFile(atPath: fileLocalyPath, contents: data, attributes: nil)
    }

    private func getImageFromFileCache(url: String) -> UIImage? {
        guard let fileLocalyPath = getFilePath(url: url),
            let info = try? FileManager.default.attributesOfItem(atPath: fileLocalyPath),
            let modificationDate = info[FileAttributeKey.modificationDate] as? Date
            else { return nil }

        let lifeTime = Date().timeIntervalSince(modificationDate)

        guard lifeTime <= cacheLifeTime,
            let image = UIImage(contentsOfFile: fileLocalyPath)
            else { return nil }

        DispatchQueue.main.async { [weak self] in
            self?.images[url] = image
        }
        return image
    }

}
