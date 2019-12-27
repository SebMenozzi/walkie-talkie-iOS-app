//
//  ViewController.swift
//  Walkie Talkie
//
//  Created by Sebastien Menozzi on 26/12/2019.
//  Copyright © 2019 Sebastien Menozzi. All rights reserved.
//

import UIKit
import AVFoundation
import Accelerate

enum RecorderState {
    case recording
    case stopped
    case denied
}

class ViewController: UIViewController {
    
    let chatRoom = ChatRoom()
    
    private var audioView = AudioVisualizerView()
    private var renderTs: Double = 0
    private var recordingTs: Double = 0
    
    var startPlayer : AVAudioPlayer?
    var stopPlayer : AVAudioPlayer?
    
    var audioPlayer : AVAudioPlayer?
    
     let settings = [AVFormatIDKey: kAudioFormatLinearPCM, AVLinearPCMBitDepthKey: 16, AVLinearPCMIsFloatKey: true, AVSampleRateKey: Float64(44100), AVNumberOfChannelsKey: 1] as [String : Any]
    
    var localAudioEngine = AVAudioEngine()
    var localInput: AVAudioInputNode?
    var localInputFormat: AVAudioFormat?
    
    var peerAudioEngine = AVAudioEngine()
    var peerAudioPlayer = AVAudioPlayerNode()
    var peerInput: AVAudioInputNode?
    var peerInputFormat: AVAudioFormat?
    
    // MARK:- UI
    private let recordingButtonSize: CGFloat = UIScreen.main.bounds.width / 2
    private let recordingIconSize: CGFloat = 50
    
    private lazy var recordingButton: UIView = {
       let view = UIView(frame: CGRect(x: 0, y: 0, width: recordingButtonSize, height: recordingButtonSize))
        view.backgroundColor = .black
        view.makeCorner(withRadius: recordingButtonSize / 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        tap.minimumPressDuration = 0
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: recordingButtonSize / 2).cgPath
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 5.0
        view.layer.masksToBounds = false
        return view
    }()
    
    let recordingIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "audio")!.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(white: 1.0, alpha: 0.8)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private func setupRecordingButton() {
        view.addSubview(recordingButton)
        recordingButton.addSubview(recordingIcon)
        
        recordingButton.widthAnchor.constraint(equalToConstant: recordingButtonSize).isActive = true
        recordingButton.heightAnchor.constraint(equalToConstant: recordingButtonSize).isActive = true
        recordingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recordingButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        recordingIcon.widthAnchor.constraint(equalToConstant: recordingIconSize).isActive = true
        recordingIcon.heightAnchor.constraint(equalToConstant: recordingIconSize).isActive = true
        recordingIcon.centerYAnchor.constraint(equalTo: recordingButton.centerYAnchor).isActive = true
        recordingIcon.centerXAnchor.constraint(equalTo: recordingButton.centerXAnchor).isActive = true
    }
    
    fileprivate func setupAudioView() {
        audioView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(audioView)
        audioView.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.main.bounds.height / 6).isActive = true
        audioView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        audioView.heightAnchor.constraint(equalToConstant: 135).isActive = true
        audioView.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 20, g: 20, b: 20)
        
        setupRecordingButton()
        
        setupAudioView()
        
        setupAVRecorder()
    }
    
    // MARK:- api
    
    private func setupAVRecorder() {
        
        let startURL = Bundle.main.url(forResource: "StartRecording", withExtension: "aiff")!
        let stopURL = Bundle.main.url(forResource: "StopRecording", withExtension: "aiff")!

        self.startPlayer = try? AVAudioPlayer(contentsOf: startURL)
        self.startPlayer?.prepareToPlay()
        self.stopPlayer = try? AVAudioPlayer(contentsOf: stopURL)
        self.stopPlayer?.prepareToPlay()

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        
        // Setting up audio engine for local recording
        self.localInput = self.localAudioEngine.inputNode
        
        // Setting up audio engine for peer recording
        self.peerInput = self.peerAudioEngine.inputNode
        self.peerAudioEngine.attach(self.peerAudioPlayer)
        
        self.peerInputFormat = AVAudioFormat(settings: self.settings)
        self.peerAudioEngine.connect(self.peerAudioPlayer, to: self.peerAudioEngine.mainMixerNode, format: self.peerInputFormat)
        
        do {
            self.peerAudioEngine.prepare()
            try self.peerAudioEngine.start()
        }
        catch let error as NSError {
            print("\(#file) > \(#function) > Error starting audio engine: \(error.localizedDescription)")
        }
    }
    
    
    private func startRecording() {
        self.recordingTs = NSDate().timeIntervalSince1970
        
        self.startPlayer?.play()
        
        let recordingFormat = self.localInput?.inputFormat(forBus: 0)
        self.localInput?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, time) in
            let level: Float = -100
            let length: UInt32 = 1024
            buffer.frameLength = length
            let channels = UnsafeBufferPointer(start: buffer.floatChannelData, count: Int(buffer.format.channelCount))
            var value: Float = 0
            vDSP_meamgv(channels[0], 1, &value, vDSP_Length(length))
            var average: Float = ((value == 0) ? -100 : 20.0 * log10f(value))
            if average > 0 {
                average = 0
            } else if average < -100 {
                average = -100
            }
            let silent = average < level
            let ts = NSDate().timeIntervalSince1970
            
            if ts - self.renderTs > 0.1 {
                // send audio
                self.chatRoom.sendAudio(buffer: buffer)
                
                let floats = UnsafeBufferPointer(start: channels[0], count: Int(buffer.frameLength))
                let frame = floats.map({ (f) -> Int in
                    return Int(f * Float(Int16.max))
                })
                
                DispatchQueue.main.async {
                    
                    self.renderTs = ts
                    let len = self.audioView.waveforms.count
                    for i in 0 ..< len {
                        let idx = ((frame.count - 1) * i) / len
                        let f: Float = sqrt(1.5 * abs(Float(frame[idx])) / Float(Int16.max))
                        self.audioView.waveforms[i] = min(49, Int(f * 50))
                    }
                    self.audioView.active = !silent
                    self.audioView.setNeedsDisplay()
                }
            }
        }
        
        do {
            self.localAudioEngine.prepare()
            try self.localAudioEngine.start()
        }
        catch let error as NSError {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
        
        self.updateUI(.recording)
    }
    
    private func stopRecording() {
        self.stopPlayer?.play()
        
        self.localAudioEngine.inputNode.removeTap(onBus: 0)
        self.localAudioEngine.stop()
        
        self.updateUI(.stopped)
    }
    
    private func updateUI(_ recorderState: RecorderState) {
        switch recorderState {
            case .recording:
                UIApplication.shared.isIdleTimerDisabled = true
                self.recordingButton.animateButtonDown(scale: 0.95)
                self.recordingButton.alpha = 0.6
                self.audioView.isHidden = false
                break
            case .stopped:
                UIApplication.shared.isIdleTimerDisabled = false
                self.recordingButton.animateButtonUp()
                self.recordingButton.alpha = 1.0
                self.audioView.isHidden = true
                break
            case .denied:
                UIApplication.shared.isIdleTimerDisabled = false
                self.recordingButton.animateButtonUp()
                self.recordingButton.alpha = 0.5
                self.audioView.isHidden = true
                break
        }
    }
    
    @objc func handleTap(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            checkPermissionAndRecord()
        } else if gesture.state == .ended {
            stopRecording()
        }
    }
    
    
    private func checkPermissionAndRecord() {
        let permission = AVAudioSession.sharedInstance().recordPermission
        
        if permission == .undetermined {
            AVAudioSession.sharedInstance().requestRecordPermission({ (result) in
                DispatchQueue.main.async {
                    if result {
                        self.startRecording()
                    }
                    else {
                        self.updateUI(.denied)
                    }
                }
            })
        } else if permission == .granted {
            self.startRecording()
        } else if permission == .denied {
            self.updateUI(.denied)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        chatRoom.delegate = self
        chatRoom.setupNetworkCommunication()
        chatRoom.joinChat(username: "Seb")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        chatRoom.stopChatSession()
    }

}

extension ViewController: ChatRoomDelegate {
    
    func received(message: Message) {
        print(message)
    }
    
    func receivedAudio(buffer: AVAudioPCMBuffer) {
        print(buffer.format)
        
        self.peerAudioPlayer.scheduleBuffer(buffer)
        self.peerAudioPlayer.volume = 100.0
        self.peerAudioPlayer.play()
    }
    
}
