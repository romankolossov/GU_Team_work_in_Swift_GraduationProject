//
//  NetworkService.swift
//  MariannePV
//
//  Created by Roman Kolosov on 03.09.2021.
//
// NetworkService is to load photos via Lorem Picsum URL then decode photos to get URLs
// in order to use the URLs to load images itself with CollectionViewPhotoService after on

import Foundation
import OSLog

// MARK: - Network Client Protocol

protocol NetworkClient {
    associatedtype Response
    typealias Completion = (Response?, Error?) -> Void

    func networkRequest(for page: Int, completion: @escaping Completion)
}

// MARK: - Network Request & Data Decoding

final class ItemNetworkClient: NetworkClient {
    // Error handling
    enum DecoderError: Error {
        case failureInJSONDecoding
    }
    typealias Response = PhotoQuery
    // URL Session
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        // configuration.allowsCellularAccess = false
        let session = URLSession(configuration: configuration)
        return session
    }()

    func networkRequest(for page: Int, completion: @escaping Completion) {
        // Lorem Picsum URL used, ex. https://picsum.photos/v2/list?page=2&limit=100
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

        // Data to get with the request & decode.
        let dataTask = session.dataTask(with: request) { (data, _, error) in
            if let data = data {
                do {
                    let photos = try JSONDecoder().decode(PhotoQuery.self, from: data)
                    completion(photos, nil)
                } catch {
                    completion(nil, DecoderError.failureInJSONDecoding)
                }
            } else if let error = error {
                Logger.viewCycle.debug(
                    "error in session.dataTask of NetworkService in:\n\(#function)"
                )
                completion(nil, error)
            }
        }
        dataTask.resume()
    }
}

// MARK: - Load Photo Items (or photo URLs, in order by using them after to get photos itself)

final class NetworkService<C: NetworkClient> {
    // Error handling
    enum ServiceError: Error {
        case badResponse
    }
    typealias Completion = ([PhotoElement]?, Error?) -> Void

    var nextFromPage: Int = .nextPageAfterFirstToStartLoadingFrom
    private let client: C

    init(client: C) {
        self.client = client
    }
}

extension NetworkService {

    // Load photos primally.
    func fetchItems(completion: @escaping Completion) {
        let page: Int = 1

        client.networkRequest(for: page) { (response, error) in
            if let error = error {
                completion(nil, error)
            } else if let item = response as? [PhotoElement] {
                completion(item, nil)
            } else { completion(nil, ServiceError.badResponse)
            }
        }
    }

    // Load photos partly page by page. Used after the prime load done.
    func fetchPaginatedItems(from page: Int, completion: @escaping Completion) {
        client.networkRequest(for: page) { (response, error) in
            if let error = error {
                completion(nil, error)
            } else if let item = response as? [PhotoElement] {
                completion(item, nil)
            } else { completion(nil, ServiceError.badResponse)
            }
        }
        // Logger.viewCycle.debug("Photos loaded from page: \(self.nextFromPage)")
        nextFromPage = page + 1
    }
}
