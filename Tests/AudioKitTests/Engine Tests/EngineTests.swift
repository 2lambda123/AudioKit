// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import AVFoundation
import XCTest

class EngineTests: AKTestCase {
    func testBasic() throws {
        let engine = AudioEngine()

        let osc = TestOscillator()

        engine.output = osc

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testEffect() throws {
        let engine = AudioEngine()

        let osc = TestOscillator()
        let fx = Distortion(osc)

        engine.output = fx

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testTwoEffects() throws {
        let engine = AudioEngine()

        let osc = TestOscillator()
        let dist = Distortion(osc)
        let dyn = PeakLimiter(dist)

        engine.output = dyn

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    /// Test changing the output chain on the fly.
    func testDynamicChange() throws {
        let engine = AudioEngine()

        let osc = TestOscillator()
        let dist = Distortion(osc)

        engine.output = osc

        let audio = engine.startTest(totalDuration: 2.0)

        audio.append(engine.render(duration: 1.0))

        engine.output = dist

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testMixer() throws {
        let engine = AudioEngine()

        let osc1 = TestOscillator()
        let osc2 = TestOscillator()
        osc2.frequency = 466.16 // dissonance, so we can really hear it

        let mix = Mixer([osc1, osc2])

        engine.output = mix

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testMixerVolume() throws {
        let engine = AudioEngine()

        let osc1 = TestOscillator()
        let osc2 = TestOscillator()
        osc2.frequency = 466.16 // dissonance, so we can really hear it

        let mix = Mixer([osc1, osc2])

        mix.volume = 0.02

        engine.output = mix

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testMixerDynamic() throws {
        let engine = AudioEngine()

        let osc1 = TestOscillator()
        let osc2 = TestOscillator()
        osc2.frequency = 466.16 // dissonance, so we can really hear it

        let mix = Mixer([osc1])

        engine.output = mix

        let audio = engine.startTest(totalDuration: 2.0)

        audio.append(engine.render(duration: 1.0))

        mix.addInput(osc2)

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testMixerVolume2() throws {
        let avAudioEngineMixerMD5s: [String] = [
            // Apple                            // Intel
            "07a5ba764493617dcaa54d16e8cbec99", "07a5ba764493617dcaa54d16e8cbec99",
            "1366766f7dfa7282c0f15150c8ad09f7", "4c049625d8134b4b234001087dfa08b1",
            "34d94eb74e7a6baff6b3f01615516824", "da9299ce5c94da455395e412bc2f8846",
            "1b6fcf41250ee6acef62fd8aa9653159", "613b27aae615de44b04a311b08925eb6",
            "96f75d59420c90eefa2a9f953902f358", "6325bd86b8fb3b6493fbe25da5f74fef",
            "5e2d75d048f097335e87c5ab3645078e", "686a334df6312dc622012af8f0bc2144",
        ]

        for volume in [0.0, 0.1, 0.5, 0.8, 1.0, 2.0] {
            let engine = AudioEngine()
            let osc = TestOscillator()
            let mix = Mixer(osc)
            mix.volume = AUValue(volume)
            engine.output = mix
            let audio = engine.startTest(totalDuration: 1.0)
            audio.append(engine.render(duration: 1.0))

            XCTAssertTrue(avAudioEngineMixerMD5s.contains(audio.md5))
        }
    }

    func testMixerPan() throws {
        let duration = 1.0

        let avAudioEngineMixerMD5s: [String] = [
            // Apple                            // Intel
            "71957476da05b8e62115113c419625cb", "8dbaaea230000bb5c238a77a9947e871",
            "4988fa152c867d15c8b263c4b9ae66aa", "b029fb0977393a5d528cdd9f97a0c671",
            "71a9223cde9f0288fe339bd3e3ba57e3", "7564518f76a4df7c8940ce937e124b6c",
            "32a97296e60a398a8b6f5533817e7e69", "3f41dee5d0df1474fa85ab51e6caeb94",
            "5f6a773a46341897356a5997dd73245b", "7bf74ad225d7cd4b4c93b1d4cd3704b3",
            "b18e555120c1e7fa2103e55cb718d42d", "b54ae9d495debab4a24cbf9b90cf09be",
            "cfc283772998074a5b0e38fff916a87a", "c3dcae3096a659433bc630fa39f897f4",
        ]

        for pan in [-0.75, -0.5, -0.25, 0.0, 0.25, 0.5, 0.75] {
            let engine = AudioEngine()
            let oscL = TestOscillator()
            let oscR = TestOscillator()
            oscR.frequency = 500
            let mixL = Mixer(oscL)
            let mixR = Mixer(oscR)
            mixL.pan = -1.0
            mixR.pan = 1.0
            let mixer = Mixer(mixL, mixR)
            mixer.pan = AUValue(pan)
            engine.output = mixer
            let audio = engine.startTest(totalDuration: duration)
            audio.append(engine.render(duration: duration))

            XCTAssertTrue(avAudioEngineMixerMD5s.contains(audio.md5))
        }
    }

    /// Test some number of changes so schedules are released.
    func testMultipleChanges() throws {
        let engine = AudioEngine()

        let osc1 = TestOscillator()
        let osc2 = TestOscillator()

        osc1.frequency = 880

        engine.output = osc1

        let audio = engine.startTest(totalDuration: 10.0)

        for i in 0 ..< 10 {
            audio.append(engine.render(duration: 1.0))
            engine.output = (i % 2 == 1) ? osc1 : osc2
        }

        testMD5(audio)
    }

    /// Lists all AUs on the system so we can identify which Apple ones are available.
    func testListAUs() throws {
        let auManager = AVAudioUnitComponentManager.shared()

        // Get an array of all available Audio Units
        let audioUnits = auManager.components(passingTest: { _, _ in true })

        for audioUnit in audioUnits {
            // Get the audio unit's name
            let name = audioUnit.name

            print("Audio Unit: \(name)")
        }
    }

    func testOscillator() {
        let engine = AudioEngine()
        let osc = TestOscillator()
        engine.output = osc
        let audio = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testSysexEncoding() {
        let value = 42
        let sysex = encodeSysex(value)

        XCTAssertEqual(sysex.count, 19)

        var decoded = 0
        decodeSysex(sysex, count: 19, &decoded)

        XCTAssertEqual(decoded, 42)
    }

    func testManyOscillatorsPerf() throws {
        let engine = AudioEngine()

        let mixer = Mixer()

        for _ in 0 ..< 20 {
            let osc = TestOscillator()
            mixer.addInput(osc)
        }

        mixer.volume = 0.001
        engine.output = mixer

        measure {
            let audio = engine.startTest(totalDuration: 2.0)
            audio.append(engine.render(duration: 2.0))
        }
    }
}
