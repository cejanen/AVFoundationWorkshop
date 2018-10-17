//
//  AVAsset+ImagePreview.swift
//  AVFWorkshop
//
//  Created by Tomas Cejka on 10/7/18.
//  Copyright © 2018 STRV. All rights reserved.
//

import AVFoundation
import UIKit

// MARK: - Private extension of AVAsset to create random image preview from video
extension AVAsset {

    // TODO: 1) TASK
    /*
        CREATE PREVIEW IMAGE FROM ASSET
        - use AVAssetImageGenerator
        - careful copying image is heave operation
     */

    // From docs: The value of the CMTime. value/timescale = seconds
    // Note: - when CMTime is bigger than video lenght last second is used
    func preview(completionHandler: @escaping (UIImage?) -> Void) {
       
    }
}
