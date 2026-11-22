extension IETF.RFC.`6570` {

    public enum Modifier: Hashable, Sendable {

        case prefix(Int)

        case explode
    }
}
