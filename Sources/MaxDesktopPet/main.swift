import MaxCore

#if canImport(AppKit)
import AppKit

@main
final class MaxDesktopPetApp: NSObject, NSApplicationDelegate {
    private let stateMachine = MaxStateMachine()
    private let script = InteractionScript()
    private var petWindow: NSWindow?
    private var petView: MaxPetView?
    private let opener = MacChatAppOpener()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        showPetWindow()
    }

    private func showPetWindow() {
        let view = MaxPetView(frame: NSRect(x: 0, y: 0, width: 180, height: 180))
        view.onInteraction = { [weak self] interaction in
            self?.handle(interaction)
        }

        let window = NSWindow(
            contentRect: NSRect(x: 300, y: 300, width: 180, height: 180),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.contentView = view
        window.makeKeyAndOrderFront(nil)

        petWindow = window
        petView = view
        render(stateMachine.snapshot)
    }

    private func handle(_ interaction: MaxInteraction) {
        let snapshot = stateMachine.apply(interaction)
        render(snapshot)

        if interaction == .doubleClick, let app = snapshot.lastChatApp {
            Task { _ = await opener.open(AppLaunchRequest(app: app)) }
        }
    }

    private func render(_ snapshot: MaxSnapshot) {
        petView?.caption = script.text(for: snapshot.mood)
        petView?.mood = snapshot.mood
        petView?.needsDisplay = true
        NSSound(named: "Funk")?.playIfNeeded(for: snapshot.mood)
    }
}

final class MaxPetView: NSView {
    var onInteraction: ((MaxInteraction) -> Void)?
    var mood: MaxMood = .idle
    var caption = ""
    private var dragStart: NSPoint?
    private var isDraggingPet = false

    override var acceptsFirstResponder: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.clear.setFill()
        dirtyRect.fill()

        drawPuppy(in: bounds.insetBy(dx: 18, dy: 24))
        drawCaption()
    }

    override func mouseDown(with event: NSEvent) {
        dragStart = event.locationInWindow
        isDraggingPet = false
        if event.clickCount == 2 {
            onInteraction?(.doubleClick)
        } else if event.modifierFlags.contains(.option) {
            onInteraction?(.poke)
        } else {
            onInteraction?(.pet)
        }
    }

    override func mouseDragged(with event: NSEvent) {
        guard let window, let dragStart else { return }
        if !isDraggingPet {
            isDraggingPet = true
            onInteraction?(.pickUp)
        }
        let current = event.locationInWindow
        let delta = NSPoint(x: current.x - dragStart.x, y: current.y - dragStart.y)
        var origin = window.frame.origin
        origin.x += delta.x
        origin.y += delta.y
        window.setFrameOrigin(origin)
    }

    override func mouseUp(with event: NSEvent) {
        dragStart = nil
        if isDraggingPet {
            isDraggingPet = false
            onInteraction?(.place)
        }
    }

    private func drawPuppy(in rect: NSRect) {
        let bodyColor = NSColor(calibratedRed: 0.93, green: 0.63, blue: 0.22, alpha: 1)
        let earColor = NSColor(calibratedRed: 0.72, green: 0.43, blue: 0.15, alpha: 1)
        let accent = NSColor(calibratedRed: 0.99, green: 0.84, blue: 0.48, alpha: 1)

        bodyColor.setFill()
        NSBezierPath(ovalIn: NSRect(x: rect.midX - 44, y: rect.minY + 6, width: 88, height: 82)).fill()
        NSBezierPath(ovalIn: NSRect(x: rect.midX - 50, y: rect.minY + 56, width: 100, height: 82)).fill()

        earColor.setFill()
        NSBezierPath(ovalIn: NSRect(x: rect.midX - 70, y: rect.minY + 58, width: 38, height: 58)).fill()
        NSBezierPath(ovalIn: NSRect(x: rect.midX + 32, y: rect.minY + 58, width: 38, height: 58)).fill()

        accent.setFill()
        NSBezierPath(ovalIn: NSRect(x: rect.midX - 28, y: rect.minY + 68, width: 56, height: 38)).fill()

        NSColor.black.setFill()
        NSBezierPath(ovalIn: NSRect(x: rect.midX - 22, y: rect.minY + 102, width: 8, height: 10)).fill()
        NSBezierPath(ovalIn: NSRect(x: rect.midX + 14, y: rect.minY + 102, width: 8, height: 10)).fill()
        NSBezierPath(ovalIn: NSRect(x: rect.midX - 6, y: rect.minY + 88, width: 12, height: 9)).fill()

        drawMoodAccessory(in: rect)
    }

    private func drawMoodAccessory(in rect: NSRect) {
        switch mood {
        case .listeningToMusic:
            NSColor.systemBlue.setStroke()
            let path = NSBezierPath()
            path.lineWidth = 5
            path.appendArc(
                withCenter: NSPoint(x: rect.midX, y: rect.minY + 112),
                radius: 42,
                startAngle: 25,
                endAngle: 155,
                clockwise: false
            )
            path.stroke()
            NSColor.systemBlue.setFill()
            NSBezierPath(roundedRect: NSRect(x: rect.midX - 56, y: rect.minY + 82, width: 16, height: 30), xRadius: 6, yRadius: 6).fill()
            NSBezierPath(roundedRect: NSRect(x: rect.midX + 40, y: rect.minY + 82, width: 16, height: 30), xRadius: 6, yRadius: 6).fill()
        case .helpingInTerminal:
            NSColor.darkGray.setFill()
            NSBezierPath(roundedRect: NSRect(x: rect.midX - 42, y: rect.minY + 12, width: 84, height: 24), xRadius: 5, yRadius: 5).fill()
            NSColor.systemGreen.setFill()
            NSString(string: ">_").draw(at: NSPoint(x: rect.midX - 35, y: rect.minY + 16), withAttributes: [.foregroundColor: NSColor.systemGreen])
        case .annoyed:
            NSColor.systemRed.setStroke()
            let path = NSBezierPath()
            path.move(to: NSPoint(x: rect.midX - 28, y: rect.minY + 120))
            path.line(to: NSPoint(x: rect.midX - 12, y: rect.minY + 128))
            path.move(to: NSPoint(x: rect.midX + 28, y: rect.minY + 120))
            path.line(to: NSPoint(x: rect.midX + 12, y: rect.minY + 128))
            path.lineWidth = 3
            path.stroke()
        case .barking:
            NSColor.systemOrange.setFill()
            NSString(string: "汪!").draw(at: NSPoint(x: rect.midX + 42, y: rect.minY + 126), withAttributes: [.foregroundColor: NSColor.systemOrange, .font: NSFont.boldSystemFont(ofSize: 20)])
        default:
            break
        }
    }

    private func drawCaption() {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.labelColor,
            .font: NSFont.systemFont(ofSize: 11, weight: .medium),
            .paragraphStyle: paragraph
        ]
        NSString(string: caption).draw(in: NSRect(x: 8, y: 4, width: bounds.width - 16, height: 28), withAttributes: attributes)
    }
}

struct MacChatAppOpener: ChatAppOpening {
    func open(_ request: AppLaunchRequest) async -> Bool {
        for bundleIdentifier in request.candidateBundleIdentifiers {
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
                do {
                    try await NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
                    return true
                } catch {
                    continue
                }
            }
        }
        return false
    }
}

private extension NSSound {
    func playIfNeeded(for mood: MaxMood) {
        guard case .barking = mood else { return }
        play()
    }
}
#else
@main
enum MaxDesktopPetCLI {
    static func main() {
        let script = InteractionScript()
        let stateMachine = MaxStateMachine()
        print(script.text(for: stateMachine.snapshot.mood))
        print("MaxDesktopPet needs AppKit to show the floating pet window. Build and run on macOS.")
    }
}
#endif
