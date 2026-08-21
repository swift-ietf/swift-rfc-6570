extension RFC_6570.Template {

    internal enum Component: Hashable, Sendable {
        case literal(String)
        case expression(Expression)
    }
}
