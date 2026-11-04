# swift-rfc-6570

Use this package when you build URIs from URI templates such as `/users/{id}{?page,sort}`, as found in API descriptions and link relations. Parse the template once with `RFC_6570.Template`, then fill it with `RFC_6570.Template.expand(variables:)`, giving each variable as an `RFC_6570.Variable`, or with `RFC_6570.Template.expand(_:)` when every value is a string. Expansion gives an `RFC_3986.URI` from swift-rfc-3986. The package only expands templates. It does not match a URI against a template to recover the variables.

## Laws

- A template is checked when it is created, and expanding it never fails. The result is not checked as a URI.
- Creating a template fails on an unclosed `{`, a stray `}`, an empty expression, a variable name with characters other than ASCII letters, digits, `_`, `.` and `%`, a prefix length outside 1 to 9999, and a variable with both a prefix and `*`.
- Variable names are case-sensitive.
- A variable that is missing, or is an empty list or empty dictionary, is undefined and leaves no trace, not even the operator's leading character. An empty string is defined: `{?var}` gives `?var=` and `{;var}` gives `;var`.
- Values are percent-encoded as UTF-8 with uppercase hex. Only unreserved characters pass through, except with `+` and `#`, which also let reserved characters through. A `%` in a value is always written as `%25`, so a value that is already percent-encoded is encoded again.
- A prefix such as `{var:3}` keeps the first characters of a string before encoding, counted as Swift characters, not bytes. It has no effect on lists or dictionaries.
- Dictionary values expand in the order of their pairs. A dictionary literal keeps the order it is written in. `RFC_6570.Variable.init(dictionary:)` sorts the pairs by key, because a Swift dictionary has no order.
- A template encodes as its text and decodes by parsing it, so text that isn't a valid template fails to decode.
