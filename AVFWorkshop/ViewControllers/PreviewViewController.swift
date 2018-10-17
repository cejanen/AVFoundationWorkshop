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

    // player item observation
    // Key-value observing context
    private var playerItemContext = 0

    // define asset keys we are interested in
    let requiredAssetKeys = ["duration", "playable", "metadata", "tracks"]

    // define player item keys
    let requiredPlayerItemKeys = [
        "playable"
    ]

    // when deinit, dont forget to remove observers
    deinit {
        NotificationCenter.default.removeObserver(self)
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
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

        // observer player item status if is ready for play
        playerItem!.addObserver(self,
                                forKeyPath: #keyPath(AVPlayerItem.status),
                                options: [.old, .new],
                                context: &playerItemContext)
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
         */

        // rate property works after setting after player.play
        switch playbackType {
        case .normal:
            player!.seek(to: .zero)
            // now starts
            player!.play()
            player!.rate = 1

        case .fast:
            player!.seek(to: .zero)
            // now starts
            player!.play()
            player!.rate = 2


        case .slow:
             player!.seek(to: .zero)
            // TODO:
            // set slow here

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

// MARK: - Observing
extension PreviewViewController {
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {

        // only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }

        // only status we observer and handle
        guard keyPath == #keyPath(AVPlayerItem.status) else {
            return
        }

        // only player current player item
        guard let playerItem = object as? AVPlayerItem else {
            return
        }

        let status: AVPlayerItem.Status
        if let statusNumber = change?[.newKey] as? NSNumber {
            status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
        } else {
            status = .unknown
        }

        // Switch over status value
        switch status {
        case .readyToPlay:
            // player item is ready to play, update metadata text view
            metadataTextView.text = """
            \(metadataTextView.text!) \n
            LOADED PLAYER ITEM METADATA \n
            duration: \(playerItem.duration) \n
            canPlayReverse: \(playerItem.canPlayReverse) \n
            canPlayFastForward: \(playerItem.canPlayFastForward) \n
            canPlaySlowBackward: \(playerItem.canPlaySlowReverse) \n
            """

        default:
            // if anything wrong log status
            print(status)
        }
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
