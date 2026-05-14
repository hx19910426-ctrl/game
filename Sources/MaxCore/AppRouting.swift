import Foundation

public struct AppLaunchRequest: Equatable, Sendable {
    public let app: ChatApp
    public let candidateBundleIdentifiers: [String]

    public init(app: ChatApp) {
        self.app = app
        self.candidateBundleIdentifiers = app.bundleIdentifiers
    }
}

public protocol ChatAppOpening: Sendable {
    func open(_ request: AppLaunchRequest) async -> Bool
}

public struct InteractionScript: Sendable {
    public var idleText = "Max 正趴在屏幕边等你。"
    public var petText = "Max 开心地摇尾巴。"
    public var annoyedText = "Max 有点烦了：别再戳啦！"
    public var musicText = "Max 戴上耳机跟着节拍摇摆。"
    public var terminalText = "Max 掏出小键盘，准备帮你查资料。"
    public var completionPrefix = "Max 完成任务提醒："

    public init() {}

    public func text(for mood: MaxMood) -> String {
        switch mood {
        case .idle:
            idleText
        case .happy:
            petText
        case .annoyed:
            annoyedText
        case .listeningToMusic:
            musicText
        case .helpingInTerminal:
            terminalText
        case let .taskCompleted(message):
            "\(completionPrefix)\(message)"
        case let .barking(source):
            "汪汪！\(source.displayName) 来消息了。"
        }
    }
}
