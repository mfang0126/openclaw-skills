# Reminder Skill — 开发路线图

## 项目概述

**名称**: reminder-cron  
**目标**: 跨平台提醒系统（Mac Reminder.app + Google Tasks 同步）  
**当前状态**: MVP 阶段（Phase 1）

---

## Phase 1: MVP — Cron-based Reminder ✅ (当前)

**功能**:
- 自然语言创建提醒
- 基于 Gateway cron
- Discord 通知

**技术栈**:
- `openclaw cron add --at` — 一次性提醒
- `openclaw cron add --every` — 重复提醒
- Discord channel 通知

**已完成**:
- ✅ z.ai 续费提醒（2026-04-07 10:00）

**文件**:
- `SKILL.md` — 使用说明
- `scripts/create.sh` — 创建提醒脚本

---

## Phase 2: Mac Reminder.app 集成

**功能**:
- 创建提醒 → 同时写入 Mac Reminder.app
- 在 iPhone/iPad/Apple Watch 上同步查看

**技术栈**:
- `remindctl` — macOS 命令行工具
- 或 AppleScript 调用 Reminders.app

**依赖**:
- macOS only
- `remindctl` 安装（`brew install remindctl`）

**参考**:
- 现有 skill: `plgonzalezrx8/apple-remind-me`
- 可以直接复用其脚本逻辑

---

## Phase 3: Google Tasks 同步

**功能**:
- 创建提醒 → 同时写入 Google Tasks
- Android 设备上查看

**技术栈**:
- Google Tasks API
- OAuth 2.0 认证

**需要**:
- Google Cloud 项目
- OAuth credential（client_id + client_secret）
- 用户授权流程

**API 文档**:
- https://developers.google.com/tasks

---

## Phase 4: 双向同步 + 冲突处理

**功能**:
- Mac Reminder.app ↔ Google Tasks 双向同步
- 冲突检测（两边都改了怎么办？）

**技术方案**:
- 定时同步（cron job 每 5 分钟）
- 最后修改时间戳对比
- 冲突策略：
  - 时间戳优先（最新的覆盖）
  - 或询问用户
  - 或保留两份

**挑战**:
- Google Tasks 和 Mac Reminder 的数据模型不完全一致
- 需要映射关系（ID 对应表）

---

## Phase 5: 会议助手集成

**场景**: 开会时实时转录 + 自动创建提醒

**调研结果**:

### 现有产品对比

| 产品 | 中文支持 | 实时转录 | 总结 | 行动项 | 隐私 | 价格 |
|------|---------|---------|------|--------|------|------|
| **Slipbox** | ❌ 只支持欧洲语言 | ✅ | ✅ | ✅ | 本地 | 免费 / $99/年 |
| **Yating (雅婷)** | ✅ 台湾口音优化 | ✅ | ❌ | ❌ | 本地 | 免费 |
| **Tactiq.io** | ✅ | ✅ | ✅ | ✅ | 云端 | 付费 |
| **tl;dv** | ✅ 30+ 语言 | ✅ | ✅ | ✅ | 云端 | 付费 |
| **WhisperKit (自建)** | ✅ | ✅ | 需自己加 | 需自己加 | 本地 | 免费 |

### 方案选择

**英文会议** → Slipbox ✅  
**中文会议，只需要转录** → Yating ✅  
**中文会议，需要总结+行动项** → 
- 方案 A: 云端（Tactiq/tl;dv）
- 方案 B: 自建（WhisperKit + OpenAI API）

**自建方案技术栈**:
- WhisperKit — 本地转录（支持中文）
- AVAudioEngine — 音频捕获
- BlackHole — 系统音频捕获（Zoom/Teams）
- OpenAI/Claude API — 总结 + 行动项提取
- SwiftUI — macOS 原生界面

**MVP 功能**:
1. 实时麦克风转录 + 浮动字幕
2. 每 5 分钟自动小结
3. 会议结束完整整理（总结 + 行动项）
4. 音频录制与导出

**参考项目**:
- https://github.com/argmaxinc/WhisperKit
- https://github.com/rudrankriyam/WhisperKit-Sample
- https://github.com/Lakr233/WhisperKit

---

## 技术决策

### 为什么先做 cron 版本？

1. **最快上线** — 5 分钟搞定
2. **无依赖** — 不需要 OAuth、不需要安装工具
3. **跨平台** — Gateway cron + Discord 通知在任何设备都能收到
4. **可扩展** — 后面加 Mac/Google 同步不影响现有功能

### 为什么用 Mac Reminder + Google Tasks？

1. **原生体验** — Mac/iOS 用 Reminder.app，Android 用 Google Tasks
2. **自动同步** — iCloud 和 Google 各自处理同步
3. **无需维护后端** — 不用自己搭服务器
4. **用户已有账号** — 不用注册新服务

---

## 待确认问题

1. **Google 同步方向**:
   - Mac → Google 单向？
   - Google → Mac 单向？
   - 双向（冲突怎么处理）？

2. **Google Cloud 项目**:
   - 你已经有项目了吗？
   - 需要我帮你创建 OAuth credential 吗？

3. **会议助手优先级**:
   - 先做完 Phase 1-4（提醒系统）？
   - 还是并行开发会议助手？

---

## 下一步行动

- [ ] 创建 `reminder-cron/SKILL.md`
- [ ] 创建 `scripts/create.sh`
- [ ] 测试自然语言时间解析
- [ ] 加入 list/delete 命令
- [ ] 写 Phase 2 技术设计文档

---

**Created**: 2026-03-27  
**Last Updated**: 2026-03-27
