//
//  File.swift
//  swift-rfc-6570
//
//  Created by Coen ten Thije Boonkkamp on 19/11/2025.
//

// Conformance visibility for the `.Ordered.Shared` alias's generic constraints
// (__HashIndexed: __StoreProtocol & __BufferProtocol live here).
public import Buffer_Linear_Primitive
public import Hash_Indexed_Primitive
public import Ownership_Shared_Primitive

extension RFC_6570 {
    /// A value that can be used in template expansion
    public enum Variable: Hashable, Sendable {
        /// A simple string value
        case string(String)

        /// A list of string values
        case list([String])

        /// An associative array (dictionary) of string key-value pairs.
        ///
        /// Uses the insertion-ordered dictionary on the CoW `Shared` column
        /// (`Dictionary<String, String>.Ordered.Shared`) — Copyable, so it is a legal
        /// `Equatable`/`Hashable`/`Sendable` enum payload — to preserve insertion order
        /// for RFC expansion. Retyped for ratified decider #8: the default `.Ordered`
        /// column went move-only upstream, so the CoW `Shared` spelling is the Copyable
        /// configuration this enum requires.
        case dictionary(Dictionary<String, String>.Ordered.Shared)
    }
}

extension RFC_6570.Variable {
    /// Returns whether this value is defined per RFC 6570
    ///
    /// Note: Empty strings ARE defined. Only missing/nil values are undefined.
    /// Empty lists and dictionaries are treated as undefined.
    var isDefined: Bool {
        switch self {
        case .string: return true  // Empty strings are defined!
        case .list(let l): return !l.isEmpty
        case .dictionary(let d): return !d.isEmpty
        }
    }

    /// Creates a dictionary value from a Swift Dictionary
    /// - Parameter dict: The dictionary to convert
    /// - Note: Keys will be sorted alphabetically for consistent output
    public init(dictionary: [String: String]) {
        // [RULE-EXEMPT-6] class (stdlib-shadow). `Dictionary` here resolves to the
        // institute `__Dictionary` family, which vends the `.Ordered` nest alias
        // ([DS-028]) — NOT `Swift.Dictionary`. The sugar `[String: String]` always
        // binds to `Swift.Dictionary`, which has no `Ordered` member, so the rule's
        // autocorrect does not compile. The generic spelling is load-bearing.
        // swiftlint:disable:next syntactic_sugar
        var ordered = Dictionary<String, String>.Ordered.Shared()
        for (key, value) in dictionary.sorted(by: { $0.key < $1.key }) {
            ordered.insert(key: key, value: value)
        }
        self = .dictionary(ordered)
    }

    /// Creates a dictionary variable from a standard Swift dictionary
    /// - Parameter dict: The dictionary to convert
    /// - Note: Keys will be sorted alphabetically for consistent output
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
        // [RULE-EXEMPT-6] class (stdlib-shadow) — see `init(dictionary:)` above.
        // swiftlint:disable:next syntactic_sugar
        var ordered = Dictionary<String, String>.Ordered.Shared()
        for (key, value) in elements {
            ordered.insert(key: key, value: value)
        }
        self = .dictionary(ordered)
    }
}

extension RFC_6570.Variable {
    /// Returns the value as a string if possible
    public var stringValue: String? {
        switch self {
        case .string(let s): return s
        default: return nil
        }
    }

    /// Returns the value as a list if possible
    public var listValue: [String]? {
        switch self {
        case .list(let l): return l
        default: return nil
        }
    }

    /// Returns the value as a dictionary if possible
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

// MARK: - Equatable / Hashable
//
// The `.dictionary` payload (`Dictionary<String, String>.Ordered.Shared`) is a CoW
// box that does not itself conform to `Equatable`/`Hashable`, so the compiler cannot
// synthesize these for `Variable`. Hand-written conformances give the correct,
// insertion-order-sensitive semantics an ordered dictionary demands (retyped for
// ratified decider #8).

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
