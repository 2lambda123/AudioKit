// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation

/// Renders contents of a file
class TestPlayerAudioUnit: AUAudioUnit {

    private var inputBusArray: AUAudioUnitBusArray!
    private var outputBusArray: AUAudioUnitBusArray!

    let inputChannelCount: NSNumber = 2
    let outputChannelCount: NSNumber = 2

    var floatChannelDatas: [FloatChannelData] = []
    var files: [AVAudioFile] = [] {
        didSet {
            floatChannelDatas.removeAll()
            for file in files {
                if let data = file.toFloatChannelData() {
                    floatChannelDatas.append(data)
                }
            }
        }
    }

    override public var channelCapabilities: [NSNumber]? {
        return [inputChannelCount, outputChannelCount]
    }

    /// Initialize with component description and options
    /// - Parameters:
    ///   - componentDescription: Audio Component Description
    ///   - options: Audio Component Instantiation Options
    /// - Throws: error
    override public init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {

        try super.init(componentDescription: componentDescription, options: options)

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        inputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: .input, busses: [])
        outputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: .output, busses: [try AUAudioUnitBus(format: format)])

        parameterTree = AUParameterTree.createTree(withChildren: [])
    }

    override var inputBusses: AUAudioUnitBusArray {
        inputBusArray
    }

    override var outputBusses: AUAudioUnitBusArray {
        outputBusArray
    }

    override func allocateRenderResources() throws {

    }

    override func deallocateRenderResources() {

    }

    var playheadInSamples: Int = 0
    var isPlaying: Bool = false

    override var internalRenderBlock: AUInternalRenderBlock {
        { (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
           timeStamp: UnsafePointer<AudioTimeStamp>,
           frameCount: AUAudioFrameCount,
           outputBusNumber: Int,
           outputBufferList: UnsafeMutablePointer<AudioBufferList>,
           renderEvents: UnsafePointer<AURenderEvent>?,
           inputBlock: AURenderPullInputBlock?) in

            let ablPointer = UnsafeMutableAudioBufferListPointer(outputBufferList)

            for frame in 0 ..< Int(frameCount) {
                var value: Float = 0.0
                let sample = self.playheadInSamples + frame
                if sample < self.floatChannelDatas[0][0].count {
                    value = self.floatChannelDatas[0][0][sample]
                }
                for buffer in ablPointer {
                    let buf = UnsafeMutableBufferPointer<Float>(buffer)
                    assert(frame < buf.count)
                    buf[frame] = self.isPlaying ? value : 0.0
                }
            }
            if self.isPlaying {
                self.playheadInSamples += Int(frameCount)
            }

            return noErr
        }
    }

}

class TestPlayer: Node {
    let connections: [Node] = []

    let avAudioNode: AVAudioNode
    let testPlayerAU: TestPlayerAudioUnit

    /// Position of playback in seconds
    var playheadPosition: Double = 0.0

    func movePlayhead(to position: Double) {
        testPlayerAU.playheadInSamples = Int(position * 44100)
    }

    func rewind() {
        movePlayhead(to: 0)
    }

    func play() {
        testPlayerAU.isPlaying = true
    }

    func stop() {
        testPlayerAU.isPlaying = false
    }


    init(file: AVAudioFile) {

        let componentDescription = AudioComponentDescription(generator: "tpla")

        AUAudioUnit.registerSubclass(TestPlayerAudioUnit.self,
                                     as: componentDescription,
                                     name: "Player AU",
                                     version: .max)
        avAudioNode = instantiate(componentDescription: componentDescription)
        testPlayerAU = avAudioNode.auAudioUnit as! TestPlayerAudioUnit
        testPlayerAU.files.append(file)
    }
}