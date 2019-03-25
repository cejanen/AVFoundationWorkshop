//
//  AudioSelectionViewController.swift
//  AVFWorkshop
//
//  Created by Tomas Cejka on 10/13/18.
//  Copyright © 2018 STRV. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - ViewController for audio selection screen
final class AudioSelectionViewController: UIViewController {
    // MARK: - @IBOutlets
    @IBOutlet weak var nextBarButtonItem: UIBarButtonItem! {
        didSet {
            nextBarButtonItem.isEnabled = false
        }
    }

    // MARK: - Properties
    let audios: [AVURLAsset] = [
        AVURLAsset(url: Bundle.main.url(forResource: "cat", withExtension: "mp3")!),
        AVURLAsset(url: Bundle.main.url(forResource: "dog", withExtension: "mp3")!),
        AVURLAsset(url: Bundle.main.url(forResource: "fox", withExtension: "mp3")!),
        AVURLAsset(url: Bundle.main.url(forResource: "hyena", withExtension: "mp3")!),
        AVURLAsset(url: Bundle.main.url(forResource: "pig", withExtension: "mp3")!)
    ]
    // help array of song names
    let names: [String] = ["cat", "dog", "fox", "hyena", "pig"]

    var videoAsset: AVAsset!
    var selectedAudioAsset: AVAsset?
    var audioPlayer: AVAudioPlayer?

    // MARK: UIViewController life cycle methods
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioPlayer?.stop()
    }
}

// MARK: - TableView delegate, data source methods
extension AudioSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audios.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioTableViewCell")!
        cell.textLabel?.text = "\(names[indexPath.row]) - \(audios[indexPath.row].duration.seconds)s"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // enable next
        nextBarButtonItem.isEnabled = true
        // play audio
        let asset = audios[indexPath.row]
        audioPlayer = try? AVAudioPlayer(contentsOf: asset.url)
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()

        // store selected value
        selectedAudioAsset = asset
    }
}

// MARK: - Navigation to other controllers
extension AudioSelectionViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let videoComposingVC = segue.destination as? VideoComposingViewController {
            videoComposingVC.videoAsset = videoAsset
            videoComposingVC.audioAsset = selectedAudioAsset
        }
    }
}
