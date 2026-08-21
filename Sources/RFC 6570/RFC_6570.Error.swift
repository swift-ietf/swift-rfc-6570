extension RFC_6570 {

    public enum Error: Swift.Error, Hashable, Sendable, CustomStringConvertible {

        case invalidTemplate(String)

        case invalidExpression(String)

        case invalidVariableName(String)

        case invalidModifier(String)

        case expansionFailed(String)

        case matchingFailed(String)
    }
}

extension RFC_6570.Error {
    public var description: String {
        switch self {
        case .invalidTemplate(let msg):
            return "Invalid URI template: \(msg)"

        case .invalidExpression(let msg):
            return "Invalid expression: \(msg)"

        case .invalidVariableName(let msg):
            return "Invalid variable name: \(msg)"

        case .invalidModifier(let msg):
            return "Invalid modifier: \(msg)"

        case .expansionFailed(let msg):
            return "Template expansion failed: \(msg)"

        case .matchingFailed(let msg):
            return "Template matching failed: \(msg)"
        }
    }
}
