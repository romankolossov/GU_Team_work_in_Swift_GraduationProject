//
//  SecondViewController.swift
//  MariannePictureViewer
//
//  Created by Roman Kolosov on 05.06.2021.
//

import UIKit
import SDWebImage

class SecondViewController: UIViewController {

    // MARK: - Private properties

    private lazy var pictureLabel: UILabel = {
        let label = UILabel()
        label.textColor = .pictureLabelTextColor
        label.textAlignment = .center
        label.font = .pictureLabelFont
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var pictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Initializers

    init() {
        super.init(nibName: nil, bundle: nil)
        addSubviews()
        setupConstraints()
    }
    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureSecondVC()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateSubviews()
    }

    // MARK: - Public methods

    func lookConfigure(with photo: PhotoElementData, photoService: CollectionViewPhotoService?, indexPath: IndexPath) {

        guard let photoStringURL = photo.downloadURL else { return }
        pictureLabel.text = "\(NSLocalizedString("author", comment: "")) \(photo.author ?? "")"

        // MARK: - TO DELETE
        /* SDWebImage use for image download */
//        pictureImageView.sd_setImage(with: URL(string: photoStringURL)) { [weak self] (_, _, _, _) in
//            self?.animateSubviews()
//        }
        /* SDWebImage for image download use end */

        /* Way of use RAM, file image caches and network download with CollectionViewPhotoService.
         For more see explanations in PictureCollectionViewCell.swift file.
         In order to use CollectionViewPhotoService, plese
         1. comment the code between "SDWebImage use for image download - SDWebImage use end";
         2. remove comments from the use of photoService for the line bellow;
         3. perform actions following instructions in PictureCollectionViewCell.swift file.
         */
        self.pictureImageView.image = photoService?.getPhoto(atIndexPath: indexPath, byUrl: photoStringURL)
    }

    // MARK: - Private methods

    // MARK: Configure

    private func configureSecondVC() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .navigationBarTintColor

        pictureLabel.alpha = 0.0
        view.backgroundColor = .pictureBackgroundColor

        (UIApplication.shared.delegate as? AppDelegate)?.restrictRotation = .all
    }

    private func addSubviews() {
        view.addSubview(pictureLabel)
        view.addSubview(pictureImageView)
    }

    private func setupConstraints() {
        let indent: CGFloat = .pictureIndent
        let safeArea = view.safeAreaLayoutGuide

        let pictureLabelConstraints = [
            pictureLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: indent * 2),
            pictureLabel.leftAnchor.constraint(equalTo: safeArea.leftAnchor, constant: indent),
            pictureLabel.rightAnchor.constraint(equalTo: safeArea.rightAnchor, constant: -indent),
            pictureLabel.heightAnchor.constraint(equalToConstant: .pictureLabelHeight)
        ]
        let pictureImageViewConstraints = [
            pictureImageView.topAnchor.constraint(equalTo: pictureLabel.bottomAnchor, constant: indent),
            pictureImageView.leftAnchor.constraint(equalTo: safeArea.leftAnchor, constant: indent),
            pictureImageView.rightAnchor.constraint(equalTo: safeArea.rightAnchor, constant: -indent),
            pictureImageView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -indent)
        ]
        NSLayoutConstraint.activate(pictureLabelConstraints)
        NSLayoutConstraint.activate(pictureImageViewConstraints)
    }

    // MARK: Animation methods

    private func animateSubviews() {
        UIView.transition(with: self.pictureLabel,
                          duration: 2.1,
                          options: [.transitionCrossDissolve, .curveEaseInOut],
                          animations: {
                            self.pictureLabel.alpha = 1.0
                          },
                          completion: nil)
    }

}
