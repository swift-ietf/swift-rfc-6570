import Testing

@testable import RFC_6570

@Suite
struct `Final Edge Case Validation` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `Final Edge Case Validation`.Unit {

    @Test
    func `Prefix applied before encoding`() throws {

        let template = try RFC_6570.Template("{var:2}")
        let result = try template.expand(variables: ["var": "你好"])

        #expect(result.value == "%E4%BD%A0%E5%A5%BD")
    }

    @Test
    func `Prefix with percent in string`() throws {
        let template = try RFC_6570.Template("{var:2}")
        let result = try template.expand(variables: ["var": "50%"])
        #expect(result.value == "50")
    }

    @Test
    func `Modifier applies to single variable only`() throws {
        let template = try RFC_6570.Template("{x:2,y}")
        let result = try template.expand(variables: [
            "x": "hello",
            "y": "world",
        ])
        #expect(result.value == "he,world")
    }

    @Test
    func `Prefix with exact length`() throws {
        let template = try RFC_6570.Template("{var:5}")
        let result = try template.expand(variables: ["var": "hello"])
        #expect(result.value == "hello")
    }

    @Test
    func `Percent encoding produces uppercase hex`() throws {
        let template = try RFC_6570.Template("{var}")
        let result = try template.expand(variables: ["var": "hello world"])

        #expect(result.value == "hello%20world")
    }

    @Test
    func `List with single element`() throws {
        let template = try RFC_6570.Template("{list}")
        let result = try template.expand(variables: [
            "list": .list(["single"])
        ])
        #expect(result.value == "single")
    }

    @Test
    func `Dictionary with single pair`() throws {
        let template = try RFC_6570.Template("{?keys*}")
        let result = try template.expand(variables: [
            "keys": .dictionary(["key": "value"])
        ])
        #expect(result.value == "?key=value")
    }

    @Test
    func `Prefix modifier ignored for dictionary`() throws {
        let template = try RFC_6570.Template("{keys:3}")
        let result = try template.expand(variables: [
            "keys": .dictionary(["a": "1", "b": "2"])
        ])

        #expect(result.value == "a,1,b,2")
    }

    @Test
    func `Explode with single list element`() throws {
        let template = try RFC_6570.Template("{?list*}")
        let result = try template.expand(variables: [
            "list": .list(["single"])
        ])
        #expect(result.value == "?list=single")
    }

    @Test
    func `Tilde passes through unencoded`() throws {
        let template = try RFC_6570.Template("{var}")
        let result = try template.expand(variables: ["var": "~user"])
        #expect(result.value == "~user")
    }
}
