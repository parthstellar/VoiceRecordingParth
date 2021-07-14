//
//  RecordingsViewController.swift
//  VoiceMemosClone
//
//  Created by Apple on 14/07/21.
//

let cellid = "cell"

import UIKit
import AVFoundation

struct Recording {
    var name: String
    var path: URL
}

protocol RecordingsViewControllerDelegate: class {
    func didStartPlayback()
    func didFinishPlayback()
}

class RecordingsViewController: UIViewController {
    
    //MARK:- Properties
    var recordings: [Recording] = []
    private var audioPlayer: AVAudioPlayer?
    weak var delegate: RecordingsViewControllerDelegate?
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadRecordings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isPlaying() {
            self.stopPlay()
        }
        super.viewWillDisappear(animated)
    }
    
    // MARK:- Data
    func loadRecordings() {
        self.recordings.removeAll()
        let filemanager = FileManager.default
        let documentsDirectory = filemanager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let paths = try filemanager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [])
            for path in paths {
                let recording = Recording(name: path.lastPathComponent, path: path)
                self.recordings.append(recording)
            }
        } catch {
            print(error)
        }
    }
    
    // MARK:- Playback
    func play(url: URL) {
        if let d = self.delegate {
            d.didStartPlayback()
        }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            let data = try Data(contentsOf: url)
            self.audioPlayer = try AVAudioPlayer(data: data, fileTypeHint: AVFileType.caf.rawValue)
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        if let player = self.audioPlayer {
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        }
    }
    
    func stopPlay() {
        if let d = self.delegate {
            d.didFinishPlayback()
        }
        if let player = self.audioPlayer {
            player.pause()
        }
        self.audioPlayer = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch  let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
    func isPlaying() -> Bool {
        if let player = self.audioPlayer {
            return player.isPlaying
        }
        return false
    }
}

extension RecordingsViewController: AVAudioPlayerDelegate {
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let e = error {
            print(e.localizedDescription)
        }
        self.stopPlay()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.stopPlay()
    }
}
