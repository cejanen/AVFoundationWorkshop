//
//  PreviewViewController.swift
//  AVFWorkshop
//
//  Created by Tomas Cejka on 9/15/18.
//  Copyright © 2018 STRV. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - Playback type enum
enum VideoPlaybackType: Int {
    case normal
    case slow
    case fast
    case backwards
    case normalSlowBackwards
}

// MARK: - Preview view controller to show different playbacks
class PreviewViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet private weak var metadataTextView: UITextView!
    @IBOutlet private weak var videoContainerView: UIView!
    @IBOutlet private weak var playbackTypeSwitcher: UISegmentedControl! {
        didSet {
            playbackTypeSwitcher.setTitle("normal", forSegmentAt: 0)
            playbackTypeSwitcher.setTitle("slow", forSegmentAt: 1)
            playbackTypeSwitcher.setTitle("fast", forSegmentAt: 2)
            playbackTypeSwitcher.setTitle("backwards", forSegmentAt: 3)
            playbackTypeSwitcher.setTitle("mix", forSegmentAt: 4)
        }
    }

    // MARK: - Properties
    var asset: AVAsset!
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var loopCount: Int = 0
    var currentPlaybackType: VideoPlaybackType = .normal
    var playerItemObservation: NSKeyValueObservation?

    // define asset keys we are interested in
    let requiredAssetKeys = ["duration", "playable", "metadata", "tracks"]

    // define player item keys
    let requiredPlayerItemKeys = [
        "playable"
    ]

    // when deinit, dont forget to remove observers
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UIViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // load asset data and show it
        showAssetMetadata()

        // prepare player with playback type
        preparePlayer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player?.play()
    }
}

// MARK: - Private helper methods
private extension PreviewViewController {

    // TODO: 2) TASK
    /*
     ASYNC LOAD ASSET KEYS
     - use asset loadValuesAsynchronously
     - requiredAssetKeys are prepared for you
     - check all keys are properly loaded
     - set values from keys to metadataTextView
     - dont forget set UI from loadValuesAsynchronously needs to be done on main thread
     */

    func showAssetMetadata() {
        
    }
}

// MARK: - Private init player methods
private extension PreviewViewController {
    func preparePlayer() {

        // init player item
        initPlayerItem()

        // init player, layer
        initPlayer()

        // setup playback type
        setPlayback(playbackType: currentPlaybackType)
    }

    func initPlayerItem() {
        // create player item and load required keys
        playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: requiredPlayerItemKeys)

        // register for notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)

        playerItemObservation = playerItem?.observe(\.status, changeHandler: { [weak self] (item, change) in
            // Switch over status value
            switch item.status {
            case .readyToPlay:
                // player item is ready to play, update metadata text view
                self?.metadataTextView.text = """
                \(self?.metadataTextView.text ?? "") \n
                LOADED PLAYER ITEM METADATA \n
                duration: \(item.duration) \n
                canPlayReverse: \(item.canPlayReverse) \n
                canPlayFastForward: \(item.canPlayFastForward) \n
                canPlaySlowBackward: \(item.canPlaySlowReverse) \n
                """

            default:
                // if anything wrong log status
                print(item.status)
            }
        })
    }

    func initPlayer() {
        player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        videoContainerView.layer.addSublayer(playerLayer)

        // set proper size of player layer
        playerLayer.frame = videoContainerView.bounds
        // type of video resizing
        playerLayer.videoGravity = .resizeAspect
    }

    func setPlayback(playbackType: VideoPlaybackType) {

        // TODO: 3) TASK
        /*
         SET SLOW PLAYBACK TYPE
         - similar to other types
         - try different rates with different videos
         - check values from observered player item (eg canPlayReverse)
         - check values printed in console after item restarts to play
         - check available rate values at https://developer.apple.com/documentation/avfoundation/avplayeritem/1385591-canplayreverse
         - try seek with tolerance parameters
         */

        // rate property works after setting after player.play
        switch playbackType {
        case .normal:
            player?.seek(to: .zero)
            // now starts
            player?.play()
            player?.rate = 1

        case .fast:
            player?.seek(to: .zero)
            // now starts
            player?.play()
            player?.rate = 2


        case .slow:
            print("TODO")

        case .backwards:
            // set start at the end of song
            player!.seek(to: playerItem!.duration)
            // now starts
            player!.play()
            // negative value is used for going backwards
            player!.rate = -2

        case .normalSlowBackwards:
            if loopCount % 2 == 0 {
                setPlayback(playbackType: .fast)
            } else {
                setPlayback(playbackType: .backwards)
            }
        }
    }
}

// MARK: - IBAction methods
private extension PreviewViewController {
    @IBAction func changePlaybackType() {

        // stop current play
        player?.pause()

        // set current playback type
        currentPlaybackType = VideoPlaybackType(rawValue: playbackTypeSwitcher.selectedSegmentIndex)!

        // reset loop number
        loopCount = 0

        // set playback
        setPlayback(playbackType: currentPlaybackType)
    }
}

// MARK: - Handling player item did end
private extension PreviewViewController {
    @objc func playerItemDidReachEnd() {
        // increase loop number
        loopCount += 1

        // set playback avoid calling this when going backwards
        if currentPlaybackType != .backwards || (currentPlaybackType == .backwards && player!.currentTime() <= .zero) {
            setPlayback(playbackType: currentPlaybackType)
        }

        // log playerItem properties (available when playing)
        print("can play reverse \(playerItem?.canPlayReverse ?? false)")
        print("can play slow reverse \(playerItem?.canPlaySlowReverse ?? false)")
        print("can play fast forward \(playerItem?.canPlayFastForward ?? false)")
    }
}

// MARK: - Navigation to next view controller
extension PreviewViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let videoComposingVC = segue.destination as? AudioSelectionViewController {
            videoComposingVC.videoAsset = asset
        }
    }
}
