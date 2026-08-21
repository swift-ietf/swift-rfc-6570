extension RFC_6570.Template {

    internal struct Expression: Hashable, Sendable {
        let op: RFC_6570.Operator
        let varspecs: [VarSpec]

        init(op: RFC_6570.Operator = .simple, varspecs: [VarSpec]) {
            self.op = op
            self.varspecs = varspecs
        }
    }
}
