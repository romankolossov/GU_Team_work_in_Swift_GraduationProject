//
//  PictureCollectionViewCell.swift
//  MariannePictureViewer
//
//  Created by Roman Kolosov on 05.06.2021.
//

import UIKit
import SDWebImage
import OSLog

class PictureCollectionViewCell: UICollectionViewCell {

    // MARK: - Private properties

    private lazy var pictureLabel: UILabel = {
        let label = UILabel()
        label.textColor = .pictureCellLabelTextColor
        label.textAlignment = .center
        label.font = .pictureCellLabelFont
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
    // MARK: - TO DELETE
//    private var cachedImages: Dictionary = [String: UIImage]()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func lookConfigure(with photo: PhotoElementData, photoService: CollectionViewPhotoService?, indexPath: IndexPath) {
        guard let photoStringURL = photo.downloadURL else { return }

        animate()
        animateSubviews()

        pictureImageView.image = photoService?.getImage(atIndexPath: indexPath, byUrl: photoStringURL)
        pictureLabel.text = photo.author
    }

    // MARK: - Private methods

    // MARK: Configure

    private func configureCell() {
        self.backgroundColor = .pictureCellBackgroundColor
        self.contentView.alpha = 0.0

        self.layer.borderWidth = .pictureCellBorderWidth
        self.layer.borderColor = UIColor.pictureCellBorderColor.cgColor
        self.layer.cornerRadius = .pictureCellCornerRadius

        addSubviews()
        setupConstraints()
    }

    private func addSubviews() {
        contentView.addSubview(pictureLabel)
        contentView.addSubview(pictureImageView)
    }

    private func setupConstraints() {
        let indent: CGFloat = .pictureCellIndent
        let safeArea = contentView.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            pictureLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: indent * 2),
            pictureLabel.leftAnchor.constraint(equalTo: safeArea.leftAnchor, constant: indent),
            pictureLabel.rightAnchor.constraint(equalTo: safeArea.rightAnchor, constant: -indent),
            pictureLabel.heightAnchor.constraint(equalToConstant: .pictureCellLabelHeight),

            pictureImageView.topAnchor.constraint(equalTo: pictureLabel.bottomAnchor, constant: indent * 2),
            pictureImageView.leftAnchor.constraint(equalTo: safeArea.leftAnchor, constant: indent),
            pictureImageView.rightAnchor.constraint(equalTo: safeArea.rightAnchor, constant: -indent),
            pictureImageView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -indent)
        ])
    }

    // MARK: - Animation methods

    private func animate() {
        UIView.transition(with: self.contentView,
                          duration: 1.2,
                          options: [.transitionCrossDissolve, .curveEaseInOut],
                          animations: {
                            self.backgroundColor = .brown
                            self.contentView.alpha = 1.0
                          },
                          completion: nil)
    }

    private func animateSubviews() {
        UIView.transition(with: self.pictureLabel,
                          duration: 1.2,
                          options: [.transitionFlipFromRight, .curveEaseInOut],
                          animations: {
                          },
                          completion: nil)

        UIView.transition(with: self.pictureImageView,
                          duration: 1.7,
                          options: [.transitionCrossDissolve, .curveEaseInOut],
                          animations: {
                          },
                          completion: nil)
    }

}
