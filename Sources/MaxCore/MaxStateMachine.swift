import Foundation

public final class MaxStateMachine: @unchecked Sendable {
    private let annoyanceThreshold: Int
    private var mood: MaxMood = .idle
    private var pokeCount = 0
    private var barkCount = 0
    private var isBeingDragged = false
    private var lastChatApp: ChatApp?

    public init(annoyanceThreshold: Int = 4) {
        precondition(annoyanceThreshold > 0, "annoyanceThreshold must be positive")
        self.annoyanceThreshold = annoyanceThreshold
    }

    @discardableResult
    public func apply(_ interaction: MaxInteraction) -> MaxSnapshot {
        switch interaction {
        case .pet:
            pokeCount = max(0, pokeCount - 1)
            mood = .happy
        case .poke:
            pokeCount += 1
            if pokeCount >= annoyanceThreshold {
                mood = .annoyed(level: pokeCount - annoyanceThreshold + 1)
            } else {
                mood = .happy
            }
        case .pickUp:
            isBeingDragged = true
            mood = .happy
        case .place:
            isBeingDragged = false
            mood = .idle
        case .doubleClick:
            if let lastChatApp {
                mood = .barking(source: lastChatApp)
            }
        case .musicStarted:
            mood = .listeningToMusic
        case .musicStopped:
            mood = .idle
        case .terminalActivated:
            mood = .helpingInTerminal
        case let .taskCompleted(message):
            mood = .taskCompleted(message: message)
        case let .chatMessage(app):
            barkCount += 1
            lastChatApp = app
            mood = .barking(source: app)
        }

        return snapshot
    }

    public var snapshot: MaxSnapshot {
        MaxSnapshot(
            mood: mood,
            barkCount: barkCount,
            pokeCount: pokeCount,
            isBeingDragged: isBeingDragged,
            lastChatApp: lastChatApp
        )
    }
}
