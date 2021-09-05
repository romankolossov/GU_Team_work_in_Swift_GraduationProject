//
//  PictureCollectionViewCell.swift
//  MariannePictureViewer
//
//  Created by Roman Kolosov on 05.06.2021.
//

import UIKit
import OSLog

class PictureCollectionViewCell: UICollectionViewCell {

    // MARK: - Private Properties

    private let pictureLabel = UILabel()
    private let pictureImageView = UIImageView()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Configuration

extension PictureCollectionViewCell {

    func lookConfigure(with photo: PhotoElementData, photoService: CollectionViewPhotoService?, indexPath: IndexPath) {
        guard let photoStringURL = photo.downloadURL else { return }

        photoService?.getImage(atIndexPath: indexPath, byUrl: photoStringURL) { [weak self] image in
            self?.pictureImageView.image = image
            self?.pictureLabel.text = photo.author
            self?.animateSubviews()
        }
    }

}

private extension PictureCollectionViewCell {

    func configureCell() {
        backgroundColor = .pictureCellBackgroundColor
        layer.borderWidth = .pictureCellBorderWidth

        layer.borderColor = UIColor.pictureCellBorderColor.cgColor
        layer.cornerRadius = .pictureCellCornerRadius

        configureSubviews()
        contentView.addSubview(pictureLabel)
        contentView.addSubview(pictureImageView)
        setupConstraints()
    }

    func configureSubviews() {
        pictureLabel.textColor = .pictureCellLabelTextColor
        pictureLabel.textAlignment = .center
        pictureLabel.font = .pictureCellLabelFont

        pictureImageView.contentMode = .scaleAspectFit
    }

}

// MARK: - Layout

private extension PictureCollectionViewCell {

    func setupConstraints() {
        let indent: CGFloat = .pictureCellIndent
        let safeArea = contentView.safeAreaLayoutGuide

        pictureLabel.clipsToBounds = true
        pictureLabel.translatesAutoresizingMaskIntoConstraints = false
        pictureImageView.clipsToBounds = true
        pictureImageView.translatesAutoresizingMaskIntoConstraints = false

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

}

// MARK: - Animation Implementation

private extension PictureCollectionViewCell {

    func animateSubviews() {
        UIView.transition(with: self.pictureLabel,
                          duration: 0.8,
                          options: [.transitionCrossDissolve, .curveEaseInOut],
                          animations: nil,
                          completion: nil)
    }

}
