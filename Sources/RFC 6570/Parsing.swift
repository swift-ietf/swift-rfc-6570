extension RFC_6570.Template {

    internal static func parse(_ template: String) throws(RFC_6570.Error) -> [Component] {
        var components: [Component] = []
        var currentLiteral = ""
        var index = template.startIndex

        while index < template.endIndex {
            let char = template[index]

            if char == "{" {

                if !currentLiteral.isEmpty {
                    components.append(.literal(currentLiteral))
                    currentLiteral = ""
                }

                guard let closingIndex = template[index...].firstIndex(of: "}") else {
                    throw RFC_6570.Error.invalidTemplate(
                        "Unclosed expression starting at position \(template.distance(from: template.startIndex, to: index))"
                    )
                }

                let exprStart = template.index(after: index)
                let exprString = String(template[exprStart..<closingIndex])
                let expression = try parseExpression(exprString)
                components.append(.expression(expression))

                index = template.index(after: closingIndex)
            } else if char == "}" {
                throw RFC_6570.Error.invalidTemplate(
                    "Unexpected '}' at position \(template.distance(from: template.startIndex, to: index))"
                )
            } else {
                currentLiteral.append(char)
                index = template.index(after: index)
            }
        }

        if !currentLiteral.isEmpty {
            components.append(.literal(currentLiteral))
        }

        return components
    }

    private static func parseExpression(_ expression: String) throws(RFC_6570.Error) -> Expression {
        guard !expression.isEmpty else {
            throw RFC_6570.Error.invalidExpression("Empty expression")
        }

        var remaining = expression

        let op: RFC_6570.Operator
        if let first = remaining.first,
            let foundOperator = RFC_6570.Operator(rawValue: String(first))
        {
            op = foundOperator
            remaining.removeFirst()
        } else {
            op = .simple
        }

        let remBytes = Array(remaining.utf8)
        var varspecStrings: [String] = []
        var vsStart = 0
        remBytes.indices.forEach { idx in
            if remBytes[idx] == 0x2C {
                varspecStrings.append(String(decoding: remBytes[vsStart..<idx], as: UTF8.self))
                vsStart = idx &+ 1
            }
        }
        varspecStrings.append(String(decoding: remBytes[vsStart..<remBytes.count], as: UTF8.self))

        guard !varspecStrings.isEmpty else {
            throw RFC_6570.Error.invalidExpression("No variables in expression")
        }

        let varspecs = try varspecStrings.map { (s: String) throws(RFC_6570.Error) in
            try parseVarSpec(s)
        }

        return Expression(op: op, varspecs: varspecs)
    }

    private static func parseVarSpec(_ varspec: String) throws(RFC_6570.Error) -> VarSpec {
        guard !varspec.isEmpty else {
            throw RFC_6570.Error.invalidVariableName("Empty variable name")
        }

        var name = varspec
        var modifier: RFC_6570.Modifier? = nil

        if name.hasSuffix("*") {
            modifier = .explode
            name.removeLast()
        }

        else if let colonIndex = name.firstIndex(of: ":") {
            let prefixString = name[name.index(after: colonIndex)...]

            guard prefixString.count >= 1 && prefixString.count <= 4,
                let prefixLength = Int(prefixString),
                prefixLength > 0
            else {
                throw RFC_6570.Error.invalidModifier("Invalid prefix length: \(prefixString)")
            }
            modifier = .prefix(prefixLength)
            name = String(name[..<colonIndex])
        }

        guard isValidVariableName(name) else {
            throw RFC_6570.Error.invalidVariableName("Invalid variable name: \(name)")
        }

        return VarSpec(name: name, modifier: modifier)
    }

    private static func isValidVariableName(_ name: String) -> Bool {
        guard !name.isEmpty else { return false }

        for char in name {
            if char.ascii.isAlphanumeric || char == "_" || char == "." {
                continue
            } else if char == "%" {

                continue
            } else {
                return false
            }
        }

        return true
    }
}
