extension RFC_6570.Template {

    internal struct VarSpec: Hashable, Sendable {
        let name: String
        let modifier: RFC_6570.Modifier?

        init(name: String, modifier: RFC_6570.Modifier? = nil) {
            self.name = name
            self.modifier = modifier
        }
    }
}
