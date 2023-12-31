// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import CryptoKit
import XCTest

class TableTests: AKTestCase {
    func MD5(_ string: String) -> String {
        let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }

    func testPositiveSawtooth() {
        XCTAssertEqual(MD5("\(Table(.positiveSawtooth).content)"), "b0d38e424a4f667b7213ddbeffb163ea")
    }

    func testPositiveSine() {
        let md5s = ["6e6cf289adef24957d785c1b916215a2", "43ff51a686e02c6aa9a0aab2e72c81fa"]
        XCTAssertTrue(md5s.contains(MD5("\(Table(.positiveSine).content)")))
    }

    func testPositiveSquare() {
        XCTAssertEqual(MD5("\(Table(.positiveSquare).content)"), "6b2a5e42d97b4472190d8d88a5078e08")
    }

    func testPositiveTriangle() {
        XCTAssertEqual(MD5("\(Table(.positiveTriangle).content)"), "b8176e769d36f84e53bfa8c77875fac8")
    }

    func testReverseSawtooth() {
        XCTAssertEqual(MD5("\(Table(.reverseSawtooth).content)"), "818da16ec1a9882218af2b24e7133369")
    }

    func testSawtooth() {
        XCTAssertEqual(MD5("\(Table(.sawtooth).content)"), "bf2f159da29e56bce563a43ec254bc44")
    }

    func testSine() {
        let md5s = ["ca89fcc197408b4829fa946c86a42855", "4e6df1c04689bc4a8cc57f712c43352b"]
        XCTAssertTrue(md5s.contains(MD5("\(Table(.sine).content)")))
    }

    func testSquare() {
        XCTAssertEqual(MD5("\(Table(.square).content)"), "d105f98e99354e7476dd6bba9cadde66")
    }

    func testTriangle() {
        XCTAssertEqual(MD5("\(Table(.triangle).content)"), "26dba54983ca6a960f1ac3abbe3ab9eb")
    }

    func testHarmonicWithPartialAmplitudes() {
        let partialAmplitudes: [Float] = [0.8, 0.2, 0.3, 0.06, 0.12, 0.0015]
        let table = Table(.harmonic(partialAmplitudes))
        let md5s = ["2e5695816694e97c824fea9b7edf9d7f", "db6d7a5af8bf379dc292df278b823dc9"]
        XCTAssertTrue(md5s.contains(MD5("\(table.content)")))
    }
}
