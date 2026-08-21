import Buffer_Linear_Primitive
import Hash_Indexed_Primitive
import Ownership_Shared_Primitive

extension RFC_6570 {

    public struct Template: Hashable, Sendable {

        public let value: String

        internal let components: [Component]

        public init(_ value: String) throws(RFC_6570.Error) {
            self.value = value
            self.components = try Self.parse(value)
        }

        internal init(unchecked value: String, components: [Component]) {
            self.value = value
            self.components = components
        }
    }
}

extension RFC_6570.Template: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        try self.init(value)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

extension RFC_6570.Template: CustomStringConvertible {
    public var description: String { value }
}

extension RFC_6570.Template: CustomDebugStringConvertible {
    public var debugDescription: String {
        "RFC 6570.Template(\(value))"
    }
}

extension RFC_6570.Template: RawRepresentable {
    public var rawValue: String { value }

    public init?(rawValue: String) {
        do throws(RFC_6570.Error) {
            try self.init(rawValue)
        } catch {
            return nil
        }
    }
}

extension RFC_6570.Template: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value
    }
}

extension RFC_6570.Template {

    public func expand(variables: [String: RFC_6570.Variable]) -> RFC_3986.URI {
        var result = ""

        for component in components {
            switch component {
            case .literal(let literal):
                result += literal

            case .expression(let expression):
                let expanded = expandExpression(expression, variables: variables)
                result += expanded
            }
        }

        return RFC_3986.URI(unchecked: result)
    }

    private func expandExpression(
        _ expression: Expression,
        variables: [String: RFC_6570.Variable]
    ) -> String {
        let op = expression.op
        var results: [String] = []

        for varspec in expression.varspecs {
            guard let value = variables[varspec.name], value.isDefined else {

                continue
            }

            let expanded = expandVarSpec(varspec, value: value, operator: op)

            results.append(expanded)
        }

        guard !results.isEmpty else {
            return ""
        }

        let joined = results.joined(separator: op.separator)

        return op.prefix + joined
    }

    private func expandVarSpec(
        _ varspec: VarSpec,
        value: RFC_6570.Variable,
        operator op: RFC_6570.Operator
    ) -> String {
        switch value {
        case .string(let str):
            return expandString(str, varspec: varspec, operator: op)

        case .list(let list):

            guard !list.isEmpty else { return "" }
            return expandList(list, varspec: varspec, operator: op)

        case .dictionary(let dict):

            guard !dict.isEmpty else { return "" }
            return expandDictionary(dict, varspec: varspec, operator: op)
        }
    }

    private func expandString(
        _ string: String,
        varspec: VarSpec,
        operator op: RFC_6570.Operator
    ) -> String {
        var value = string

        if case .prefix(let length) = varspec.modifier {
            value = String(value.prefix(length))
        }

        let encoded = percentEncode(value, allowReserved: op.allowReserved)

        if op.named {

            if value.isEmpty && op == .parameter {

                return varspec.name
            } else if value.isEmpty {

                return "\(varspec.name)="
            } else {

                return "\(varspec.name)=\(encoded)"
            }
        } else {

            return encoded
        }
    }

    private func expandList(
        _ list: [String],
        varspec: VarSpec,
        operator op: RFC_6570.Operator
    ) -> String {
        guard !list.isEmpty else { return "" }

        let encoded = list.map { percentEncode($0, allowReserved: op.allowReserved) }

        if case .explode = varspec.modifier {

            if op.named {

                return encoded.map { "\(varspec.name)=\($0)" }.joined(separator: op.separator)
            } else {

                return encoded.joined(separator: op.separator)
            }
        } else {

            let joined = encoded.joined(separator: ",")
            if op.named {
                return "\(varspec.name)=\(joined)"
            } else {
                return joined
            }
        }
    }

    private func expandDictionary(
        _ dict: Dictionary<String, String>.Ordered.Shared,
        varspec: VarSpec,
        operator op: RFC_6570.Operator
    ) -> String {
        guard !dict.isEmpty else { return "" }

        var entries: [(key: String, value: String)] = []
        dict.forEach { key, value in entries.append((key: key, value: value)) }

        if case .explode = varspec.modifier {

            var pairs: [String] = []
            pairs.reserveCapacity(entries.count)
            for (key, value) in entries {
                let encodedKey = percentEncode(key, allowReserved: op.allowReserved)
                let encodedValue = percentEncode(value, allowReserved: op.allowReserved)
                pairs.append("\(encodedKey)=\(encodedValue)")
            }
            return pairs.joined(separator: op.separator)
        } else {

            var parts: [String] = []
            parts.reserveCapacity(entries.count * 2)
            for (key, value) in entries {
                parts.append(percentEncode(key, allowReserved: op.allowReserved))
                parts.append(percentEncode(value, allowReserved: op.allowReserved))
            }
            let joined = parts.joined(separator: ",")

            if op.named {
                return "\(varspec.name)=\(joined)"
            } else {
                return joined
            }
        }
    }

    private func percentEncode(_ string: String, allowReserved: Bool) -> String {
        if allowReserved {

            let allowed = RFC_3986.CharacterSet.unreserved.union(.reserved)
            return string.percentEncoded(allowing: allowed)
        } else {

            return string.percentEncoded(allowing: .unreserved)
        }
    }
}

extension RFC_6570.Template {

    public func expand(_ variables: [String: String]) -> RFC_3986.URI {
        let wrapped = variables.mapValues { RFC_6570.Variable.string($0) }
        return expand(variables: wrapped)
    }
}
