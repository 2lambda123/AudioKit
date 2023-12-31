// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioUnit

/// Instantiate AUAudioUnit
public func instantiateAU(componentDescription: AudioComponentDescription) -> AUAudioUnit {
    var result: AUAudioUnit!
    let runLoop = RunLoop.current
    AUAudioUnit.instantiate(with: componentDescription) { auAudioUnit, _ in
        guard let au = auAudioUnit else { fatalError("Unable to instantiate AUAudioUnit") }
        runLoop.perform {
            result = au
        }
    }
    while result == nil {
        runLoop.run(until: .now + 0.01)
    }
    return result
}
