public import Buffer_Linear_Primitive
public import Hash_Indexed_Primitive
import Ownership_Shared_Primitive

extension RFC_6570 {

    public enum Variable: Hashable, Sendable {

        case string(String)

        case list([String])

        case dictionary(Dictionary<String, String>.Ordered.Shared)
    }
}

extension RFC_6570.Variable {

    var isDefined: Bool {
        switch self {
        case .string: return true
        case .list(let l): return !l.isEmpty
        case .dictionary(let d): return !d.isEmpty
        }
    }

    public init(dictionary: [String: String]) {

        var ordered = Dictionary<String, String>.Ordered.Shared()
        for (key, value) in dictionary.sorted(by: { $0.key < $1.key }) {
            ordered.insert(key: key, value: value)
        }
        self = .dictionary(ordered)
    }

    public static func dictionary(_ dict: [String: String]) -> RFC_6570.Variable {
        RFC_6570.Variable(dictionary: dict)
    }
}

extension RFC_6570.Variable: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension RFC_6570.Variable: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: String...) {
        self = .list(elements)
    }
}

extension RFC_6570.Variable: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String)...) {

        var ordered = Dictionary<String, String>.Ordered.Shared()
        for (key, value) in elements {
            ordered.insert(key: key, value: value)
        }
        self = .dictionary(ordered)
    }
}

extension RFC_6570.Variable {

    public var stringValue: String? {
        switch self {
        case .string(let s): return s
        default: return nil
        }
    }

    public var listValue: [String]? {
        switch self {
        case .list(let l): return l
        default: return nil
        }
    }

    public var dictionaryValue: [String: String]? {
        switch self {
        case .dictionary(let d):
            var result: [String: String] = [:]
            d.forEach { key, value in result[key] = value }
            return result

        default: return nil
        }
    }
}

extension RFC_6570.Variable {
    public static func == (lhs: RFC_6570.Variable, rhs: RFC_6570.Variable) -> Bool {
        switch (lhs, rhs) {
        case (.string(let l), .string(let r)):
            return l == r

        case (.list(let l), .list(let r)):
            return l == r

        case (.dictionary(let l), .dictionary(let r)):
            guard l.count == r.count else { return false }
            var lhsPairs: [(String, String)] = []
            l.forEach { key, value in lhsPairs.append((key, value)) }
            var rhsPairs: [(String, String)] = []
            r.forEach { key, value in rhsPairs.append((key, value)) }
            return lhsPairs.elementsEqual(rhsPairs) { $0.0 == $1.0 && $0.1 == $1.1 }

        default:
            return false
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .string(let value):
            hasher.combine(0)
            hasher.combine(value)

        case .list(let values):
            hasher.combine(1)
            hasher.combine(values)

        case .dictionary(let dictionary):
            hasher.combine(2)
            dictionary.forEach { key, value in
                hasher.combine(key)
                hasher.combine(value)
            }
        }
    }
}
