import Foundation

extension URL {

    public init(template: String, variables: [String: String]) throws(RFC_6570.Error) {
        let tpl = try RFC_6570.Template(template)
        let uri = tpl.expand(variables)
        guard let url = URL(string: uri.value) else {
            throw RFC_6570.Error.expansionFailed("Result is not a valid URL: \(uri.value)")
        }
        self = url
    }

    public init(template: String, variables: [String: RFC_6570.Variable]) throws(RFC_6570.Error) {
        let tpl = try RFC_6570.Template(template)
        let uri = tpl.expand(variables: variables)
        guard let url = URL(string: uri.value) else {
            throw RFC_6570.Error.expansionFailed("Result is not a valid URL: \(uri.value)")
        }
        self = url
    }

    public init(template: RFC_6570.Template, variables: [String: String]) throws(RFC_6570.Error) {
        let uri = template.expand(variables)
        guard let url = URL(string: uri.value) else {
            throw RFC_6570.Error.expansionFailed("Result is not a valid URL: \(uri.value)")
        }
        self = url
    }

    public init(
        template: RFC_6570.Template,
        variables: [String: RFC_6570.Variable]
    ) throws(RFC_6570.Error) {
        let uri = template.expand(variables: variables)
        guard let url = URL(string: uri.value) else {
            throw RFC_6570.Error.expansionFailed("Result is not a valid URL: \(uri.value)")
        }
        self = url
    }
}
