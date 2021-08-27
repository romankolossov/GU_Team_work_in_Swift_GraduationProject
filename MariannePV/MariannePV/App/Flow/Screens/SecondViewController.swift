//
//  SecondViewController.swift
//  MariannePictureViewer
//
//  Created by Roman Kolosov on 05.06.2021.
//

import UIKit

class SecondViewController: UIViewController {

    // MARK: - Private Properties

    private let pictureLabel = UILabel()
    private let pictureImageView = UIImageView()

    // MARK: - Initializers

    init() {
        super.init(nibName: nil, bundle: nil)
        configureUI()
        // setupConstraints()
    }
    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureVC()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateSubviews()
    }
}

// MARK: - Configuration

extension SecondViewController {

    func lookConfigure(with photo: PhotoElementData, photoService: CollectionViewPhotoService?, indexPath: IndexPath) {
        guard let photoStringURL = photo.downloadURL else { return }

        pictureLabel.text = "\(NSLocalizedString("author", comment: "")) \(photo.author ?? "")"
        pictureImageView.image = photoService?.getImage(atIndexPath: indexPath, byUrl: photoStringURL)
    }
}

private extension SecondViewController {

    func configureUI() {
        configureSubviews()
        view.addSubview(pictureLabel)
        view.addSubview(pictureImageView)
    }

    func configureVC() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .navigationBarTintColor

        pictureLabel.alpha = 0.0
        view.backgroundColor = .pictureBackgroundColor

        (UIApplication.shared.delegate as? AppDelegate)?.restrictRotation = .all
    }

    func configureSubviews() {
        pictureLabel.textColor = .pictureLabelTextColor
        pictureLabel.textAlignment = .center
        pictureLabel.font = .pictureLabelFont

        pictureImageView.contentMode = .scaleAspectFit
    }
}

// MARK: - Layout

private extension SecondViewController {

    func setupConstraints() {
        let indent: CGFloat = .pictureIndent
        let safeArea = view.safeAreaLayoutGuide

        pictureLabel.clipsToBounds = true
        pictureLabel.translatesAutoresizingMaskIntoConstraints = false
        pictureImageView.clipsToBounds = true
        pictureImageView.translatesAutoresizingMaskIntoConstraints = false

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
}

// MARK: - Animation Implementation

private extension SecondViewController {

    func animateSubviews() {
        UIView.transition(with: self.pictureLabel,
                          duration: 1.2,
                          options: [.transitionCrossDissolve, .curveEaseInOut],
                          animations: {
                            self.pictureLabel.alpha = 1.0
                          },
                          completion: nil)
    }
}
