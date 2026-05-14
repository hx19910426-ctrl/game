# MaxDesktopPet

MaxDesktopPet 是一个 macOS 桌面端小宠物原型：一只名叫 **Max** 的小金毛会悬浮在桌面上，响应抚摸、戳戳、拖拽摆放、聊天消息提醒，以及音乐/终端等场景状态。

## 已实现的基础能力

- **宠物形象与互动**：AppKit 悬浮透明窗口绘制 Max 的小金毛形象；单击视为抚摸，按住 Option 单击视为戳戳，戳多了会进入烦躁状态；拖拽可以把 Max 放到屏幕任意位置。
- **消息提醒模型**：内置飞书、微信、QQ、企业微信的 Bundle ID 规则；收到聊天事件后 Max 会进入“汪汪提醒”状态，并记录最后一个消息来源。
- **双击打开聊天软件**：双击 Max 时，会按记录的消息来源尝试通过 macOS Bundle ID 打开对应聊天应用。
- **场景化互动状态**：支持播放音乐、终端帮忙、任务完成等状态文案和绘制附件（耳机、小键盘、汪汪气泡等）。
- **可测试核心逻辑**：`MaxCore` 将状态机、提醒规则、脚本文案与 macOS UI 解耦，便于后续接入真实系统事件。

## 运行

在 macOS 上运行：

```bash
swift run MaxDesktopPet
```

在 Linux CI 中也可以构建核心逻辑与 CLI fallback，但桌面悬浮窗口需要 AppKit，因此必须在 macOS 上才能显示完整桌宠。

## 交互说明

| 操作 | 效果 |
| --- | --- |
| 单击 Max | 抚摸，Max 开心摇尾巴 |
| Option + 单击 Max | 戳戳，连续戳多次 Max 会烦 |
| 拖拽 Max | 提起并放置到任意屏幕位置 |
| 双击 Max | 打开最近一次提醒对应的聊天软件 |

## 后续接入建议

macOS 没有公开 API 允许普通 App 直接读取所有其他聊天软件的通知内容。后续可以采用以下组合方案：

1. 使用 Accessibility 权限或自动化脚本检测特定 App 的红点/窗口标题变化，只保存来源，不读取消息正文。
2. 为飞书、企业微信等企业工具接入官方 Bot/Webhook 或本地桥接服务，向 `MaxCore` 发送 `chatMessage` 事件。
3. 使用 `NSWorkspace` 监听前台应用变化，当前台为 Terminal/iTerm/VS Code 终端时触发 `terminalActivated`。
4. 使用媒体播放器脚本、MediaRemote 桥接或 AppleScript 监听音乐播放状态，触发 `musicStarted` / `musicStopped`。
