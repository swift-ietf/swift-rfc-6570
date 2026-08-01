extension RFC_6570.Template {
    /// A template expression: operator and list of variable specifications
    internal struct Expression: Hashable, Sendable {
        let op: RFC_6570.Operator
        let varspecs: [VarSpec]

        init(op: RFC_6570.Operator = .simple, varspecs: [VarSpec]) {
            self.op = op
            self.varspecs = varspecs
        }
    }
}
