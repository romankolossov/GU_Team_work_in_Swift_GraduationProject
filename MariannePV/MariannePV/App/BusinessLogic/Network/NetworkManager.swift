//
//  NetworkManager.swift
//  MariannePictureViewer
//
//  Created by Roman Kolosov on 05.06.2021.
//

import Foundation
import OSLog

class NetworkManager {

    static let shared = NetworkManager()
    private init() {}

    // MARK: - Nested types

    // Error handling
    enum NetworkError: Error {
        case incorrectData
    }
    enum DecoderError: Error {
        case failureInJSONdecoding
    }

    // MARK: - Public properties

    var nextFromPage: Int = .nextPageAfterFirstToStartLoadingFrom

    // MARK: - Private properties

    // URLSession
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        // configuration.allowsCellularAccess = false
        let session = URLSession(configuration: configuration)

        return session
    }()

    // MARK: - Public methods

    // MARK: Network load methods

    func loadPhotos(completion: ((Result<[PhotoElement], NetworkError>) -> Void)? = nil) {
        let page: Int = 1

        networkRequest(for: page) {result in
            switch result {
            case let .success(photos):
                completion?(.success(photos as? [PhotoElement] ?? []))
            case .failure:
                completion?(.failure(.incorrectData))
            }
        }
    }

    func loadPartPhotos(from page: Int, completion: ((Result<[PhotoElement], NetworkError>) -> Void)? = nil) {
        networkRequest(for: page) {result in
            switch result {
            case let .success(photos):
                completion?(.success(photos as? [PhotoElement] ?? []))
            case .failure:
                completion?(.failure(.incorrectData))
            }
        }
        Logger.viewCycle.debug("Photos loaded from page: \(NetworkManager.shared.nextFromPage)")

        NetworkManager.shared.nextFromPage = page + 1
    }

    // MARK: - Private methods

    private func networkRequest(for page: Int, completion: ((Result<[Any], Error>) -> Void)? = nil) {
        // Lorem Picsum URL used
        // https://picsum.photos/v2/list?page=2&limit=100

        guard page >= 1 else { return }

        // URL constructor
        var urlConstructor = URLComponents()

        urlConstructor.scheme = "https"
        urlConstructor.host = "picsum.photos"
        urlConstructor.path = "/v2/list"

        urlConstructor.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
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
                    let photos = try JSONDecoder().decode(PhotoQuery.self, from: data)
                    completion?(.success(photos))
                } catch {
                    completion?(.failure(DecoderError.failureInJSONdecoding))
                }
            } else if let error = error {
                Logger.viewCycle.debug(
                    "error in session.dataTask of NetworkManager in:\n\(#function)"
                )
                completion?(.failure(error))
            }
        }
        dataTask.resume()
    }

}
