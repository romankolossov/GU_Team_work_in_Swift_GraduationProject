//
//  SecondViewController.swift
//  MariannePictureViewer
//
//  Created by Roman Kolosov on 05.06.2021.
//

import UIKit
import SDWebImage

class SecondViewController: BaseViewController {

    // MARK: - Public properties

    var pictureLabel = UILabel()
    var pictureImageView = UIImageView()

    // MARK: - Initializers

    init() {
        super.init(nibName: nil, bundle: nil)
        configureSecondVC()
    }
    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        (UIApplication.shared.delegate as? AppDelegate)?.restrictRotation = .portrait
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.animateSubviews()
    }

    // MARK: - Public methods

    func lookConfigure(with photo: PhotoElementData, photoService: CollectionViewPhotoService?, indexPath: IndexPath) {

        guard let photoStringURL = photo.downloadURL else { return }
        self.pictureLabel.text = "\(localize("author")) \(photo.author ?? "")"

        /* SDWebImage use for image download */
        self.pictureImageView.sd_setImage(with: URL(string: photoStringURL)) { [weak self] (_, _, _, _) in

            self?.animateSubviews()
        }
        /* SDWebImage for image download use end */

        /* Way of use RAM, file image caches and network download with CollectionViewPhotoService.
         For more see explanations in PictureCollectionViewCell.swift file.
         In order to use CollectionViewPhotoService, plese
         1. comment the code between "SDWebImage use for image download - SDWebImage use end";
         2. remove comments from the use of photoService for the line bellow;
         3. perform actions following instructions in PictureCollectionViewCell.swift file.
         */
        // self.pictureImageView.image = photoService?.getPhoto(atIndexPath: indexPath, byUrl: photoStringURL)
    }

    // MARK: - Private methods

    // MARK: Configure

    private func configureSecondVC() {
        self.view.backgroundColor = .systemYellow

        // MARK: Layout subviews

        let indent: CGFloat = 11.0
        let picScale: CGFloat = 12 / 9
        let subviewWidth: CGFloat = ceil(self.view.bounds.size.width - indent * 2)

        let piclHeight: CGFloat = ceil(subviewWidth * picScale)
        let picY: CGFloat = ceil(self.view.bounds.size.height / 2 - piclHeight / 2)

        let labelHeight: CGFloat = 21.0
        let labelY: CGFloat = ceil(picY - labelHeight - indent * 1.5)

        let pictureLabelFrame = CGRect(x: indent, y: labelY, width: subviewWidth, height: labelHeight)
        let pictureImageViewFrame = CGRect(x: indent, y: picY, width: subviewWidth, height: piclHeight)

        // MARK: Configure subviws

        pictureLabel = UILabel(frame: pictureLabelFrame)
        pictureLabel.font = .systemFont(ofSize: 21)
        pictureLabel.textColor = .blue
        pictureLabel.textAlignment = NSTextAlignment.center
        pictureLabel.alpha = 0

        pictureImageView = UIImageView(frame: pictureImageViewFrame)
        pictureImageView.contentMode = .scaleAspectFit

        self.view.addSubview(pictureLabel)
        self.view.addSubview(pictureImageView)
    }

    // MARK: Animation methods

    private func animateSubviews() {
        UIView.transition(with: self.pictureLabel,
                          duration: 2.1,
                          options: [.transitionCrossDissolve, .curveEaseInOut],
                          animations: {
                            self.pictureLabel.alpha = 1
                          },
                          completion: nil)
    }

}
