extension RFC_6570 {

    public enum Modifier: Hashable, Sendable {

        case prefix(Int)

        case explode
    }
}
