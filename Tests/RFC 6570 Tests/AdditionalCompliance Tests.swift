import Testing

@testable import RFC_6570

enum `AdditionalCompliance Tests` {}

extension `AdditionalCompliance Tests` {
    @Suite
    struct `Additional RFC 6570 Compliance Tests` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension `AdditionalCompliance Tests`.`Additional RFC 6570 Compliance Tests`.Unit {

    @Test
    func `Reserved expansion passes pct-encoded triplets through`() throws {
        let reserved = try RFC_6570.Template("{+var}")
        #expect(reserved.expand(variables: ["var": "a%41b%2"]).value == "a%41b%252")

        let fragment = try RFC_6570.Template("{#var}")
        #expect(fragment.expand(variables: ["var": "%e2%82%ac%zz"]).value == "#%e2%82%ac%25zz")

        let simple = try RFC_6570.Template("{var}")
        #expect(simple.expand(variables: ["var": "%41"]).value == "%2541")
    }

    @Test
    func `Prefix modifier should not apply to lists`() throws {

        let template = try RFC_6570.Template("{list:3}")
        let result = template.expand(variables: [
            "list": .list(["red", "green", "blue"])
        ])

        #expect(result.value == "red,green,blue")
    }

    @Test
    func `Prefix modifier can have up to 4 digits`() throws {
        let template = try RFC_6570.Template("{var:9999}")
        let result = template.expand(variables: ["var": "test"])
        #expect(result.value == "test")
    }

    @Test
    func `Cannot combine prefix and explode modifiers`() {

        #expect(throws: RFC_6570.Error.self) {
            try RFC_6570.Template("{var:3*}")
        }
    }

    @Test
    func `All reserved characters in fragment expansion`() throws {
        let template = try RFC_6570.Template("{#var}")
        let reserved = ":/?#[]@!$&'()*+,;="
        let result = template.expand(variables: ["var": .string(reserved)])
        #expect(result.value == "#:/?#[]@!$&'()*+,;=")
    }

    @Test
    func `Multiple uses of same variable`() throws {
        let template = try RFC_6570.Template("{var}{var}{var}")
        let result = template.expand(variables: ["var": "test"])
        #expect(result.value == "testtesttest")
    }

    @Test
    func `Multiple variables in one expression`() throws {
        let template = try RFC_6570.Template("{?a,b,c}")
        let result = template.expand(variables: [
            "a": "1",
            "b": "2",
            "c": "3",
        ])
        #expect(result.value == "?a=1&b=2&c=3")
    }

    @Test
    func `Literal text between expressions`() throws {
        let template = try RFC_6570.Template("http://example.com{/path}{?query}")
        let result = template.expand(variables: [
            "path": "users",
            "query": "active",
        ])
        #expect(result.value == "http://example.com/users?query=active")
    }

    @Test
    func `Semicolon operator with list explode`() throws {
        let template = try RFC_6570.Template("{;list*}")
        let result = template.expand(variables: [
            "list": .list(["a", "b", "c"])
        ])
        #expect(result.value == ";list=a;list=b;list=c")
    }

    @Test
    func `Percent-encoded variable names`() throws {
        let template = try RFC_6570.Template("{var%20name}")
        let result = template.expand(variables: ["var%20name": "value"])
        #expect(result.value == "value")
    }

    @Test
    func `Variable names are case-sensitive`() throws {
        let template = try RFC_6570.Template("{Var}{var}{VAR}")
        let result = template.expand(variables: [
            "Var": "A",
            "var": "B",
            "VAR": "C",
        ])
        #expect(result.value == "ABC")
    }
}
