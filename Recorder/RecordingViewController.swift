//
//  RecordingViewController.swift
//  Recorder
//
//  Created by Jacob Sokora on 12/7/18.
//  Copyright © 2018 Jacob Sokora. All rights reserved.
//

import UIKit
import AVKit

class RecordingViewController: UIViewController {
	
	@IBOutlet weak var recordButton: UIBarButtonItem!
	@IBOutlet weak var playButton: UIBarButtonItem!
	@IBOutlet weak var audioQualityLabel: UILabel!
	
	var recording = false
	var playing = false
	
	var audioSettings: [String: Any] = [
		AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
		AVEncoderBitRateKey: 16,
		AVNumberOfChannelsKey: 2,
		AVSampleRateKey: 44100.0
	]
	
	var audioSession: AVAudioSession?
	var recorder: AVAudioRecorder?
	var player: AVAudioPlayer?
	var audioFile: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
		audioFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("recording.caf")
		audioSession = AVAudioSession.sharedInstance()
		do {
			try audioSession?.setCategory(.playAndRecord, mode: .default)
			try audioSession?.setActive(true)
			audioSession?.requestRecordPermission{ allowed in
				if allowed {
					self.recordButton.isEnabled = true
				} else {
					self.displayError("You must give the app permission to record audio!")
				}
			}
		} catch {
			displayError(error.localizedDescription)
		}
    }
	
	func displayError(_ error: String) {
		let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default))
		present(alert, animated: true)
	}

	@IBAction func record(_ sender: Any) {
		if !recording {
			do {
				recorder = try AVAudioRecorder(url: audioFile, settings: audioSettings)
				recorder?.delegate = self
				recorder?.record()
				recordButton.image = UIImage(named: "stop")
				recording = true
				playButton.isEnabled = false
			} catch {
				endRecording()
			}
		} else {
			endRecording()
			recording = false
			recordButton.image = UIImage(named: "record")
			playButton.isEnabled = true
		}
	}
	
	func endRecording() {
		recorder?.stop()
		recorder = nil
	}
	
	@IBAction func play(_ sender: Any) {
		if !playing {
			do {
				player = try AVAudioPlayer(contentsOf: audioFile, fileTypeHint: AVFileType.mp4.rawValue)
				player?.delegate = self
				player?.prepareToPlay()
				player?.play()
				playing = true
				playButton.image = UIImage(named: "stop")
				recordButton.isEnabled = false
			} catch {
				displayError(error.localizedDescription)
				print(error)
			}
		} else {
			playing = false
			player?.stop()
			player = nil
			playButton.image = UIImage(named: "play")
			recordButton.isEnabled = true
		}
	}
	
	@IBAction func changeAudioQuality(_ sender: UISlider) {
		audioSettings[AVEncoderAudioQualityKey] = Int(sender.value)
		audioQualityLabel.text = "Audio Quality: \(Int(sender.value))"
	}
}

extension RecordingViewController: AVAudioRecorderDelegate {
	func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
		endRecording()
	}
}

extension RecordingViewController: AVAudioPlayerDelegate {
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		self.player = nil
		playing = false
		playButton.image = UIImage(named: "play")
		recordButton.isEnabled = true
	}
}
