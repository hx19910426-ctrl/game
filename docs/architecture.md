# Max 桌宠架构设计

## 模块划分

- `MaxCore`：平台无关核心模块，包含 Max 的状态机、聊天软件识别规则、文案脚本和打开应用请求模型。
- `MaxDesktopPet`：macOS 入口。可用 AppKit 创建无边框透明悬浮窗口、绘制小金毛、处理鼠标交互和打开聊天软件。
- `Tests/MaxCoreTests`：覆盖戳戳烦躁、消息提醒、场景文案和 Bundle ID 识别等关键逻辑。

## 事件流

1. 交互源产生 `MaxInteraction`：例如鼠标单击、拖拽、聊天消息、音乐播放、终端激活。
2. `MaxStateMachine.apply(_:)` 更新 Max 的情绪、计数和最近消息来源。
3. UI 层读取 `MaxSnapshot`，绘制对应表情/道具，并展示 `InteractionScript` 生成的中文提示。
4. 如果用户双击且存在最近聊天来源，UI 层创建 `AppLaunchRequest` 并交给 macOS 打开器。

## 权限与隐私边界

- 聊天提醒默认只识别“哪个 App 来消息”，不读取消息正文。
- 如果后续使用 Accessibility，需要在首次启动时引导用户到系统设置中授予权限。
- 如果接入企业聊天 Webhook，应将 Token 存储在 Keychain，避免写入仓库或明文配置。
