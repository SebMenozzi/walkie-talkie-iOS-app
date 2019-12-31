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
import AudioToolbox
import CocoaAsyncSocket

enum RecordingButtonState {
    case notConnected
    case connected
    case recording
    case stopped
    case denied
}

class ViewController: UIViewController {
    
    private var currentChannel: Int = 500
    
    private var lastServerTime: Int = Int(NSDate().timeIntervalSince1970)
    
    private var lastTimeAudio: Int?
    
    private var isConnected = false
    
    var socket : UDPSocket?
    
    private var audioView = AudioVisualizerView()
    private var renderTs: Double = 0
    private var recordingTs: Double = 0
    
    var startPlayer : AVAudioPlayer?
    var stopPlayer : AVAudioPlayer?
    
    var audioPlayer : AVAudioPlayer?
    
    var localAudioEngine = AVAudioEngine()
    var localAudioMixer = AVAudioMixerNode()
    var localInput: AVAudioInputNode?
    
    var peerAudioEngine = AVAudioEngine()
    var peerAudioPlayer = AVAudioPlayerNode()
    var peerInput: AVAudioInputNode?
    
    // MARK:- connected label
    let connectedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GothamRounded-Medium", size: 14)!
        label.textColor = UIColor(r: 56, g: 202, b: 81)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func setupConnectedLabel() {
        view.addSubview(connectedLabel)
        
        connectedLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        connectedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    // MARK:- Recording Button
    private let recordingButtonSize: CGFloat = UIScreen.main.bounds.width / 2
    private let recordingIconSize: CGFloat = 50
    
    private lazy var recordingButton: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: recordingButtonSize, height: recordingButtonSize))
        view.makeCorner(withRadius: recordingButtonSize / 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(handleTapRecord))
        tap.minimumPressDuration = 0
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        let layer = CAGradientLayer()
        layer.frame = view.bounds
        layer.cornerRadius = recordingButtonSize / 2
        layer.colors = [ UIColor.orange.cgColor, UIColor.yellow.cgColor ]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1.0, y: 1.0)
        view.layer.addSublayer(layer)
        
        return view
    }()
    
    let recordingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GothamRounded-Bold", size: 18)!
        label.text = "PUSH TO TALK"
        label.textColor = UIColor(white: 0, alpha: 0.4)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func setupRecordingButton() {
        view.addSubview(recordingButton)
        recordingButton.addSubview(recordingLabel)
        
        recordingButton.widthAnchor.constraint(equalToConstant: recordingButtonSize).isActive = true
        recordingButton.heightAnchor.constraint(equalToConstant: recordingButtonSize).isActive = true
        recordingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recordingButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        recordingLabel.centerYAnchor.constraint(equalTo: recordingButton.centerYAnchor).isActive = true
        recordingLabel.centerXAnchor.constraint(equalTo: recordingButton.centerXAnchor).isActive = true
    }
    
    // MARK:- On/Off Button
    private let onoffButtonSize: CGFloat = 70
    private let onoffIconSize: CGFloat = 25
    
    private lazy var onoffButton: UIView = {
       let view = UIView(frame: CGRect(x: 0, y: 0, width: onoffButtonSize, height: onoffButtonSize))
        view.backgroundColor = UIColor(r: 236, g: 60, b: 68)
        view.makeCorner(withRadius: onoffButtonSize / 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(handleTapOnOff))
        tap.minimumPressDuration = 0
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: onoffButtonSize / 2).cgPath
        view.layer.shadowColor = UIColor(r: 236, g: 60, b: 68).cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 5.0
        view.layer.masksToBounds = false
        return view
    }()
    
    let onoffIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "onoff")!.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(white: 1.0, alpha: 0.8)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private func setupOnOffButton() {
        view.addSubview(onoffButton)
        onoffButton.addSubview(onoffIcon)
        
        onoffButton.widthAnchor.constraint(equalToConstant: onoffButtonSize).isActive = true
        onoffButton.heightAnchor.constraint(equalToConstant: onoffButtonSize).isActive = true
        onoffButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        onoffButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        
        onoffIcon.widthAnchor.constraint(equalToConstant: onoffIconSize).isActive = true
        onoffIcon.heightAnchor.constraint(equalToConstant: onoffIconSize).isActive = true
        onoffIcon.centerYAnchor.constraint(equalTo: onoffButton.centerYAnchor).isActive = true
        onoffIcon.centerXAnchor.constraint(equalTo: onoffButton.centerXAnchor).isActive = true
    }
    
    fileprivate func setupAudioView() {
        audioView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(audioView)
        audioView.bottomAnchor.constraint(equalTo: onoffButton.topAnchor).isActive = true
        audioView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        audioView.heightAnchor.constraint(equalToConstant: 135).isActive = true
        audioView.isHidden = true
    }
    
    private func setupUDPServer() {
        self.socket = UDPSocket()
        self.socket?.delegate = self
        
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(nb_clients), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(ping), userInfo: nil, repeats: true)
    }
    
    @objc private func nb_clients() {
        socket?.send(message: "NB_CLIENTS \(currentChannel)")
    }
    
    @objc private func ping() {
        let diff: Int = Int(NSDate().timeIntervalSince1970) - lastServerTime
        
        if (diff > 20)
        {
            updateUI(.notConnected)
            socket?.setupConnection()
        }
        
        self.socket?.send(message: "PING")
    }
    
    lazy var lazyTimeRullerView:DYScrollRulerView = { [unowned self] in
        let unitStr = "Hz"
        
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        let margin = 0
        let window = UIApplication.shared.keyWindow
        let topPadding: Int = Int(window?.safeAreaInsets.top ?? 0)
        
        var frame = CGRect(x: margin / 2, y: topPadding + 30, width: Int(screenWidth) - margin, height: DYScrollRulerView.rulerViewHeight())
        var timerView = DYScrollRulerView(frame: frame, tminValue: 0, tmaxValue: 1000, tstep: 1, tunit: unitStr, tNum: 5, viewcontroller: self)
        timerView.setDefaultValueAndAnimated(defaultValue: Float(currentChannel), animated: true)
        timerView.delegate      = self
        timerView.scrollByHand  = true
        
        return timerView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 10, g: 10, b: 10)
        
        setupRecordingButton()
        
        setupOnOffButton()
        
        setupAudioView()
        
        setupConnectedLabel()
        
        setupAVRecorder()
        
        updateUI(.notConnected)

        view.addSubview(lazyTimeRullerView)
        
        setupUDPServer()
        
        socket?.setupConnection()
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
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .measurement)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        
        // Setting up audio engine for local recording
        self.localInput = self.localAudioEngine.inputNode
        self.localAudioEngine.attach(self.localAudioMixer)
        
        self.localAudioEngine.connect(self.localAudioMixer, to: self.localAudioEngine.mainMixerNode, format:  self.localInput?.outputFormat(forBus: 0))
        
        // Setting up audio engine for peer recording
        self.peerInput = self.peerAudioEngine.inputNode
        self.peerAudioEngine.attach(self.peerAudioPlayer)
        
        self.peerAudioEngine.connect(self.peerAudioPlayer, to: self.peerAudioEngine.mainMixerNode, format: Constants.FORMAT)
        
        do {
            self.peerAudioEngine.prepare()
            try self.peerAudioEngine.start()
        }
        catch let error as NSError {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }
    
    private func startRecording() {
        self.recordingTs = NSDate().timeIntervalSince1970
        
        guard let inputFormat = self.localInput?.inputFormat(forBus: 0) else { return }
        
        guard let fmt = Constants.FORMAT else { return }
        
        guard let converter = AVAudioConverter(from: inputFormat, to: fmt) else { return }
        
        self.localInput?.installTap(onBus: 0, bufferSize: AVAudioFrameCount(Constants.BUFFER_SIZE), format: inputFormat) { (buffer, time) in
            
            let inputCallback: AVAudioConverterInputBlock = { inNumPackets, outStatus in
                outStatus.pointee = AVAudioConverterInputStatus.haveData
                return buffer
            }

            guard let convertedBuffer = AVAudioPCMBuffer(
                pcmFormat: fmt,
                frameCapacity: AVAudioFrameCount(fmt.sampleRate) * buffer.frameLength / AVAudioFrameCount(buffer.format.sampleRate)
            ) else {
                return
            }

            var error: NSError? = nil
            let status = converter.convert(to: convertedBuffer, error: &error, withInputFrom: inputCallback)
            assert(status != .error)
            
            // send audio
            self.socket?.sendAudio(buffer: convertedBuffer)
            
            // audioView UI
            let length = UInt32(Constants.BUFFER_SIZE)
            let level: Float = -100
            
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
            
            if ts - self.renderTs > 0.05 {
                
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
        
        updateUI(.recording)
    }
    
    private func stopRecording() {
        localAudioEngine.inputNode.removeTap(onBus: 0)
        localAudioEngine.stop()
        
        updateUI(.stopped)
    }
    
    private func updateUI(_ recordingButtonState: RecordingButtonState) {
        switch recordingButtonState {
            case .notConnected:
                recordingButton.isUserInteractionEnabled = false
                recordingButton.alpha = 0.5
                audioView.isHidden = true
                onoffButton.backgroundColor = UIColor(r: 255, g: 60, b: 68)
                onoffButton.layer.shadowColor = UIColor(r: 255, g: 60, b: 68).cgColor
                lazyTimeRullerView.alpha = 1.0
                break
            case .connected:
                recordingButton.isUserInteractionEnabled = true
                recordingButton.alpha = 1.0
                audioView.isHidden = true
                onoffButton.backgroundColor = UIColor(r: 56, g: 202, b: 81)
                onoffButton.layer.shadowColor = UIColor(r: 56, g: 202, b: 81).cgColor
                lazyTimeRullerView.alpha = 0.5
                break
            case .recording:
                recordingButton.isUserInteractionEnabled = true
                recordingButton.animateButtonDown(scale: 0.95)
                recordingButton.alpha = 0.5
                audioView.isHidden = false
                break
            case .stopped:
                recordingButton.isUserInteractionEnabled = true
                recordingButton.animateButtonUp()
                recordingButton.alpha = 1.0
                audioView.isHidden = true
                break
            case .denied:
                recordingButton.isUserInteractionEnabled = true
                recordingButton.animateButtonUp()
                recordingButton.alpha = 0.5
                audioView.isHidden = true
                break
        }
    }
    
    @objc func handleTapRecord(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            // play the start sound
            self.startPlayer?.play()
            
            checkPermissionAndRecord()
        } else if gesture.state == .ended {
            // play the stop sound
            self.stopPlayer?.play()
            
            stopRecording()
        }
    }
    
    @objc func handleTapOnOff(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            self.onoffButton.animateButtonDown(scale: 0.95)
        } else if gesture.state == .ended {
            self.onoffButton.animateButtonUp()
            
            if (!isConnected)
            {
                socket?.send(message: "CONNECTION \(currentChannel)")
                updateUI(.connected)
            }
            else
            {
                socket?.send(message: "DECONNECTION")
                updateUI(.notConnected)
            }
            
            isConnected = !isConnected
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
    
    private func vibrateWithHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        
        generator.impactOccurred()
    }
}

extension ViewController: UDPSocketDelegate {
    
    func receivedNbClients(nb_clients: Int) {
        connectedLabel.text = "\(nb_clients) CONNECTED"
    }
    
    func receivedPong(time: Int) {
        lastServerTime = Int(NSDate().timeIntervalSince1970)
    }
    
    func receivedAudio(time: Int, buffer: AVAudioPCMBuffer) {
        if isConnected {
            self.stopRecording()
            self.peerAudioPlayer.scheduleBuffer(buffer)
            self.peerAudioPlayer.volume = 200.0
            self.peerAudioPlayer.play()
            self.lastTimeAudio = time
            
            
            if (lastTimeAudio != nil && time < lastTimeAudio!)
            {
                print("Audio buffer late!")
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension ViewController:DYScrollRulerDelegate {
    
    func dyScrollRulerViewValueChange(rulerView: DYScrollRulerView, value: Float) {
        let value = Int(value)
        
        if (currentChannel != value)
        {
            vibrateWithHaptic()
        }
        
        updateUI(.notConnected)
        currentChannel = value
    }
    
}
