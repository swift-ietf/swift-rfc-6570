import Testing

@testable import RFC_6570

@Suite
struct `Prefix Modifier Deep Dive` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `Prefix Modifier Deep Dive`.Unit {

    @Test
    func `Prefix counts characters correctly`() throws {
        let template = try RFC_6570.Template("{var:3}")

        var result = try template.expand(variables: ["var": "value"])
        #expect(result.value == "val")

        result = try template.expand(variables: ["var": "👨‍👩‍👧‍👦ABC"])

        print("Emoji test result: \(result)")
    }

    @Test
    func `Prefix modifier supports up to 9999`() throws {
        let template = try RFC_6570.Template("{var:9999}")
        let result = try template.expand(variables: ["var": "test"])
        #expect(result.value == "test")
    }

    @Test
    func `Five-digit prefix should fail`() {

        #expect(throws: RFC_6570.Error.self) {
            try RFC_6570.Template("{var:10001}")
        }
    }
}
