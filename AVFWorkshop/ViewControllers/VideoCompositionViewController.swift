//
//  VideoCompositionViewController.swift
//  AVFWorkshop
//
//  Created by Tomas Cejka on 10/13/18.
//  Copyright © 2018 STRV. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

// MARK: - ViewController for creating final video
final class VideoComposingViewController: UIViewController {
    // MARK: - @IBOutlets
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem! {
        didSet {
            saveBarButtonItem.isEnabled = false
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties
    var audioAsset: AVAsset!
    var videoAsset: AVAsset!
    var reversedAsset: AVAsset?
    var composedAsset: AVURLAsset?
    var player: AVPlayer?

    // when deinit, dont forget to remove observers
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UIViewController life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // compose final asset
        composeAsset()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
}


// MARK: - Composing final video
private extension VideoComposingViewController {

    // TODO: 4) TASK
    /*
     CREATE NEW ASSET MIXING VIDEO & SOUND
     - create mutable track for video, check video asset has video track
     - create mutable track for audio, check audio asset has audio track
     - note reversed video is prepared for you
     - try to set max time of video to make it nice and faster
     - insert time ranges to proper tracks, compare audio video lenght
     - create video composing instructions with layer instructions and set it properly to videoComposition
     - careful video recorded in portrait would be rotated without updating video size
     - once composition is ready video is exported, save button enabled a video played
     */

    func composeVideo() {

        let composition = AVMutableComposition()
        let videoComposition = AVMutableVideoComposition()

        // video composition, track
        let compositionVideoTrack = composition.addMutableTrack(withMediaType:
            AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)

        guard let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first else {
            print("no video track in video asset")
            return
        }

        compositionVideoTrack?.preferredTransform = videoTrack.preferredTransform

        // reversed video track
        guard let videoReversedTrack = reversedAsset?.tracks(withMediaType: AVMediaType.video).first else {
            print("no video track in reversed video asset")
            return
        }

        // audio track
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)

        guard let audioTrack = audioAsset.tracks(withMediaType: AVMediaType.audio).first else {
            print("no audio track in audio asset")
            return
        }

        // pointer of current total duration of generated asset
        var currentTimePointer = CMTime.zero
        var startReverse = CMTime.zero

        // we wanna cut video, reversed video should be same duration
        var maxVideoAssetDuration = CMTime(seconds: 3, preferredTimescale: 1)

        // video is shorter than max length
        if CMTimeCompare(videoAsset.duration, maxVideoAssetDuration) <= 0 {
            maxVideoAssetDuration = videoAsset.duration
        } else {
            // create start for reversed video to join videos at same time
            startReverse = CMTimeSubtract(videoAsset.duration, maxVideoAssetDuration)
        }

        do {
            // set composition of two video tracks
            // cut video tracks to max length

            try compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: maxVideoAssetDuration), of: videoTrack, at: CMTime.zero)

            currentTimePointer = CMTimeAdd(currentTimePointer, maxVideoAssetDuration)

            try compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: startReverse, duration: maxVideoAssetDuration), of: videoReversedTrack, at: currentTimePointer)
            currentTimePointer = CMTimeAdd(currentTimePointer, maxVideoAssetDuration)


            // set double rate, total time in half duration
            compositionVideoTrack?.scaleTimeRange(CMTimeRangeMake(start: .zero, duration: currentTimePointer), toDuration: maxVideoAssetDuration)
            // set currentTime pointer to half duration
            currentTimePointer = maxVideoAssetDuration

        } catch {
            print(error.localizedDescription)
            return
        }

        // compare video tracks length with audio
        // audio is shorter than video
        if CMTimeCompare(currentTimePointer, audioAsset.duration) > 0 {
            var audioTimePointer: CMTime = .zero
            let maximumDuration = currentTimePointer

            while true {
                // iteration of time added
                let thisTimeRangeDuration = CMTimeAdd(audioTimePointer, audioAsset.duration)
                var audioTrackDuration = audioAsset.duration

                // value 1 means greater than
                if CMTimeCompare(thisTimeRangeDuration, maximumDuration) == 1 {
                    // we cannot put there the full audio duration because it'll become
                    // longer than the video. Let's cut it
                    audioTrackDuration = CMTimeSubtract(maximumDuration, audioTimePointer)
                }

                do {
                    try compositionAudioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: audioTrackDuration), of: audioTrack, at: audioTimePointer)
                } catch {
                    print(error.localizedDescription)
                    return
                }
                audioTimePointer = CMTimeAdd(audioTimePointer, audioTrackDuration)
                if CMTimeCompare(audioTimePointer, maximumDuration) >= 0 {
                    // there's no empty slot, let's break, we're done
                    break
                }
            }
        } else {
            // audio is longer than video merge it and cut
            do {
                try compositionAudioTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: currentTimePointer), of: audioTrack, at: CMTime.zero)
            } catch {
                print(error.localizedDescription)
                return
            }
        }

        // set instructions to have full video properly exported
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(start: .zero, duration: CMTimeAdd(maxVideoAssetDuration, maxVideoAssetDuration))

        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        mainInstruction.layerInstructions = [layerInstruction]

        videoComposition.instructions = [mainInstruction]
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)

        // fix rotation for video from camera
        var renderSize = videoTrack.naturalSize
        if isPortrait(track: videoTrack) {
            renderSize = CGSize(width: renderSize.height, height: renderSize.width)
        }
        videoComposition.renderSize = renderSize

        saveAsset(composition, videoComposition: videoComposition)
    }

    // check portrait to avoid rotation of video when exporting
    func isPortrait(track: AVAssetTrack) -> Bool {
        let t = track.preferredTransform
        // Portrait
        if t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0
        {
            return true
        }
        // PortraitUpsideDown
        if t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0 {

            return true
        }

        return false
    }
}

// MARK: - Compose flow
private extension VideoComposingViewController {
    func composeAsset() {

        // create reversed video asset
        DispatchQueue.main.async { [weak self] in
            self?.createReversed { [weak self] in
                // after compose final video
                self?.composeVideo()
            }
        }
    }

    func saveAsset(_ asset: AVAsset, videoComposition: AVVideoComposition?) {
        // hack to avoid crash in app version without code
        guard videoComposition?.renderSize.width ?? 0 > 0  else {
             DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.stopAnimating()
            }
            return }

        // create temp file url
        let uniqueId = UUID().uuidString
        let tempFileName = "\(uniqueId).mp4"
        let outputUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(tempFileName, isDirectory: false)
        // define exporter
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
        exporter.outputURL = outputUrl
        exporter.outputFileType = AVFileType.mp4
        exporter.videoComposition = videoComposition
        exporter.shouldOptimizeForNetworkUse = true

        exporter.exportAsynchronously( completionHandler: { [weak self] () -> Void in
            guard exporter.error == nil else {
                print(exporter.error!.localizedDescription)
                return
            }
            // work with UI have to be on main thread
            DispatchQueue.main.async {
                self?.composedAsset = AVURLAsset(url: outputUrl)
                self?.saveBarButtonItem.isEnabled = true
                self?.activityIndicator.stopAnimating()
                self?.setupPlayer()
            }
        })

    }
}

// MARK: - Play final composed video
private extension VideoComposingViewController {
    func setupPlayer() {
        if let videoComposed = composedAsset {
            let playerItem = AVPlayerItem(asset: videoComposed)
            // register for notification
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(playerItemDidReachEnd),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: playerItem)
            player = AVPlayer(playerItem: playerItem)
            let playerLayer = AVPlayerLayer(player: player)
            videoContainerView.layer.addSublayer(playerLayer)

            // set proper size of player layer
            playerLayer.frame = videoContainerView.bounds

            player?.play()
        }
    }
}

// MARK: - Create reverse asset
private extension VideoComposingViewController {
    func createReversed(handler: @escaping () -> Void ) {
        // create reversed asset first
        let tempFileName = "reversed.mp4"
        let outputUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(tempFileName, isDirectory: false)
        // remove existing file
        try? FileManager.default.removeItem(at: outputUrl)
        AVUtilities.reverse(videoAsset, outputURL: outputUrl) { [weak self] asset in
            self?.reversedAsset = asset
            handler()
        }
    }
}

// MARK: - Handling player item did end
private extension VideoComposingViewController {
    @objc func playerItemDidReachEnd() {
        player?.seek(to: .zero)
        player?.play()
    }
}

// MARK: - @IBAction methods
private extension VideoComposingViewController {

    @IBAction func save() {
        if let url = composedAsset?.url {
            saveToCameraRoll(url: url)
        }
    }

    // save exported url to photo library
    func saveToCameraRoll(url: URL) {

        checkAuthorizationAndPerform {

            PHPhotoLibrary.shared().performChanges({

                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }, completionHandler: { [weak self] saved, error in
                DispatchQueue.main.async {
                    if saved {
                        let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(defaultAction)
                        self?.present(alertController, animated: true, completion: nil)
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            })
        }
    }

    // check authorization for storing videos
    func checkAuthorizationAndPerform(success: @escaping () -> Void) {
        PHPhotoLibrary.requestAuthorization {(status) -> Void in

            switch status {
            case .authorized:
                success()

            case .restricted, .denied:
                DispatchQueue.main.async(execute: { [weak self] () -> Void in
                    let alert = UIAlertController(title: "Access Requested", message: "This feature needs to access your photo album", preferredStyle: .alert)
                    alert.addAction(
                        UIAlertAction(title: "Settings", style: .default) { _ in

                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    )

                    alert.addAction(
                        UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    )

                    self?.present(alert, animated: true, completion: nil)
                })
            default:
                break
            }
        }
    }
}
