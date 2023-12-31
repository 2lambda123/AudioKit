// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Atomics
import AudioToolbox
import AudioUnit
import AVFoundation
import Foundation

public typealias RenderJobIndex = Int

/// Information to render a single AudioUnit
final class RenderJob {
    /// Buffer we're writing to, unless overridden by buffer passed to render.
    private let outputBuffer: SynchronizedAudioBufferList

    /// Block called to render.
    private let renderBlock: AURenderBlock

    /// Input block passed to the renderBlock. We don't chain AUs recursively.
    private let inputBlock: AURenderPullInputBlock

    /// Number of inputs feeding this AU.
    var inputCount: Int32 { Int32(inputIndices.count) }

    /// Indices of jobs that this one feeds.
    var outputIndices: [Int] = []

    /// Indices of jobs feeding this one
    let inputIndices: [Int]

    public init(outputBuffer: SynchronizedAudioBufferList,
                renderBlock: @escaping AURenderBlock,
                inputBlock: @escaping AURenderPullInputBlock,
                inputIndices: [Int])
    {
        self.outputBuffer = outputBuffer
        self.renderBlock = renderBlock
        self.inputBlock = inputBlock
        self.inputIndices = inputIndices
    }

    func render(actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                timeStamp: UnsafePointer<AudioTimeStamp>,
                frameCount: AUAudioFrameCount,
                outputBufferList: UnsafeMutablePointer<AudioBufferList>?)
    {
        let out = outputBufferList ?? outputBuffer.abl
        let outputBufferListPointer = UnsafeMutableAudioBufferListPointer(out)

        // AUs may change the output size, so reset it.
        outputBufferListPointer[0].mDataByteSize = frameCount * UInt32(MemoryLayout<Float>.size)
        outputBufferListPointer[1].mDataByteSize = frameCount * UInt32(MemoryLayout<Float>.size)

        // Do the actual DSP.
        let status = renderBlock(actionFlags,
                                 timeStamp,
                                 frameCount,
                                 0,
                                 out,
                                 inputBlock)
        // Propagate errors.
        if status != noErr {
            switch status {
                case kAudioUnitErr_NoConnection:
                    print("got kAudioUnitErr_NoConnection")
                case kAudioUnitErr_TooManyFramesToProcess:
                    print("got kAudioUnitErr_TooManyFramesToProcess")
                case AVAudioEngineManualRenderingError.notRunning.rawValue:
                    print("got AVAudioEngineManualRenderingErrorNotRunning")
                case kAudio_ParamError:
                    print("got kAudio_ParamError")
                default:
                    print("unknown rendering error \(status)")
            }
        }

        // Indicate that we're done writing to the output.
        outputBuffer.endWriting()
    }
}
