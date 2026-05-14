import Foundation

public enum MaxMood: Equatable, Sendable {
    case idle
    case happy
    case annoyed(level: Int)
    case listeningToMusic
    case helpingInTerminal
    case taskCompleted(message: String)
    case barking(source: ChatApp)
}

public enum MaxInteraction: Equatable, Sendable {
    case pet
    case poke
    case pickUp
    case place
    case doubleClick
    case musicStarted
    case musicStopped
    case terminalActivated
    case taskCompleted(String)
    case chatMessage(ChatApp)
}

public enum ChatApp: String, CaseIterable, Codable, Equatable, Sendable {
    case feishu
    case wechat
    case qq
    case wecom

    public var displayName: String {
        switch self {
        case .feishu: "飞书"
        case .wechat: "微信"
        case .qq: "QQ"
        case .wecom: "企业微信"
        }
    }

    public var bundleIdentifiers: [String] {
        switch self {
        case .feishu:
            ["com.electron.lark", "com.bytedance.lark", "com.larksuite.Lark"]
        case .wechat:
            ["com.tencent.xinWeChat", "com.tencent.WeChat"]
        case .qq:
            ["com.tencent.qq", "com.tencent.QQ"]
        case .wecom:
            ["com.tencent.WeWorkMac", "com.tencent.WeWork"]
        }
    }
}

public struct MaxSnapshot: Equatable, Sendable {
    public let mood: MaxMood
    public let barkCount: Int
    public let pokeCount: Int
    public let isBeingDragged: Bool
    public let lastChatApp: ChatApp?

    public init(
        mood: MaxMood,
        barkCount: Int,
        pokeCount: Int,
        isBeingDragged: Bool,
        lastChatApp: ChatApp?
    ) {
        self.mood = mood
        self.barkCount = barkCount
        self.pokeCount = pokeCount
        self.isBeingDragged = isBeingDragged
        self.lastChatApp = lastChatApp
    }
}
