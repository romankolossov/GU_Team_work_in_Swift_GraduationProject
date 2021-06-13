//
//  MainViewController.swift
//  MariannePictureViewer
//
//  Created by Roman Kolosov on 05.06.2021.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, AlertShowable {

    // MARK: - Public properties

    var publicPictureCellIdentifier: String {
        pictureCellIdentifier
    }
    var publicCollectionViewPhotoService: CollectionViewPhotoService? {
        collectionViewPhotoService
    }
    var publicNetworkManager: NetworkManager {
        networkManager
    }
    var photos: Results<PhotoElementData>? {
        let photos: Results<PhotoElementData>? = realmManager?.getObjects()
        return photos?.sorted(byKeyPath: "id", ascending: true)
    }
    var isLoading: Bool = false

    // MARK: - Private properties

    private let pictureCellIdentifier: String = "PictureCellIdentifier"
    private var collectionViewPhotoService: CollectionViewPhotoService?
    private let networkManager = NetworkManager.shared
    private let realmManager = RealmManager.shared
    private var pictureCollectionView: UICollectionView?
    private var refreshControl: UIRefreshControl?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        (UIApplication.shared.delegate as? AppDelegate)?.restrictRotation = .portrait

        configureMainVC()
        configureCollectionView()

        setupRefreshControl()
        collectionViewPhotoService = CollectionViewPhotoService(container: pictureCollectionView)

        if let photos = photos, photos.isEmpty {
            loadData()
        }
    }

    // MARK: - Actions

    @objc private func refresh(_ sender: UIRefreshControl) {
        NetworkManager.shared.nextFromPage = .nextPageAfterFirstToStartLoadingFrom

        self.loadData { [weak self] in
            self?.refreshControl?.endRefreshing()
        }
    }

    // MARK: - Public methods

    // MARK: Network methods

    func loadPartData(from page: Int, completion: (() -> Void)? = nil) {
        DispatchQueue.global().async { [weak self] in
            self?.networkManager.loadPartPhotos(from: page) { [weak self] result in

                switch result {
                case let .success(photoElements):
                    let nextPhotos: [PhotoElementData] = photoElements.map { PhotoElementData(photoElement: $0) }
                    DispatchQueue.main.async { [weak self] in
                        try? self?.realmManager?.add(objects: nextPhotos)
                        self?.pictureCollectionView?.reloadData()
                        self?.isLoading = false
                        completion?()
                    }
                case let .failure(error):
                    self?.showAlert(
                        title: NSLocalizedString("error", comment: ""),
                        message: error.localizedDescription
                    )
                }
            }
        }
    }

    // MARK: - Private methods

    // MARK: Configure

    private func configureMainVC() {
        self.title = NSLocalizedString("mainVCName", comment: "Main view controller name")

        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func configureCollectionView() {
        // Custom layout
        let layout = PhotoLayout()

        pictureCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        pictureCollectionView?.backgroundColor = .pictureCollectionViewBackgroundColor

        pictureCollectionView?.dataSource = self
        pictureCollectionView?.delegate = self
        pictureCollectionView?.prefetchDataSource = self

        pictureCollectionView?.register(PictureCollectionViewCell.self, forCellWithReuseIdentifier: publicPictureCellIdentifier)

        guard let collectionSubview = pictureCollectionView else {
            return
        }
        self.view.addSubview(collectionSubview)
    }

    // MARK: Network methods

    private func loadData(completion: (() -> Void)? = nil) {
        DispatchQueue.global().async { [weak self] in
            self?.networkManager.loadPhotos { [weak self] result in

                switch result {
                case let .success(photoElements):
                    let photos: [PhotoElementData] = photoElements.map { PhotoElementData(photoElement: $0) }
                    DispatchQueue.main.async { [weak self] in
                        try? self?.realmManager?.deleteAll()
                        try? self?.realmManager?.add(objects: photos)
                        self?.pictureCollectionView?.reloadData()
                        self?.isLoading = false
                        completion?()
                    }
                case let .failure(error):
                    self?.showAlert(
                        title: NSLocalizedString("error", comment: ""),
                        message: error.localizedDescription
                    )
                }
            }
        }
    }

    // MARK: Pull-to-refresh pattern method

    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()

        refreshControl?.attributedTitle = NSAttributedString(string: NSLocalizedString("reloadData", comment: ""), attributes: [.font: UIFont.refreshControlFont])
        refreshControl?.tintColor = .systemOrange
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)

        pictureCollectionView?.refreshControl = refreshControl
    }

}
