//
//  PictureCollectionViewCell.swift
//  MariannePictureViewer
//
//  Created by Roman Kolosov on 05.06.2021.
//

import UIKit
import SDWebImage

class PictureCollectionViewCell: UICollectionViewCell {

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
    private var cachedImages: Dictionary = [String: UIImage]()

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
        // SDWebImage use for activity indicator
        self.pictureImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray

        /* SDWebImage use for image download*/
        /* SDWebImage used since it is the most easy way to download images
         avoiding its mismatch in cells. Also it shows the download activity */

        // RAM cache use
        if let image = cachedImages[photoStringURL] {
            #if DEBUG
            // print("\(photoStringURL) : Cached image with SDWebImage")
            #endif
            self.pictureImageView.image = image
            self.pictureLabel.text = photo.author
        } else {
            self.pictureImageView.sd_setImage(with: URL(string: photoStringURL)) { [weak self] (image, _, _, _) in
                #if DEBUG
                // print("\(photoStringURL) : Network image with SDWebImage")
                #endif
                self?.pictureLabel.text = photo.author
                self?.animateSubviews()

                guard let image = image else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.cachedImages[photoStringURL] = image
                }
            }
        }
        /* SDWebImage use for image download end */

        /* Way of use RAM and file image caches with network download providing CollectionViewPhotoService.
         It is slower than the use SDWebImage for network.
         Also it causes mismatch images when cache fomm file used.
         Stack - CollectionViewPhotoService.
         In order to use CollectionViewPhotoService, plese
         1. comment the code between "SDWebImage use for image download - SDWebImage use end";
         2. comment the line: "private var cachedImages: Dictionary = [String : UIImage]()"
         3. remove comments from the use of photoService, "self.pictureLabel.tex=" and "self.animateSubviews()" for the lines bellow;
         4. perform actions following instructions in SecondViewController.swift file.
         */
        // self.pictureImageView.image = photoService?.getPhoto(atIndexPath: indexPath, byUrl: photoStringURL)
        // self.pictureLabel.text = photo.author
        // self.animateSubviews()

        animate()
    }

    // MARK: - Private methods

    // MARK: Configure

    private func configureCell() {
        self.backgroundColor = .pictureCellBackgroundColor
        self.contentView.alpha = 0

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
            pictureLabel.heightAnchor.constraint(equalToConstant: .pictureLabelHeight),

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
                            self.contentView.alpha = 1
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
                          duration: 1.2,
                          options: [.transitionCrossDissolve, .curveEaseInOut],
                          animations: {
                          },
                          completion: nil)
    }

}
