//
//  ChatRoom.swift
//  Walkie Talkie
//
//  Created by Sebastien Menozzi on 26/12/2019.
//  Copyright © 2019 Sebastien Menozzi. All rights reserved.
//

import UIKit
import AVFoundation

protocol ChatRoomDelegate: class {
    func received(message: Message)
    func receivedAudio(buffer: AVAudioPCMBuffer)
}

class ChatRoom: NSObject {
    
    var inputStream: InputStream!
    var outputStream: OutputStream!
    
    weak var delegate: ChatRoomDelegate?
    
    var username = ""
    
    let maxReadLength = 4096
    
    func setupNetworkCommunication() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(
            kCFAllocatorDefault,
            "192.168.1.13" as CFString,
            8080,
            &readStream,
            &writeStream
        )
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        
        inputStream.open()
        outputStream.open()
    }
    
    func joinChat(username: String) {
        let data = "iam:\(username)".data(using: .utf8)!
        
        self.username = username
        
        
        _ = data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                print("Error joining chat")
                return
            }
            
            outputStream.write(pointer, maxLength: data.count)
        }
    }
    
    func send(message: String) {
        let data = "msg:\(message)".data(using: .utf8)!

        _ = data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                print("Error joining chat")
                return
            }
            
            outputStream.write(pointer, maxLength: data.count)
        }
    }
    
    private func audioBufferToNSData(PCMBuffer: AVAudioPCMBuffer) -> Data {
        let channelCount = 1  // given PCMBuffer channel count is 1
        let channels = UnsafeBufferPointer(start: PCMBuffer.floatChannelData, count: channelCount)
        let data = Data(bytes: channels[0], count: Int(PCMBuffer.frameCapacity * PCMBuffer.format.streamDescription.pointee.mBytesPerFrame))
        return data
    }
    
    func sendAudio(buffer: AVAudioPCMBuffer)
    {
        let data = audioBufferToNSData(PCMBuffer: buffer)
        
        _ = data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                print("Error joining chat")
                return
            }
            
            outputStream.write(pointer, maxLength: data.count)
        }
    }
    
    func stopChatSession() {
        inputStream.close()
        outputStream.close()
    }
    
}

extension ChatRoom: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        switch eventCode {
            case .hasBytesAvailable:
                readAvailableBytes(stream: aStream as! InputStream)
            case .endEncountered:
                stopChatSession()
            case .errorOccurred:
                print("error occurred")
            case .hasSpaceAvailable:
                print("has space available")
            default:
                print("some other event...")
        }
    }

    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)

            if numberOfBytesRead < 0, let error = stream.streamError {
                print(error)
                break
            }

            // Construct the message object
            if let message = processedMessageString(buffer: buffer, length: numberOfBytesRead) {
                delegate?.received(message: message)
            } else if let audioBuffer = processedAudioBuffer(buffer: buffer, length: numberOfBytesRead) {
                print("audio")
                delegate?.receivedAudio(buffer: audioBuffer)
            }
        }
    }

    private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>, length: Int) -> Message? {
        
        guard let stringArray = String(bytesNoCopy: buffer, length: length, encoding: .utf8, freeWhenDone: true)?.components(separatedBy: ":"),
              let name = stringArray.first,
              let message = stringArray.last else {
            return nil
        }
    
        let messageSender: MessageSender = (name == self.username) ? .ourself : .someoneElse

        return Message(message: message, messageSender: messageSender, username: name)
    }
    
     private func processedAudioBuffer(buffer: UnsafeMutablePointer<UInt8>, length: Int) -> AVAudioPCMBuffer? {
        let data = Data(bytes: buffer, count: length)
        
        guard let audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false) else { return nil }
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: UInt32(data.count) / audioFormat.streamDescription.pointee.mBytesPerFrame) else { return nil }
        
        audioBuffer.frameLength = audioBuffer.frameCapacity
        let channels = UnsafeBufferPointer(start: audioBuffer.floatChannelData, count: Int(audioBuffer.format.channelCount))
        
        _ = data.copyBytes(to: UnsafeMutableBufferPointer(start: channels[0], count: Int(audioBuffer.frameLength)))
        
        return audioBuffer
    }
}
