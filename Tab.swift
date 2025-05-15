enum Tab: String, CaseIterable, Identifiable, Hashable {
    case home
    case vehicles
    case messages
    case profile
    case callUs

    var id: String { self.rawValue }
}
