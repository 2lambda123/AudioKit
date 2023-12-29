// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/

import AVFoundation
import Utilities

/// AudioKit version of Apple's BandPassFilter Audio Unit
///
public class BandPassFilter: Node {
    public var auAudioUnit: AUAudioUnit

    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Specification details for centerFrequency
    public static let centerFrequencyDef = NodeParameterDef(
        identifier: "centerFrequency",
        name: "Center Frequency",
        address: AUParameterAddress(kBandpassParam_CenterFrequency),
        defaultValue: 5000,
        range: 20 ... 22050,
        unit: .hertz
    )

    /// Center Frequency (Hertz) ranges from 20 to 22050 (Default: 5000)
    @Parameter(centerFrequencyDef) public var centerFrequency: AUValue

    /// Specification details for bandwidth
    public static let bandwidthDef = NodeParameterDef(
        identifier: "bandwidth",
        name: "Bandwidth",
        address: AUParameterAddress(kBandpassParam_Bandwidth),
        defaultValue: 600,
        range: 100 ... 12000,
        unit: .cents
    )

    /// Bandwidth (Cents) ranges from 100 to 12000 (Default: 600)
    @Parameter(bandwidthDef) public var bandwidth: AUValue

    /// Initialize the band pass filter node
    ///
    /// - parameter input: Input node to process
    /// - parameter centerFrequency: Center Frequency (Hertz) ranges from 20 to 22050 (Default: 5000)
    /// - parameter bandwidth: Bandwidth (Cents) ranges from 100 to 12000 (Default: 600)
    ///
    public init(
        _ input: Node,
        centerFrequency: AUValue = centerFrequencyDef.defaultValue,
        bandwidth: AUValue = bandwidthDef.defaultValue
    ) {
        self.input = input

        let desc = AudioComponentDescription(appleEffect: kAudioUnitSubType_BandPassFilter)
        auAudioUnit = instantiateAU(componentDescription: desc)
        associateParams(with: auAudioUnit)

        self.centerFrequency = centerFrequency
        self.bandwidth = bandwidth
        AudioEngine.nodeInstanceCount.wrappingIncrement(ordering: .relaxed)
    }

    deinit {
        AudioEngine.nodeInstanceCount.wrappingDecrement(ordering: .relaxed)
    }
}
