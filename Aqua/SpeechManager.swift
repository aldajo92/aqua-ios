//
//  SpeechManager.swift
//  Aqua
//
//  Created by Edgard Aguirre Rozo on 10/21/16.
//  Copyright © 2016 Edgard Aguirre Rozo. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import SpeechKit

class SpeechManager {
    static let sharedInstance = SpeechManager()
    var speechDelegate : SKTransactionDelegate? = nil
    var transaction: SKTransaction?
    var utterance = AVSpeechUtterance(string: "")
    let synth = AVSpeechSynthesizer()
    let session = SKSession(url: URL(string: SKSServerUrl), appToken: SKSAppKey)
    let voice = AVSpeechSynthesisVoice(language: "en-EN")
    
    private init(){}
    
    func read(text: String) {
        utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        utterance.rate = 0.5
        utterance.volume = 0.75
        synth.speak(utterance)
    }
    
    func listen() {
        loadEarcons()
        transaction = session?.recognize(withType: SKTransactionSpeechTypeDictation,
                                                       detection: .short,
                                                       language: "eng-USA",
                                                       options: nil,
                                                       delegate: speechDelegate)
    }
    
    func loadEarcons() {
        let startEarconPath = Bundle.main.path(forResource: "sk_start", ofType: "pcm")
        let stopEarconPath = Bundle.main.path(forResource: "sk_stop", ofType: "pcm")
        let errorEarconPath = Bundle.main.path(forResource: "sk_error", ofType: "pcm")
        let audioFormat = SKPCMFormat()
        audioFormat.sampleFormat = .signedLinear16
        audioFormat.sampleRate = 16000
        audioFormat.channels = 1
        session!.startEarcon = SKAudioFile(url: URL(fileURLWithPath: startEarconPath!), pcmFormat: audioFormat)
        session!.endEarcon = SKAudioFile(url: URL(fileURLWithPath: stopEarconPath!), pcmFormat: audioFormat)
        session!.errorEarcon = SKAudioFile(url: URL(fileURLWithPath: errorEarconPath!), pcmFormat: audioFormat)
    }
    
    func resetTransaction() {
        OperationQueue.main.addOperation({
            self.transaction = nil
        })
    }
}
