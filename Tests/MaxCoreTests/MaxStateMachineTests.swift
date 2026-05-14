import Testing
@testable import MaxCore

@Test func pettingMakesMaxHappyAndReducesPokePressure() {
    let machine = MaxStateMachine(annoyanceThreshold: 2)

    _ = machine.apply(.poke)
    _ = machine.apply(.poke)
    let snapshot = machine.apply(.pet)

    #expect(snapshot.mood == .happy)
    #expect(snapshot.pokeCount == 1)
}

@Test func repeatedPokesMakeMaxAnnoyed() {
    let machine = MaxStateMachine(annoyanceThreshold: 3)

    _ = machine.apply(.poke)
    _ = machine.apply(.poke)
    let snapshot = machine.apply(.poke)

    #expect(snapshot.mood == .annoyed(level: 1))
}

@Test func chatMessageBarksAndStoresLastAppForOpening() {
    let machine = MaxStateMachine()

    let snapshot = machine.apply(.chatMessage(.wechat))

    #expect(snapshot.mood == .barking(source: .wechat))
    #expect(snapshot.barkCount == 1)
    #expect(snapshot.lastChatApp == .wechat)
}

@Test func notificationRulesMapKnownBundleIdentifiers() {
    let rules = NotificationRuleSet()

    #expect(rules.chatApp(forBundleIdentifier: "com.tencent.xinWeChat") == .wechat)
    #expect(rules.chatApp(forBundleIdentifier: "com.tencent.WeWorkMac") == .wecom)
    #expect(rules.chatApp(forBundleIdentifier: "unknown.app") == nil)
}

@Test func scriptDescribesScenarioMoods() {
    let script = InteractionScript()

    #expect(script.text(for: .listeningToMusic).contains("耳机"))
    #expect(script.text(for: .helpingInTerminal).contains("小键盘"))
    #expect(script.text(for: .taskCompleted(message: "构建完成")).contains("构建完成"))
}
