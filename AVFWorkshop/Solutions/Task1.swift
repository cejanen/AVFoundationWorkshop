//
//  Solutions.swift
//  AVFWorkshop
//
//  Created by Tomas Cejka on 3/25/19.
//  Copyright © 2019 STRV. All rights reserved.
//

/** SOLUTIONS FOR TASKS **/
// TASK 1

/**
 // setup time
 let randomTime = CMTime(seconds: Double.random(in: 0...duration.seconds), preferredTimescale: 30)
 
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
 **/
