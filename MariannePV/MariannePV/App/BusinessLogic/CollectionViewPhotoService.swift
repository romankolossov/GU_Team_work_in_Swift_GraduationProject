//
//  CollectionViewPhotoService.swift
//  MariannePictureViewer
//
//  Created by Roman Kolosov on 05.06.2021.
//

import UIKit

class CollectionViewPhotoService {

    // MARK: - Nested types

    // Error handling
    enum DecoderError: Error {
        case failureInJSONdecoding
    }

    // MARK: - Public properties

    var images = [String: UIImage]()

    // MARK: - Private properties

    // Create cache files dirrectory
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

    // URLSession
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        // configuration.allowsCellularAccess = false
        let session = URLSession(configuration: configuration)

        return session
    }()

    private let cacheLifeTime: TimeInterval = 1 * 60 * 60
    private let container: UICollectionView?

    // MARK: - Initializers

    init(container: UICollectionView?) {
        self.container = container
    }

    // MARK: - Public methods

    func getPhoto(atIndexPath indexPath: IndexPath, byUrl url: String) -> UIImage? {
        var image: UIImage?

        if let photo = images[url] {
            #if DEBUG
            print("\(url) : RAM cache use with PhotoService")
            #endif
            image = photo
        } else if let photo = getImageFromCache(url: url) {
            #if DEBUG
            print("\(url) : SDD cache file used with PhotoService")
            #endif
            image = photo
        } else {
            #if DEBUG
            print("\(url) : Network download with PhotoService")
            #endif
            // MARK: TO DO: isLoading = true
            loadPhoto(atIndexPath: indexPath, byUrl: url)
        }
        return image
    }

    // MARK: - Private methods

    private func networkRequest(completion: ((Result<[PhotoElementData], Error>) -> Void)? = nil) {
        // Lorem Picsum URL used
        // https://picsum.photos/v2/list?page=2&limit=100

        // URL constructor
        var urlConstructor = URLComponents()

        urlConstructor.scheme = "https"
        urlConstructor.host = "picsum.photos"
        urlConstructor.path = "/v2/list"

        urlConstructor.queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "limit", value: "30")
        ]
        guard let url = urlConstructor.url else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // request.allowsCellularAccess = false

        // Data task
        let dataTask = session.dataTask(with: request) { (data, _, error) in
            if let data = data {
                do {
                    let photoElements = try JSONDecoder().decode(PhotoQuery.self, from: data)
                    let photos: [PhotoElementData] = photoElements.map { PhotoElementData(photoElement: $0) }
                    completion?(.success(photos))
                } catch {
                    completion?(.failure(DecoderError.failureInJSONdecoding))
                }
            } else if let error = error {
                completion?(.failure(error))
            }
        }
        dataTask.resume()
    }

    // MARK: Load from Network method

    private func loadPhoto(atIndexPath indexPath: IndexPath, byUrl url: String) {
        DispatchQueue.global().async { [weak self] in
            self?.networkRequest { [weak self] result in

                switch result {
                case let .success(photoElementsData):
                    let photoElementData = photoElementsData[indexPath.row]

                    guard let photoStringURL = photoElementData.downloadURL else { return }
                    guard let photoURL = URL(string: photoStringURL) else { return }
                    guard let data = try? Data(contentsOf: photoURL) else { return }
                    guard let image = UIImage(data: data) else { return }

                    DispatchQueue.main.async { [weak self] in
                        self?.images[photoStringURL] = image
                    }
                    self?.saveImageToCache(url: photoStringURL, image: image)

                    DispatchQueue.main.async { [weak self] in
                        self?.container?.reloadItems(at: [indexPath])
                        // MARK: TO DO: isLoading = false
                    }
                case let .failure(error):
                    #if DEBUG
                    print(error.localizedDescription)
                    #endif
                }
            }
        }
    }

    // MARK: Cache in file methods

    // Get an image cache file path basing on its url
    private func getFilePath(url: String) -> String? {
        guard let cashesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            else { return nil }

        let hashName = url.split(separator: "/").last ?? "default"
        return cashesDirectory.appendingPathComponent(CollectionViewPhotoService.pathName + "/" + hashName).path
    }

    private func saveImageToCache(url: String, image: UIImage) {
        guard let fileLocalyPath = getFilePath(url: url), let data = image.pngData()
            else { return }

        FileManager.default.createFile(atPath: fileLocalyPath, contents: data, attributes: nil)
    }

    private func getImageFromCache(url: String) -> UIImage? {
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
