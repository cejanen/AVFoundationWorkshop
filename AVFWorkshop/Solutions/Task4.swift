//
//  Solutions.swift
//  AVFWorkshop
//
//  Created by Tomas Cejka on 3/25/19.
//  Copyright © 2019 STRV. All rights reserved.
//

/** SOLUTIONS FOR TASKS **/
// TASK 4

/**
 let composition = AVMutableComposition()

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
 var maxVideoAssetDuration = CMTime(seconds: 3, preferredTimescale: 30)

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
 mainInstruction.timeRange = CMTimeRangeMake(start: .zero, duration: maxVideoAssetDuration)

 let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
 mainInstruction.layerInstructions = [layerInstruction]

 let videoComposition = AVMutableVideoComposition()
 videoComposition.instructions = [mainInstruction]
 videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)

 // fix rotation for video from camera
 var renderSize = videoTrack.naturalSize
 if isPortrait(track: videoTrack) {
 renderSize = CGSize(width: renderSize.height, height: renderSize.width)
 }
 videoComposition.renderSize = renderSize
 **/
