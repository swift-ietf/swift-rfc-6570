extension RFC_6570 {

    public enum Operator: String, Hashable, Sendable, CaseIterable {

        case simple = ""

        case reserved = "+"

        case fragment = "#"

        case label = "."

        case path = "/"

        case parameter = ";"

        case query = "?"

        case continuation = "&"
    }
}

extension RFC_6570.Operator {

    var prefix: String {
        switch self {
        case .simple: return ""
        case .reserved: return ""
        case .fragment: return "#"
        case .label: return "."
        case .path: return "/"
        case .parameter: return ";"
        case .query: return "?"
        case .continuation: return "&"
        }
    }

    var separator: String {
        switch self {
        case .simple, .reserved, .fragment: return ","
        case .label: return "."
        case .path: return "/"
        case .parameter: return ";"
        case .query, .continuation: return "&"
        }
    }

    var named: Bool {
        switch self {
        case .simple, .reserved, .fragment, .label, .path: return false
        case .parameter, .query, .continuation: return true
        }
    }

    var allowReserved: Bool {
        switch self {
        case .simple, .label, .path, .parameter, .query, .continuation: return false
        case .reserved, .fragment: return true
        }
    }

    public var includesEmptyValues: Bool {
        switch self {
        case .query, .continuation:
            return true

        case .parameter:
            return false

        default:
            return true
        }
    }
}
