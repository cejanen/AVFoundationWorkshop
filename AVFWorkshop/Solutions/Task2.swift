//
//  Solutions.swift
//  AVFWorkshop
//
//  Created by Tomas Cejka on 3/25/19.
//  Copyright © 2019 STRV. All rights reserved.
//

/** SOLUTIONS FOR TASKS **/
// TASK 2

/**
 // proper solution, not to block thread
 asset.loadValuesAsynchronously(forKeys: requiredAssetKeys) { [weak self] in
 guard let `self` = self else { return }

 // check if value loaded properly
 var error: NSError? = nil
 for key in self.requiredAssetKeys {
 // guard each value if loaded
 guard self.asset.statusOfValue(forKey: key, error: &error) == .loaded else {
 if error != nil {
 // log anything is wrong
 print(error?.localizedDescription ?? "error loading asset keys")
 }
 return
 }
 }

 // need to be called on main bc touching ui
 // careful blocking thread if not loaded before
 DispatchQueue.main.async { [weak self] in
 guard let `self` = self else { return }
 let metadata = """
 LOADED ASSET METADATA: \n
 duration: \(self.asset.duration) \n
 isPlayable: \(self.asset.isPlayable) \n
 metadata: \(self.asset.metadata) \n
 tracks: \(self.asset.tracks) \n
 """

 // set prepared text
 self.metadataTextView.text = metadata
 }
 }
 **/
