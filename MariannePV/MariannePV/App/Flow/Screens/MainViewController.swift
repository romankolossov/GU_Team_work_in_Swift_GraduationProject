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

    private lazy var pictureCollectionView: UICollectionView = {
        // Custom layout
        let layout = PhotoLayout()
        let safeArea = view.safeAreaLayoutGuide

        let cv = UICollectionView(
            frame: safeArea.layoutFrame,
            collectionViewLayout: layout
        )
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .pictureCollectionViewBackgroundColor

        cv.dataSource = self
        cv.delegate = self
        cv.prefetchDataSource = self

        cv.register(PictureCollectionViewCell.self, forCellWithReuseIdentifier: publicPictureCellIdentifier)

        return cv
    }()

    private let pictureCellIdentifier: String = "PictureCellIdentifier"
    private let networkManager = NetworkManager.shared
    private let realmManager = RealmManager.shared
    private var collectionViewPhotoService: CollectionViewPhotoService?
    private var refreshControl: UIRefreshControl?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupRefreshControl()
        collectionViewPhotoService = CollectionViewPhotoService(container: pictureCollectionView)

        if let photos = photos, photos.isEmpty {
            loadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureMainVC()
    }

    // MARK: - Actions

    @objc private func refresh(_ sender: UIRefreshControl) {
        loadData { [weak self] in
            self?.refreshControl?.endRefreshing()
        }
        NetworkManager.shared.nextFromPage = .nextPageAfterFirstToStartLoadingFrom
    }

    // MARK: - Public methods

    // MARK: Network method

    func loadPartData(from page: Int, completion: (() -> Void)? = nil) {
        isLoading = true
        DispatchQueue.global().async { [weak self] in
            self?.networkManager.loadPartPhotos(from: page) { [weak self] result in
                switch result {

                case let .success(photoElements):
                    let nextPhotos: [PhotoElementData] = photoElements.map { PhotoElementData(photoElement: $0) }
                    DispatchQueue.main.async { [weak self] in
                        try? self?.realmManager?.add(objects: nextPhotos)
                        self?.pictureCollectionView.reloadData()
                        self?.isLoading = false
                        completion?()
                    }
                case let .failure(error):
                    self?.isLoading = false
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
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.navigationBarLargeTitleTextColor
        ]
        title = NSLocalizedString("mainVCName", comment: "Main view controller name")

        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.navigationBarTitleTextColor
        ]
        (UIApplication.shared.delegate as? AppDelegate)?.restrictRotation = .portrait
    }

    private func addSubviews() {
        view.addSubview(pictureCollectionView)
    }

    // MARK: Network method

    private func loadData(completion: (() -> Void)? = nil) {
        isLoading = true
        DispatchQueue.global().async { [weak self] in
            self?.networkManager.loadPhotos { [weak self] result in
                switch result {

                case let .success(photoElements):
                    let photos: [PhotoElementData] = photoElements.map { PhotoElementData(photoElement: $0) }
                    DispatchQueue.main.async { [weak self] in
                        try? self?.realmManager?.deleteAll()
                        try? self?.realmManager?.add(objects: photos)
                        self?.pictureCollectionView.reloadData()
                        self?.isLoading = false
                        completion?()
                    }
                case let .failure(error):
                    self?.isLoading = false
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

        refreshControl?.attributedTitle = NSAttributedString(
            string: NSLocalizedString("reloadData", comment: ""), attributes: [.font: UIFont.refreshControlFont]
        )
        refreshControl?.tintColor = .systemOrange
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)

        pictureCollectionView.refreshControl = refreshControl
    }

}
