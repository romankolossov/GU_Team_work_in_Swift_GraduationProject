//
//  MainViewController.swift
//  MariannePictureViewer
//
//  Created by Roman Kolosov on 05.06.2021.
//

import UIKit
import RealmSwift

class ListViewController: UIViewController, AlertShowable {

    // MARK: - Public Properties

    var photos: Results<PhotoElementData>? {
        let photos: Results<PhotoElementData>? = realmManager?.getObjects()
        return photos?.sorted(byKeyPath: "id", ascending: true)
    }
    var isLoading = false

    // MARK: - Private Properties

    private let pictureCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: PhotoLayout()
    )
    private let networkManager: NetworkManager
    private let realmManager = RealmManager.shared
    private var collectionViewPhotoService: CollectionViewPhotoService?
    private var refreshControl: UIRefreshControl?

    // MARK: - Initializers

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupRefreshControl()
        collectionViewPhotoService = CollectionViewPhotoService(
            container: pictureCollectionView
        )
        if let photos = photos, photos.isEmpty {
            loadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureVC()
    }

    // MARK: - Public Methods

    // MARK: Network Load Data Partly used after the Prime Load done

    func loadPartData(from page: Int, completion: (() -> Void)? = nil) {
        let concurrentQueue = DispatchQueue(
            label: "concurrentQueueToLoadPartData",
            qos: .default,
            attributes: .concurrent,
            autoreleaseFrequency: .inherit,
            target: nil
        )
        isLoading = true

        concurrentQueue.async { [weak self] in
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
                    DispatchQueue.main.async { [weak self] in
                        self?.showAlert(
                            title: NSLocalizedString("error", comment: ""),
                            message: error.localizedDescription
                        )
                    }
                }
            }
        }
    }

    // MARK: - Private Methods

    // MARK: Network Load Data Primally

    private func loadData(completion: (() -> Void)? = nil) {
        let concurrentQueue = DispatchQueue(
            label: "concurrentQueueToLoadData",
            qos: .default,
            attributes: .concurrent,
            autoreleaseFrequency: .inherit,
            target: nil
        )
        isLoading = true

        concurrentQueue.async { [weak self] in
            self?.networkManager.loadPhotos { [weak self] result in
                switch result {
                case let .success(photoElements):
                    let photos: [PhotoElementData] = photoElements.map { PhotoElementData(photoElement: $0) }
                    DispatchQueue.main.async { [weak self] in
                        // Clear dictionary and Realm and reload collection view.
                        self?.collectionViewPhotoService?.images.removeAll()
                        try? self?.realmManager?.deleteAll()
                        self?.pictureCollectionView.reloadData()
                        // Add new data in Realm.
                        try? self?.realmManager?.add(objects: photos)
                        self?.pictureCollectionView.reloadData()
                        self?.isLoading = false
                        completion?()
                    }
                case let .failure(error):
                    self?.isLoading = false
                    DispatchQueue.main.async { [weak self] in
                        self?.showAlert(
                            title: NSLocalizedString("error", comment: ""),
                            message: error.localizedDescription
                        )
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource Implementation

extension ListViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: - UICollectionViewDataSource Implementation

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photos = self.photos else { fatalError(description) }
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Configuration.pictureCellIdentifier,
                for: indexPath) as? PictureCollectionViewCell else { fatalError(description) }
        guard let photos = self.photos else { fatalError(description) }

        let photoElementData = photos[indexPath.row]

        cell.lookConfigure(with: photoElementData,
                           photoService: collectionViewPhotoService,
                           indexPath: indexPath)

        return cell
    }

    // MARK: - UICollectionViewDelegate Implementation

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let photos = self.photos else { return }
        let secondVC = DetailViewController()

        let photoElementData = photos[indexPath.row]

        secondVC.lookConfigure(with: photoElementData,
                           photoService: collectionViewPhotoService,
                           indexPath: indexPath)

        self.navigationController?.pushViewController(secondVC, animated: true)
    }
}

// MARK: - Configuration

private extension ListViewController {

    enum Configuration {
        static let pictureCellIdentifier = "com.picture.cell"
    }

    func configureUI() {
        configureCollectionView()
        view.addSubview(pictureCollectionView)
        setupConstraints() // Another a possible implementation: pictureCollectionView.frame = view.bounds
    }

    func configureVC() {
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

    func configureCollectionView() {
        pictureCollectionView.backgroundColor = .pictureCollectionViewBackgroundColor

        pictureCollectionView.dataSource = self
        pictureCollectionView.delegate = self
        pictureCollectionView.prefetchDataSource = self

        pictureCollectionView.register(
            PictureCollectionViewCell.self,
            forCellWithReuseIdentifier: Configuration.pictureCellIdentifier
        )
    }
}

// MARK: - Layout

private extension ListViewController {

    func setupConstraints() {
        pictureCollectionView.translatesAutoresizingMaskIntoConstraints = false

        pictureCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pictureCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pictureCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pictureCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

// MARK: - Pull-to-refresh Implementation

private extension ListViewController {

    @objc func refresh(_ sender: UIRefreshControl) {
        networkManager.nextFromPage = .nextPageAfterFirstToStartLoadingFrom
        loadData { [weak self] in
            self?.refreshControl?.endRefreshing()
        }
    }

    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(
            string: NSLocalizedString(
                "reloadData", comment: ""),
            attributes: [
                .font: UIFont.refreshControlFont,
                .foregroundColor: UIColor.refreshControlForegroundColor
            ]
        )
        refreshControl?.tintColor = .refreshControlTintColor
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)

        pictureCollectionView.refreshControl = refreshControl
    }
}

// MARK: - CollectionViewDataSourcePrefetching (Infinite Scrolling) Implementation

extension ListViewController: UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let photos = self.photos else { return }
        guard let maxIndex = indexPaths.map({ $0.row }).max() else { return }

        if maxIndex > (photos.count - Int.decrementToDefineStartLoading),
           !isLoading {
            self.loadPartData(from: NetworkManager.shared.nextFromPage)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    }
}
