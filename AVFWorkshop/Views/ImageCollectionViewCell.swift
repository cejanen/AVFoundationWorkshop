//
//  VideoImageCollectionViewCell.swift
//  AVFWorkshop
//
//  Created by Tomas Cejka on 9/15/18.
//  Copyright © 2018 STRV. All rights reserved.
//

import UIKit
import AVFoundation

// Simple UICollectionViewCell with image
class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}

// MARK: - Public methods, setup image
extension ImageCollectionViewCell {
    func set(with asset: AVAsset) {
        backgroundColor = .gray
        // creating preview is heavy operation, result in completion handler
        asset.preview { [weak self] image in
            self?.imageView.image = image
        }
    }
}
