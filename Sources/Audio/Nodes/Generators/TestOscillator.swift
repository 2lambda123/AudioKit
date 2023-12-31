// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioUnit
import AVFoundation
import Utilities

enum TestOscillatorCommand {
    case table(UnsafeMutablePointer<Vec<Float>>?)
}

public class TestOscillator: Node {
    public let connections: [Node] = []

    public let auAudioUnit: AUAudioUnit

    let oscAU: OscillatorAudioUnit

    public var waveform: Table? {
        didSet {
            if let waveform = waveform {
                oscAU.setWaveform(waveform)
            }
        }
    }

    /// Output Volume (Default 1), values above 1 will have gain applied
    public var amplitude: AUValue = 1.0 {
        didSet {
            amplitude = max(amplitude, 0)
            oscAU.amplitudeParam.value = amplitude
        }
    }

    // Frequency in Hz
    public var frequency: AUValue = 440 {
        didSet {
            frequency = max(frequency, 0)
            oscAU.frequencyParam.value = frequency
        }
    }

    /// Initialize the pure Swift oscillator
    /// - Parameters:
    ///   - waveform: Shape of the oscillator waveform
    ///   - frequency: Pitch in Hz
    ///   - amplitude: Volume, usually 0-1
    public init(waveform: Table = Table(.sine), frequency: AUValue = 440, amplitude: AUValue = 1.0) {
        let componentDescription = AudioComponentDescription(instrument: "pgos")
        
        AUAudioUnit.registerSubclass(OscillatorAudioUnit.self,
                                     as: componentDescription,
                                     name: "Oscillator AU",
                                     version: .max)
        auAudioUnit = instantiateAU(componentDescription: componentDescription)
        oscAU = auAudioUnit as! OscillatorAudioUnit
        self.waveform = waveform
        oscAU.amplitudeParam.value = amplitude
        self.amplitude = amplitude
        oscAU.frequencyParam.value = frequency
        self.frequency = frequency
        oscAU.setWaveform(waveform)
        self.waveform = waveform
        AudioEngine.nodeInstanceCount.wrappingIncrement(ordering: .relaxed)
    }

    deinit {
        AudioEngine.nodeInstanceCount.wrappingDecrement(ordering: .relaxed)
    }
}
