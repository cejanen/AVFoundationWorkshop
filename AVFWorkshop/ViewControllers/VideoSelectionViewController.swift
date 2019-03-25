//
//  VideoSelectionViewController.swift
//  AVFWorkshop
//
//  Created by Tomas Cejka on 9/15/18.
//  Copyright © 2018 STRV. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - ViewController for video selection screen
final class VideoSelectionViewController: UIViewController {
    // MARK: - Properties
    var videos: [AVAsset] = [
        AVURLAsset(url: Bundle.main.url(forResource: "bear", withExtension: "mp4")!),
        AVURLAsset(url: Bundle.main.url(forResource: "football", withExtension: "mp4")!),
        AVURLAsset(url: Bundle.main.url(forResource: "lastJedi", withExtension: "mp4")!),
        AVURLAsset(url: Bundle.main.url(forResource: "fall", withExtension: "mp4")!),
        AVURLAsset(url: Bundle.main.url(forResource: "kid", withExtension: "mp4")!),
        AVURLAsset(url: Bundle.main.url(forResource: "seagull", withExtension: "mp4")!),
        AVURLAsset(url: Bundle.main.url(forResource: "wwdcavfoundation", withExtension: "mp4")!),
        AVURLAsset(url: Bundle.main.url(forResource: "test", withExtension: "pdf")!)
    ]

    // help property to set proper size of preview cell item
    private lazy var halfScreenWidth: CGFloat = {
        return view.bounds.size.width/2 - 20
    }()
}

// MARK: - UICollectionView data source methods
extension VideoSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell

        // set video asset for video preview image
        imageCollectionViewCell.set(with: videos[indexPath.row])

        // using tag for simple identify asset item
        // to minimalize code for ui or navigation flow
        imageCollectionViewCell.tag = indexPath.row
        return imageCollectionViewCell
    }
}

// MARK: - UICollectionView data source methods
extension VideoSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: halfScreenWidth, height: 150)
    }
}

// MARK: Navigation to next view controller
extension VideoSelectionViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check destination view controller, sender
        guard let previewViewController = segue.destination as? PreviewViewController, let cell = sender as? ImageCollectionViewCell  else {
            return
        }
        // set selected asset to preview controller
        previewViewController.asset = videos[cell.tag]
    }
}
