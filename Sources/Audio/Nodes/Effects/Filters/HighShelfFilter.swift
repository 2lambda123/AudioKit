// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/

import AVFoundation
import Utilities

/// AudioKit version of Apple's HighShelfFilter Audio Unit
///
public class HighShelfFilter: Node {
    public var au: AUAudioUnit

    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Specification details for cutOffFrequency
    public static let cutOffFrequencyDef = NodeParameterDef(
        identifier: "cutOffFrequency",
        name: "Cut Off Frequency",
        address: AUParameterAddress(kHighShelfParam_CutOffFrequency),
        defaultValue: 10000,
        range: 10000 ... 22050,
        unit: .hertz
    )

    /// Cut Off Frequency (Hertz) ranges from 10000 to 22050 (Default: 10000)
    @Parameter(cutOffFrequencyDef) public var cutOffFrequency: AUValue

    /// Specification details for gain
    public static let gainDef = NodeParameterDef(
        identifier: "gain",
        name: "Gain",
        address: AUParameterAddress(kHighShelfParam_Gain),
        defaultValue: 0,
        range: -40 ... 40,
        unit: .decibels
    )

    /// Gain (decibels) ranges from -40 to 40 (Default: 0)
    @Parameter(gainDef) public var gain: AUValue

    /// Initialize the high shelf filter node
    ///
    /// - parameter input: Input node to process
    /// - parameter cutOffFrequency: Cut Off Frequency (Hertz) ranges from 10000 to 22050 (Default: 10000)
    /// - parameter gain: Gain (decibels) ranges from -40 to 40 (Default: 0)
    ///
    public init(
        _ input: Node,
        cutOffFrequency: AUValue = cutOffFrequencyDef.defaultValue,
        gain: AUValue = gainDef.defaultValue
    ) {
        self.input = input

        let desc = AudioComponentDescription(appleEffect: kAudioUnitSubType_HighShelfFilter)
        au = instantiateAU(componentDescription: desc)
        associateParams(with: au)

        self.cutOffFrequency = cutOffFrequency
        self.gain = gain
        Engine.nodeInstanceCount.wrappingIncrement(ordering: .relaxed)
    }

    deinit {
        Engine.nodeInstanceCount.wrappingDecrement(ordering: .relaxed)
    }
}
