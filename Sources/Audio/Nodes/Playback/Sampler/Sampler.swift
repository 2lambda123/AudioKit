// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioFiles
import AudioUnit
import AVFoundation
import Foundation
import Utilities



public class Sampler: Node {
    public let connections: [Node] = []

    public let auAudioUnit: AUAudioUnit
    let samplerAU: SamplerAudioUnit

    public init() {
        let componentDescription = AudioComponentDescription(instrument: "tpla")

        AUAudioUnit.registerSubclass(SamplerAudioUnit.self,
                                     as: componentDescription,
                                     name: "Player AU",
                                     version: .max)
        auAudioUnit = instantiateAU(componentDescription: componentDescription)
        samplerAU = auAudioUnit as! SamplerAudioUnit
        AudioEngine.nodeInstanceCount.wrappingIncrement(ordering: .relaxed)
    }

    deinit {
        AudioEngine.nodeInstanceCount.wrappingDecrement(ordering: .relaxed)
    }

    public func stop() {
        samplerAU.stop()
    }

    public func play(_ buffer: AVAudioPCMBuffer) {
        samplerAU.play(buffer)
        samplerAU.collect()
    }

    public func play(url: URL) {
        if let buffer = try? AVAudioPCMBuffer(url: url) {
            play(buffer)
        }
    }

    public func assign(_ buffer: AVAudioPCMBuffer, to midiNote: UInt8) {
        samplerAU.setSample(buffer, midiNote: midiNote)
    }

    public func assign(url: URL, to midiNote: UInt8) {
        if let buffer = try? AVAudioPCMBuffer(url: url) {
            assign(buffer, to: midiNote)
        }
    }

    public func play(noteNumber: UInt8) {
        samplerAU.play(noteNumber: noteNumber)
    }

    public func stop(noteNumber: UInt8) {
        samplerAU.stop(noteNumber: noteNumber)
    }
}
