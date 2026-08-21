import Testing

@testable import RFC_6570

@Suite
struct `RFC 6570 URI Template Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `RFC 6570 URI Template Tests`.Unit {

    @Test
    func `Parse simple template`() throws {
        let template = try RFC_6570.Template("/{var}")
        #expect(template.value == "/{var}")
        #expect(template.components.count == 2)
    }

    @Test
    func `Parse template with literals and expressions`() throws {
        let template = try RFC_6570.Template("/users/{id}/posts")

        #expect(template.components.count == 3)
    }

    @Test
    func `Parse template with query parameters`() throws {
        let template = try RFC_6570.Template("/search{?q,page}")
        #expect(template.value == "/search{?q,page}")
    }

    @Test
    func `Invalid template throws error`() {
        #expect(throws: RFC_6570.Error.self) {
            try RFC_6570.Template("{invalid")
        }
    }

    @Test
    func `Empty expression throws error`() {
        #expect(throws: RFC_6570.Error.self) {
            try RFC_6570.Template("{}")
        }
    }

    @Test
    func `Expand simple variable`() throws {
        let template = try RFC_6570.Template("/{var}")
        let uri = try template.expand(variables: ["var": "value"])
        #expect(uri == "/value")
    }

    @Test
    func `Expand multiple variables`() throws {
        let template = try RFC_6570.Template("/users/{id}/posts/{postId}")
        let uri = try template.expand(variables: [
            "id": "123",
            "postId": "456",
        ])
        #expect(uri == "/users/123/posts/456")
    }

    @Test
    func `Expand with undefined variable`() throws {
        let template = try RFC_6570.Template("/{var}/{other}")
        let uri = try template.expand(variables: ["var": "value"])

        #expect(uri == "/value/")
    }

    @Test
    func `Simple expansion operator`() throws {
        let template = try RFC_6570.Template("{var}")
        let uri = try template.expand(variables: ["var": "value"])
        #expect(uri == "value")
    }

    @Test
    func `Reserved expansion operator`() throws {
        let template = try RFC_6570.Template("{+var}")
        let uri = try template.expand(variables: ["var": "hello world"])

        #expect(uri == "hello%20world")
    }

    @Test
    func `Fragment expansion operator`() throws {
        let template = try RFC_6570.Template("{#var}")
        let uri = try template.expand(variables: ["var": "section"])
        #expect(uri == "#section")
    }

    @Test
    func `Query expansion operator`() throws {
        let template = try RFC_6570.Template("{?var}")
        let uri = try template.expand(variables: ["var": "value"])
        #expect(uri == "?var=value")
    }

    @Test
    func `Query with multiple variables`() throws {
        let template = try RFC_6570.Template("{?x,y}")
        let uri = try template.expand(variables: [
            "x": "1",
            "y": "2",
        ])
        #expect(uri == "?x=1&y=2")
    }

    @Test
    func `List with simple expansion`() throws {
        let template = try RFC_6570.Template("{list}")
        let uri = try template.expand(variables: [
            "list": .list(["red", "green", "blue"])
        ])
        #expect(uri == "red,green,blue")
    }

    @Test
    func `List with explode modifier`() throws {
        let template = try RFC_6570.Template("{list*}")
        let uri = try template.expand(variables: [
            "list": .list(["red", "green", "blue"])
        ])
        #expect(uri == "red,green,blue")
    }

    @Test
    func `List with query and explode`() throws {
        let template = try RFC_6570.Template("{?list*}")
        let uri = try template.expand(variables: [
            "list": .list(["red", "green", "blue"])
        ])
        #expect(uri == "?list=red&list=green&list=blue")
    }

    @Test
    func `Dictionary with query and explode`() throws {
        let template = try RFC_6570.Template("{?dict*}")
        let uri = try template.expand(variables: [
            "dict": .dictionary(["lang": "en", "sort": "date"])
        ])

        #expect(uri == "?lang=en&sort=date")
    }

    @Test
    func `Prefix modifier`() throws {
        let template = try RFC_6570.Template("{var:3}")
        let uri = try template.expand(variables: ["var": "value"])
        #expect(uri == "val")
    }

    private static let standardVars: [String: RFC_6570.Variable] = [
        "var": "value",
        "hello": "Hello World!",
        "half": "50%",
        "empty": "",
        "who": "fred",
        "base": "http://example.com/home/",
        "path": "/foo/bar",
        "dub": "me/too",
        "v": "6",
        "x": "1024",
        "y": "768",
        "list": .list(["red", "green", "blue"]),
        "keys": ["semi": ";", "dot": ".", "comma": ","],
        "dom": .list(["example", "com"]),
        "count": .list(["one", "two", "three"]),
        "empty_keys": [:],
    ]

    @Test(arguments: [
        ("{var}", "value"),
        ("{hello}", "Hello%20World%21"),
        ("{half}", "50%25"),
        ("O{empty}X", "OX"),
        ("O{undef}X", "OX"),
        ("{x,y}", "1024,768"),
        ("{x,hello,y}", "1024,Hello%20World%21,768"),
        ("?{x,empty}", "?1024,"),
        ("?{x,undef}", "?1024"),
        ("?{undef,y}", "?768"),
        ("{var:3}", "val"),
        ("{var:30}", "value"),
        ("{list}", "red,green,blue"),
        ("{list*}", "red,green,blue"),
        ("{keys}", "semi,%3B,dot,.,comma,%2C"),
        ("{keys*}", "semi=%3B,dot=.,comma=%2C"),
    ])
    func `RFC 6570 Section 3.2.2 - Simple String Expansion`(
        template: String,
        expected: String
    ) throws {
        let tpl = try RFC_6570.Template(template)
        let result = try tpl.expand(variables: Self.standardVars)
        #expect(result.value == expected)
    }

    @Test(arguments: [
        ("{+var}", "value"),
        ("{+hello}", "Hello%20World!"),
        ("{+half}", "50%25"),
        ("{base}index", "http%3A%2F%2Fexample.com%2Fhome%2Findex"),
        ("{+base}index", "http://example.com/home/index"),
        ("O{+empty}X", "OX"),
        ("O{+undef}X", "OX"),
        ("{+path}/here", "/foo/bar/here"),
        ("here?ref={+path}", "here?ref=/foo/bar"),
        ("up{+path}{var}/here", "up/foo/barvalue/here"),
        ("{+x,hello,y}", "1024,Hello%20World!,768"),
        ("{+path,x}/here", "/foo/bar,1024/here"),
        ("{+path:6}/here", "/foo/b/here"),
        ("{+list}", "red,green,blue"),
        ("{+list*}", "red,green,blue"),
        ("{+keys}", "semi,;,dot,.,comma,,"),
        ("{+keys*}", "semi=;,dot=.,comma=,"),
    ])
    func `RFC 6570 Section 3.2.3 - Reserved Expansion`(template: String, expected: String) throws {
        let tpl = try RFC_6570.Template(template)
        let result = try tpl.expand(variables: Self.standardVars)
        #expect(result.value == expected)
    }

    @Test(arguments: [
        ("{#var}", "#value"),
        ("{#hello}", "#Hello%20World!"),
        ("{#half}", "#50%25"),
        ("foo{#empty}", "foo#"),
        ("foo{#undef}", "foo"),
        ("{#x,hello,y}", "#1024,Hello%20World!,768"),
        ("{#path,x}/here", "#/foo/bar,1024/here"),
        ("{#path:6}/here", "#/foo/b/here"),
        ("{#list}", "#red,green,blue"),
        ("{#list*}", "#red,green,blue"),
        ("{#keys}", "#semi,;,dot,.,comma,,"),
        ("{#keys*}", "#semi=;,dot=.,comma=,"),
    ])
    func `RFC 6570 Section 3.2.4 - Fragment Expansion`(template: String, expected: String) throws {
        let tpl = try RFC_6570.Template(template)
        let result = try tpl.expand(variables: Self.standardVars)
        #expect(result.value == expected)
    }

    @Test(arguments: [
        ("{.who}", ".fred"),
        ("{.who,who}", ".fred.fred"),
        ("{.half,who}", ".50%25.fred"),
        ("www{.dom*}", "www.example.com"),
        ("X{.var}", "X.value"),
        ("X{.empty}", "X."),
        ("X{.undef}", "X"),
        ("X{.var:3}", "X.val"),
        ("X{.list}", "X.red,green,blue"),
        ("X{.list*}", "X.red.green.blue"),
        ("X{.keys}", "X.semi,%3B,dot,.,comma,%2C"),
        ("X{.keys*}", "X.semi=%3B.dot=..comma=%2C"),
        ("X{.empty_keys}", "X"),
        ("X{.empty_keys*}", "X"),
    ])
    func `RFC 6570 Section 3.2.5 - Label Expansion`(template: String, expected: String) throws {
        let tpl = try RFC_6570.Template(template)
        let result = try tpl.expand(variables: Self.standardVars)
        #expect(result.value == expected)
    }

    @Test(arguments: [
        ("{/who}", "/fred"),
        ("{/who,who}", "/fred/fred"),
        ("{/half,who}", "/50%25/fred"),
        ("{/who,dub}", "/fred/me%2Ftoo"),
        ("{/var}", "/value"),
        ("{/var,empty}", "/value/"),
        ("{/var,undef}", "/value"),
        ("{/var,x}/here", "/value/1024/here"),
        ("{/var:1,var}", "/v/value"),
        ("{/list}", "/red,green,blue"),
        ("{/list*}", "/red/green/blue"),
        ("{/list*,path:4}", "/red/green/blue/%2Ffoo"),
        ("{/keys}", "/semi,%3B,dot,.,comma,%2C"),
        ("{/keys*}", "/semi=%3B/dot=./comma=%2C"),
    ])
    func `RFC 6570 Section 3.2.6 - Path Segment Expansion`(
        template: String,
        expected: String
    ) throws {
        let tpl = try RFC_6570.Template(template)
        let result = try tpl.expand(variables: Self.standardVars)
        #expect(result.value == expected)
    }

    @Test(arguments: [
        ("{;who}", ";who=fred"),
        ("{;half}", ";half=50%25"),
        ("{;empty}", ";empty"),
        ("{;v,empty,who}", ";v=6;empty;who=fred"),
        ("{;v,bar,who}", ";v=6;who=fred"),
        ("{;x,y}", ";x=1024;y=768"),
        ("{;x,y,empty}", ";x=1024;y=768;empty"),
        ("{;x,y,undef}", ";x=1024;y=768"),
        ("{;hello:5}", ";hello=Hello"),
        ("{;list}", ";list=red,green,blue"),
        ("{;list*}", ";list=red;list=green;list=blue"),
        ("{;keys}", ";keys=semi,%3B,dot,.,comma,%2C"),
        ("{;keys*}", ";semi=%3B;dot=.;comma=%2C"),
    ])
    func `RFC 6570 Section 3.2.7 - Path-Style Parameter Expansion`(
        template: String,
        expected: String
    ) throws {
        let tpl = try RFC_6570.Template(template)
        let result = try tpl.expand(variables: Self.standardVars)
        #expect(result.value == expected)
    }

    @Test(arguments: [
        ("{?who}", "?who=fred"),
        ("{?half}", "?half=50%25"),
        ("{?x,y}", "?x=1024&y=768"),
        ("{?x,y,empty}", "?x=1024&y=768&empty="),
        ("{?x,y,undef}", "?x=1024&y=768"),
        ("{?var:3}", "?var=val"),
        ("{?list}", "?list=red,green,blue"),
        ("{?list*}", "?list=red&list=green&list=blue"),
        ("{?keys}", "?keys=semi,%3B,dot,.,comma,%2C"),
        ("{?keys*}", "?semi=%3B&dot=.&comma=%2C"),
    ])
    func `RFC 6570 Section 3.2.8 - Form-Style Query Expansion`(
        template: String,
        expected: String
    ) throws {
        let tpl = try RFC_6570.Template(template)
        let result = try tpl.expand(variables: Self.standardVars)
        #expect(result.value == expected)
    }

    @Test(arguments: [
        ("{&who}", "&who=fred"),
        ("{&half}", "&half=50%25"),
        ("?fixed=yes{&x}", "?fixed=yes&x=1024"),
        ("{&x,y,empty}", "&x=1024&y=768&empty="),
        ("{&x,y,undef}", "&x=1024&y=768"),
        ("{&var:3}", "&var=val"),
        ("{&list}", "&list=red,green,blue"),
        ("{&list*}", "&list=red&list=green&list=blue"),
        ("{&keys}", "&keys=semi,%3B,dot,.,comma,%2C"),
        ("{&keys*}", "&semi=%3B&dot=.&comma=%2C"),
    ])
    func `RFC 6570 Section 3.2.9 - Form-Style Query Continuation`(
        template: String,
        expected: String
    ) throws {
        let tpl = try RFC_6570.Template(template)
        let result = try tpl.expand(variables: Self.standardVars)
        #expect(result.value == expected)
    }
}

@Suite
struct `URI Template Operators` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `URI Template Operators`.Unit {
    @Test
    func `All operators have correct prefixes`() {
        #expect(RFC_6570.Operator.simple.prefix.isEmpty)
        #expect(RFC_6570.Operator.reserved.prefix.isEmpty)
        #expect(RFC_6570.Operator.fragment.prefix == "#")
        #expect(RFC_6570.Operator.label.prefix == ".")
        #expect(RFC_6570.Operator.path.prefix == "/")
        #expect(RFC_6570.Operator.parameter.prefix == ";")
        #expect(RFC_6570.Operator.query.prefix == "?")
        #expect(RFC_6570.Operator.continuation.prefix == "&")
    }

    @Test
    func `All operators have correct separators`() {
        #expect(RFC_6570.Operator.simple.separator == ",")
        #expect(RFC_6570.Operator.reserved.separator == ",")
        #expect(RFC_6570.Operator.fragment.separator == ",")
        #expect(RFC_6570.Operator.label.separator == ".")
        #expect(RFC_6570.Operator.path.separator == "/")
        #expect(RFC_6570.Operator.parameter.separator == ";")
        #expect(RFC_6570.Operator.query.separator == "&")
        #expect(RFC_6570.Operator.continuation.separator == "&")
    }
}

@Suite
struct `Variable Value Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `Variable Value Tests`.Unit {
    @Test
    func `String value is defined`() {
        let value: RFC_6570.Variable = "hello"
        #expect(value.isDefined)
    }

    @Test
    func `Empty string is defined per RFC 6570`() {

        let value: RFC_6570.Variable = ""
        #expect(value.isDefined)
    }

    @Test
    func `List value is defined`() {
        let value: RFC_6570.Variable = ["a", "b", "c"]
        #expect(value.isDefined)
    }

    @Test
    func `Dictionary value is defined`() {
        let value: RFC_6570.Variable = ["key": "value"]
        #expect(value.isDefined)
    }
}
