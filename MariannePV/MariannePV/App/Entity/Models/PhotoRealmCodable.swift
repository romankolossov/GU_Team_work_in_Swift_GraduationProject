//
//  PhotoRealmCodable.swift
//  MariannePictureViewer
//
//  Created by Roman Kolosov on 05.06.2021.
//

import Foundation
import RealmSwift

// MARK: - View model. Data to save Realm ready

class PhotoElementData: Object {
    @objc dynamic var id: String?
    @objc dynamic var author: String?
    @objc dynamic var downloadURL: String?

    override class func primaryKey() -> String? {
        "id"
    }
    override static func indexedProperties() -> [String] {
        ["id"]
    }

    init(photoElement: PhotoElement) {
        self.id = photoElement.id
        self.author = photoElement.author
        self.downloadURL = photoElement.downloadURL
    }

    override required init() {
        super.init()
    }
}

// MARK: - PhotoElement Realm ready

class PhotoElement: Object, Codable {
    @objc dynamic var id: String = ""
    @objc dynamic var author: String = ""
    @objc dynamic var width: Int = 0
    @objc dynamic var height: Int = 0
    @objc dynamic var url: String = ""
    @objc dynamic var downloadURL: String = ""

    enum CodingKeys: String, CodingKey {
        case id, author, width, height, url
        case downloadURL = "download_url"
    }

    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        let author = try container.decodeIfPresent(String.self, forKey: .author) ?? ""
        let width = try container.decodeIfPresent(Int.self, forKey: .width) ?? 0
        let height = try container.decodeIfPresent(Int.self, forKey: .height) ?? 0
        let url = try container.decodeIfPresent(String.self, forKey: .url) ?? ""
        let downloadURL = try container.decodeIfPresent(String.self, forKey: .downloadURL) ?? ""

        self.init(id: id, author: author, width: width, height: height, url: url, downloadURL: downloadURL)
    }

    convenience init(id: String, author: String, width: Int, height: Int, url: String, downloadURL: String) {
        self.init()
        self.id = id
        self.author = author
        self.width = width
        self.height = height
        self.url = url
        self.downloadURL = downloadURL
    }

    override required init() {
        super.init()
    }
}

typealias PhotoQuery = [PhotoElement]
