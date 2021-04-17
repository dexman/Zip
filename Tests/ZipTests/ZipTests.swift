import XCTest
@testable import Zip

final class ZipTests: XCTestCase {
    func testZip() throws {
        let zipURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).zip")
        defer { try? FileManager.default.removeItem(at: zipURL) }

        do {
            let writer = try ZipWriter(zipURL)
            try writer.writeEntry("test.txt", "Hello, world".data(using: .utf8)!)
        }
        let attrs = try FileManager.default.attributesOfItem(atPath: zipURL.path)
        XCTAssertEqual(128, attrs[.size] as? Int)

        let reader = try ZipReader(zipURL)
        let entries = try reader.entries()
        XCTAssertEqual(["test.txt"], entries)
        let contents = try String(data: reader.readEntry("test.txt"), encoding: .utf8)
        XCTAssertEqual("Hello, world", contents)
    }

    static var allTests = [
        ("testZip", testZip),
    ]
}
