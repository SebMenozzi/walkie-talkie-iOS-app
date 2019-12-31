//
//  OutSocket.swift
//  Walkie Talkie
//
//  Created by Sebastien Menozzi on 28/12/2019.
//  Copyright © 2019 Sebastien Menozzi. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
import AVFoundation

protocol UDPSocketDelegate: class {
    func receivedPong(time: Int)
    func receivedAudio(time: Int, buffer: AVAudioPCMBuffer)
    func receivedNbClients(nb_clients: Int)
}

class UDPSocket: NSObject, GCDAsyncUdpSocketDelegate {
    
    var socket: GCDAsyncUdpSocket!
    
    weak var delegate: UDPSocketDelegate?
    
    func setupConnection() {
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try socket.connect(toHost: Constants.HOST, onPort: UInt16(Constants.PORT))
            try socket.beginReceiving()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func send(message: String) {
        guard let data = message.data(using: String.Encoding.utf8) else {
            print("Failure to send")
            return
        }
        
        self.socket.send(data, withTimeout: 2, tag: 0)
    }
    
    private func audioBufferToNSData(PCMBuffer: AVAudioPCMBuffer) -> Data {
        let channelCount = 1  // given PCMBuffer channel count is 1
        let channels = UnsafeBufferPointer(start: PCMBuffer.floatChannelData, count: channelCount)
        let data = Data(bytes: channels[0], count: Int(PCMBuffer.frameLength * PCMBuffer.format.streamDescription.pointee.mBytesPerFrame))
        print(data)
        return data
    }
    
    func sendAudio(buffer: AVAudioPCMBuffer)
    {
        guard var data = "AUDIO ".data(using: String.Encoding.utf8) else {
            print("Failure to send audio!")
            return
        }
        
        let buffer_data = audioBufferToNSData(PCMBuffer: buffer).base64EncodedData()
        data.append(buffer_data)
        
        self.socket.send(data, withTimeout: 2, tag: 0)
    }
    
    //MARK:- GCDAsyncUdpSocketDelegate
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        print("didConnectToAddress")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        if let _error = error {
            print("didNotConnect \(_error )")
        }
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        
        guard let decodedString = String(data: data, encoding: .utf8) else {
            print("Can't encode the data received into utf8 string!")
            return
        }
        let array = decodedString.components(separatedBy: " ")
        
        if (array.count < 1)
        {
            print("No header has been received!")
            return
        }
        
        let header = array[0]
        
        if (header == "AUDIO")
        {
            if (array.count != 3)
            {
                print("AUDIO has 2 parameters!")
                return
            }
            
            let time = Int(array[1]) ?? -1
            let stringBase64 = array[2]
            
            guard let dataBase64 = stringBase64.data(using: .utf8) else {
                print("Can't encode the utf8 string into data!")
                return
            }
            
            guard let bufferData = Data(base64Encoded: dataBase64, options: .ignoreUnknownCharacters) else { return }
            
            guard let audioFormat = Constants.FORMAT else { return }
            guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: UInt32(bufferData.count) / audioFormat.streamDescription.pointee.mBytesPerFrame) else { return }

            audioBuffer.frameLength = audioBuffer.frameCapacity
            let channels = UnsafeBufferPointer(start: audioBuffer.floatChannelData, count: Int(audioBuffer.format.channelCount))

            _ = bufferData.copyBytes(to: UnsafeMutableBufferPointer(start: channels[0], count: Int(audioBuffer.frameLength)))

            delegate?.receivedAudio(time: time, buffer: audioBuffer)
        }
        else if (header == "PONG")
        {
            if (array.count != 2)
            {
                print("PONG has 2 parameters!")
                return
            }
            
            let time = Int(array[1].replacingOccurrences(of: "\0", with: "", options: .regularExpression)) ?? -1
            
            delegate?.receivedPong(time: time)
        }
        else if (header == "NB_CLIENTS")
        {
            if (array.count != 2)
            {
                print("NB_CLIENTS has 2 parameters!")
                return
            }
            
            let nb_clients = Int(array[1].replacingOccurrences(of: "\0", with: "", options: .regularExpression)) ?? -1
            
            delegate?.receivedNbClients(nb_clients: nb_clients)
        }
    }
    
}
