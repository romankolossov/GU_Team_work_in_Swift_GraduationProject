//
//  UIImage+Extension.swift
//  MariannePV
//
//  Created by Roman Kolosov on 29.08.2021.
//

import UIKit

extension UIImage {

    // Resize the image with the scale to save the memory speed up the UI.
    func scaled(withScale scale: CGFloat) -> UIImage? {
        let size = CGSize(width: self.size.width * scale, height: self.size.height * scale)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

}
