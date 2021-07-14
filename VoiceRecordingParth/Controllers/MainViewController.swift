//
//  MainViewController.swift
//  VoiceMemosClone
//
//  Created by Apple on 14/07/21.
//

import UIKit

class MainViewController: UIViewController {

    //MARK:- Properties
    private var recordingsViewController: RecordingsViewController? {
        get {
            return children.compactMap({ $0 as? RecordingsViewController }).first
        }
    }
    private var recorderViewController: RecorderViewController? {
        get {
            return children.compactMap({ $0 as? RecorderViewController }).first
        }
    }
    
    //MARK:- Outlets
    @IBOutlet weak var recordingsView: UIView!
    @IBOutlet weak var recorderView: UIView!
    var recordingsVC = RecordingsViewController()
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.        
        if let recorder = self.recorderViewController {
            recorder.delegate = self
        }
        if let recordings = self.recordingsViewController {
            recordings.delegate = self
        }

    }
    
    @IBAction func btnPlayAction() {
        if self.recordingsVC.isPlaying() {
            self.recordingsVC.stopPlay()
        }

        let filemanager = FileManager.default
        let documentsDirectory = filemanager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let paths = try filemanager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [])
            if paths.count > 0 {
                let recording = Recording(name: paths.first!.lastPathComponent, path: paths.first!)
                    self.recordingsVC.play(url: recording.path)
            }
        } catch {
            print(error)
        }
    }

}

extension MainViewController: RecorderViewControllerDelegate {
    func didStartRecording() {
    }
    
    func didFinishRecording() {
        if let recordings = self.recordingsViewController {
            recordings.view.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.25, animations: {
            }, completion: { (finished) in
                if finished {
                        recordings.loadRecordings()
                }
            })
            
        }
    }
}

extension MainViewController: RecordingsViewControllerDelegate {
    func didStartPlayback() {
        if let recorder = self.recorderViewController {
            recorder.fadeView.isHidden = false
            UIView.animate(withDuration: 0.25, animations: {
                recorder.fadeView.alpha = 1
            })
        }
    }
    
    func didFinishPlayback() {
        if let recorder = self.recorderViewController {
            recorder.view.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.25, animations: {
                recorder.fadeView.alpha = 0
            }, completion: { (finished) in
                if finished {
                    recorder.fadeView.isHidden = true
                }
            })
        }
    }
}

extension UIView {
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

}
