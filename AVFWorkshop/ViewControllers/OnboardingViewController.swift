//
//  ViewController.swift
//  AVFWorkshop
//
//  Created by Tomas Cejka on 9/15/18.
//  Copyright © 2018 STRV. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices

// MARK: - View controller - selection between camera view or video selection
class OnboardingViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var cameraButton: UIButton! {
        didSet {
            cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        }
    }
}

// MARK: - Private methods
private extension OnboardingViewController {
    @IBAction func openCamera() {
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = .camera
        mediaUI.mediaTypes = [kUTTypeMovie as String]
        mediaUI.allowsEditing = true
        mediaUI.delegate = self
        present(mediaUI, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension OnboardingViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)

        // check info dict if all data are set
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
            mediaType == kUTTypeMovie as String,
            let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
            return
        }
        // create AVAsset for preview
        let asset = AVAsset(url: url)
        performSegue(withIdentifier: "showPreview", sender: asset)
    }
}

// MARK: - UINavigationControllerDelegate
extension OnboardingViewController: UINavigationControllerDelegate {
}

// MARK: - Navigation to other controllers
extension OnboardingViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let asset = sender as? AVAsset, let previewVC = segue.destination as? PreviewViewController {
            previewVC.asset = asset
        }
    }
}
