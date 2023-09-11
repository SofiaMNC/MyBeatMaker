/* This content is from Apple's Sound Pad Playground */

import Foundation
import SwiftUI
import AVFoundation

class SoundPlayer: ObservableObject {
    var audioPlayer: AudioPlayer
    @Published var beatDelay: Double = 0
    
    init() {
        let engine = AVAudioEngine()
        self.audioPlayer = AudioPlayer(engine: engine)
    }
    
    init(engine: AVAudioEngine) {
        self.audioPlayer = AudioPlayer(engine: engine)
    }
    
    func playSound(_ sound: Sound, pitch: Double = 0, speed: Double = 1.0, volume: Float = 1.0, filter: AVAudioUnitDistortionPreset? = nil) {
        let pitch = 0.0
        let speed = 1.0
        let volume: Float = 1.0
        
        let node = AVAudioPlayerNode()
        let length = AudioPlayer.soundLength(sound, speed: speed)
        audioPlayer.playSound(sound, node: node, pitch: pitch, speed: speed, volume: volume, filter: filter, length: length)
        _ = Timer.scheduledTimer(withTimeInterval: length, repeats: false) { _ in
            self.stopLoop(node)
        }
    }
    
    func beatDelayCalc(isRecording: States) -> Double {
        if isRecording == .completed {
            return 0.0
        } else {
            return 2 - (Date.timeIntervalSinceReferenceDate * 100).truncatingRemainder(dividingBy: 200)/100
        }
    }
    
    func playLoop(_ sound: Sound, node: AVAudioPlayerNode, pitch: Double, speed: Double, volume: Float, filter: AVAudioUnitDistortionPreset?, isRecording: Binding<States>, isLooping: Binding<Bool>, loopingButtons: Binding<[AVAudioNode: Binding<Bool>]>) {
        let length = AudioPlayer.soundLength(sound, speed: speed)
        beatDelay = beatDelayCalc(isRecording: isRecording.wrappedValue)
        loopingButtons.wrappedValue[node] = isLooping
        DispatchQueue.main.asyncAfter(deadline: .now() + beatDelay) {
            if isLooping.wrappedValue && isRecording.wrappedValue != .completed {
                self.audioPlayer.playSound(sound, node: node, pitch: pitch, speed: speed, volume: volume, filter: filter, length: length)
            }
            let timerBlock: ((Timer) -> Void) = { [self] timer in
                if isRecording.wrappedValue == .completed || !isLooping.wrappedValue {
                    timer.invalidate()
                    isLooping.wrappedValue = false
                    loopingButtons.wrappedValue[node] = nil
                    self.stopLoop(node)
                }
            }
            let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: timerBlock)
            timerBlock(timer)
        }
    }
    
    func stopLoop(_ node: AVAudioPlayerNode) {
        node.stop()
        self.audioPlayer.removeNode(node: node)
    }
    
    func stopAllSounds(loopingButtons: Binding<[AVAudioNode: Binding<Bool>]>) {
        audioPlayer.stopEngine()
        for isLooping in loopingButtons.wrappedValue.values {
            isLooping.wrappedValue = false
        }
        loopingButtons.wrappedValue.removeAll()
    }
}
