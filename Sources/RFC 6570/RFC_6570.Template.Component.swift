// MARK: - Template Components

extension RFC_6570.Template {
    /// A component of a URI template (either a literal string or an expression)
    internal enum Component: Hashable, Sendable {
        case literal(String)
        case expression(Expression)
    }
}
