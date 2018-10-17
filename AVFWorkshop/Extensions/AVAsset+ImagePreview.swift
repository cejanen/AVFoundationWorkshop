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
        - careful copying image is heavy operation
     */

    // From docs: The value of the CMTime. value/timescale = seconds
    // Note: - when CMTime is bigger than video lenght last second is used
    func preview(completionHandler: @escaping (UIImage?) -> Void) {
        // setup time
        let duration = Int(self.duration.seconds)
        let randomTime = CMTime(value: CMTimeValue(Int.random(in: 0...duration)), timescale: 1)

        // Blocking operation, call async
        DispatchQueue.main.async {
            let imgGenerator = AVAssetImageGenerator(asset: self)

            do {
                // create image
                // From docs: Returns a CFRetained CGImageRef for an asset at or near the specified time.
                let cgImage = try imgGenerator.copyCGImage(at: randomTime, actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                completionHandler(uiImage)

            } catch {
                print(error)
                completionHandler(nil)
            }
        }
    }
}
