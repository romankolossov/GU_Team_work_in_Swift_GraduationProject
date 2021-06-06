//
//  BaseViewController.swift
//  MariannePictureViewer
//
//  Created by Roman Kolosov on 05.06.2021.
//

import UIKit

class BaseViewController: UIViewController {

    // MARK: - Public method

    // MARK: Localize

    func localize(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    // MARK: Alert

    func showAlert(
        title: String? = nil,
        message: String? = nil,
        handler: ((UIAlertAction) -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        alertController.addAction(okAction)

        present(alertController, animated: true, completion: completion)
    }

}
