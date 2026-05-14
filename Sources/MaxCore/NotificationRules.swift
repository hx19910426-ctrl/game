import Foundation

public struct NotificationRule: Equatable, Sendable {
    public let app: ChatApp
    public let bundleIdentifiers: [String]

    public init(app: ChatApp, bundleIdentifiers: [String] = []) {
        self.app = app
        self.bundleIdentifiers = bundleIdentifiers.isEmpty ? app.bundleIdentifiers : bundleIdentifiers
    }

    public func matches(bundleIdentifier: String) -> Bool {
        bundleIdentifiers.contains { $0.caseInsensitiveCompare(bundleIdentifier) == .orderedSame }
    }
}

public struct NotificationRuleSet: Sendable {
    public let rules: [NotificationRule]

    public init(rules: [NotificationRule] = ChatApp.allCases.map { NotificationRule(app: $0) }) {
        self.rules = rules
    }

    public func chatApp(forBundleIdentifier bundleIdentifier: String) -> ChatApp? {
        rules.first { $0.matches(bundleIdentifier: bundleIdentifier) }?.app
    }
}
