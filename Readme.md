# AVFoundation workshop

Source code for AVFoundation workshop

## Project
* UI code is mostly in storyboard, it doesnt bother you
* Methods we dont use are at the end of class
* Simple MVC architecture
* For learning purposes of AVFoundation
* Code doesnt contain pods or any 3rd party tools

## Run
* Run app in simulator, don't use
* To run on device change your team in project settings

## Tasks
1) CREATE PREVIEW IMAGE FROM ASSET
- task in AVAsset+ImagePreview, method called from ImageCollectionViewCell
- use AVAssetImageGenerator
- careful copying image is heavy operation

2) ASYNC LOAD ASSET KEYS
- task in PreviewViewController
- use asset loadValuesAsynchronously
- requiredAssetKeys are prepared for you
- check all keys are properly loaded
- set values from keys to metadataTextView
- dont forget set UI from loadValuesAsynchronously needs to be done on main thread

3) SET SLOW PLAYBACK TYPE
- task in PreviewViewController
- similar to other types
- try different rates
- check values from observered player item (eg canPlayReverse)
- check values printed in console after item restarts to play
- check available rate values at https://developer.apple.com/documentation/avfoundation/avplayeritem/1385591-canplayreverse

4) CREATE NEW ASSET MIXING VIDEO & SOUND
- task in VideoCompositionViewController
- create mutable track for video, check video asset has video track
- create mutable track for audio, check audio asset has audio track
- note reversed video is prepared for you
- try to set max time of video to make it nice and faster
- insert time ranges to proper tracks, compare audio video lenght
- create video composing instructions with layer instructions and set it properly to videoComposition
- careful video recorded in portrait would be rotated without updating video size
- once composition is ready video is exported, save button enabled a video played

5) BONUS - SEND ME FUNNY VIDEO
As bonus try to use remote assets
Dont forget that before reversing them or composing them they needed to be downloaded

