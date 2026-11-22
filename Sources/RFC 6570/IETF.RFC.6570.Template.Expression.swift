extension IETF.RFC.`6570`.Template {

    internal struct Expression: Hashable, Sendable {
        let op: IETF.RFC.`6570`.Operator
        let varspecs: [VarSpec]

        init(op: IETF.RFC.`6570`.Operator = .simple, varspecs: [VarSpec]) {
            self.op = op
            self.varspecs = varspecs
        }
    }
}
