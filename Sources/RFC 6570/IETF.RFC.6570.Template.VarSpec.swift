extension IETF.RFC.`6570`.Template {

    internal struct VarSpec: Hashable, Sendable {
        let name: String
        let modifier: IETF.RFC.`6570`.Modifier?

        init(name: String, modifier: IETF.RFC.`6570`.Modifier? = nil) {
            self.name = name
            self.modifier = modifier
        }
    }
}
