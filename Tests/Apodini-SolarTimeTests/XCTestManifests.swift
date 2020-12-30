import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Apodini_SolarTimeTests.allTests),
    ]
}
#endif
