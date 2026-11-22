import Foundation

extension URL {

    public init(template: String, variables: [String: String]) throws(IETF.RFC.`6570`.Error) {
        let tpl = try IETF.RFC.`6570`.Template(template)
        let uri = tpl.expand(variables)
        guard let url = URL(string: uri.value) else {
            throw IETF.RFC.`6570`.Error.expansionFailed("Result is not a valid URL: \(uri.value)")
        }
        self = url
    }

    public init(template: String, variables: [String: IETF.RFC.`6570`.Variable]) throws(IETF.RFC.`6570`.Error) {
        let tpl = try IETF.RFC.`6570`.Template(template)
        let uri = tpl.expand(variables: variables)
        guard let url = URL(string: uri.value) else {
            throw IETF.RFC.`6570`.Error.expansionFailed("Result is not a valid URL: \(uri.value)")
        }
        self = url
    }

    public init(template: IETF.RFC.`6570`.Template, variables: [String: String]) throws(IETF.RFC.`6570`.Error) {
        let uri = template.expand(variables)
        guard let url = URL(string: uri.value) else {
            throw IETF.RFC.`6570`.Error.expansionFailed("Result is not a valid URL: \(uri.value)")
        }
        self = url
    }

    public init(
        template: IETF.RFC.`6570`.Template,
        variables: [String: IETF.RFC.`6570`.Variable]
    ) throws(IETF.RFC.`6570`.Error) {
        let uri = template.expand(variables: variables)
        guard let url = URL(string: uri.value) else {
            throw IETF.RFC.`6570`.Error.expansionFailed("Result is not a valid URL: \(uri.value)")
        }
        self = url
    }
}
