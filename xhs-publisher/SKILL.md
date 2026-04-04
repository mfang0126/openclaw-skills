---
name: xhs-publisher
description: |
  安全地通过 sau CLI 发布小红书笔记和视频。内置反 bot 检测策略：频率控制、时段限制、人审门控。

  USE FOR:
  - "发小红书", "发笔记", "发布小红书", "xhs post", "xhs publish"
  - "帮我发一篇小红书笔记", "upload note to xiaohongshu"
  - "发个视频到小红书", "upload video to xiaohongshu"
  - "检查小红书账号状态", "xhs session check"

  NOT FOR:
  - 搜索/读取小红书内容（用 xiaohongshu-mcp）
  - 抓取小红书数据
  - 多账号批量操作
metadata: {"clawdbot":{"emoji":"📕","requires":{"bins":["sau"]}}}
---

# 小红书安全发帖 Skill

## When to Use

- 用户要求发小红书笔记/视频
- 用户要求检查小红书账号状态
- 用户提到小红书发布/上传

不适用：搜索小红书内容、抓取数据、多账号批量操作。

## 配置

使用前，从 config.template.json 复制并填写实际值：

```
cp config.template.json config.json
```

config.json 包含：账号名、social-auto-upload 路径、频率限制参数。
脚本不直接读 config.json——由 AI 读取后通过 CLI 参数传递给脚本。

## Workflow

发布流程详见 [`workflow/publish-flow.md`](workflow/publish-flow.md)。

简要流程：读取 config.json → 检查前提 → 生成草稿 → 人审确认 → 安全发帖 → 更新状态 → 报告结果。

## Knowledge

按需查阅以下知识文件：

| 文件 | 何时查阅 |
|------|---------|
| [`knowledge/safety-policy.md`](knowledge/safety-policy.md) | 检查频率限制、超发警告、行为模拟规则 |
| [`knowledge/content-guidelines.md`](knowledge/content-guidelines.md) | 生成草稿时参考标题/正文/标签风格要求 |
| [`knowledge/cli-contract.md`](knowledge/cli-contract.md) | 查询 sau 命令格式、publish.py 参数 |
| [`knowledge/runtime-requirements.md`](knowledge/runtime-requirements.md) | 环境安装、虚拟环境激活、浏览器配置 |
| [`knowledge/troubleshooting.md`](knowledge/troubleshooting.md) | 发布失败时排查错误 |

## Hard Rules

1. **人审门控不可跳过** — 不经过用户明确确认，绝不调用任何发布命令。
2. **频率限制不可绕过** — 超过每日限额或最小间隔时，必须拒绝并说明原因。
3. **禁止时段不可突破** — 00:00-06:00 不执行任何发布操作。
4. **超发必须警告** — 达到每日上限后用户仍要求发布时，必须发出风险警告并要求二次确认。
