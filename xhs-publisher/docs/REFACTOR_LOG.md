# xhs-publisher Skill 重构记录

> 日期：2026-04-02
> 状态：重构完成，待修复 5 个 🟡 问题后合并

---

## 一、背景

### 1.1 我们有什么

| 组件 | 位置 | 说明 |
|------|------|------|
| **social-auto-upload** | [dreammis/social-auto-upload](https://github.com/dreammis/social-auto-upload) | 原始项目，Python CLI 多平台自动发帖工具 |
| **xiaohongshu-upload skill** | `social-auto-upload/skills/xiaohongshu-upload/` | 原作者自带的 skill，教 AI 怎么调 CLI |
| **xhs-publisher skill** | [mfang0126/openclaw-skills](https://github.com/mfang0126/openclaw-skills/tree/main/xhs-publisher) | 我们写的安全增强版 skill |

### 1.2 原版 vs 我们的

| | 原版 xiaohongshu-upload | 我们的 xhs-publisher |
|--|--|--|
| 定位 | 基础操作手册 | 安全发帖系统 |
| 发帖速度 | 18 秒 | 3-6 分钟（故意慢） |
| 频率限制 | ❌ 无 | ✅ 每日 ≤5 篇，间隔 ≥2 小时 |
| 时段限制 | ❌ 无 | ✅ 00:00-06:00 禁止 |
| 人审门控 | ❌ 无 | ✅ 必须用户确认才发 |
| 状态追踪 | ❌ 无 | ✅ state.json 记录每次发帖 |
| 反 bot 行为 | ❌ 无 | ✅ 预热、延迟、点赞、刷推荐 |

**一句话：原版是"怎么调 CLI"，我们的是"怎么不被封号地调 CLI"。**

### 1.3 我们从原版学到的

1. **职责隔离** — SKILL.md 只做入口，细节放 references/（不要把所有内容塞一个文件）
2. **明确的"不要做什么"** — 告诉 AI 不要读源码、不要绕过限制
3. **模板文件** — 给 AI 提供可复制的命令模板
4. **多账号设计** — `--account` 传自定义名称，不硬编码

---

## 二、重构思路

### 2.1 发现的问题

原版 skill 暗含了一个三层结构，但没有显式标注：

```
SKILL.md（入口）
├── 🔄 Workflow（默认工作流）— 但混在正文里
├── 🧠 Knowledge（参考文档）— 放在 references/ 下
└── ⚡ Skill（执行能力）— sau 命令
```

我们的 xhs-publisher 把所有内容（安全策略、流程、命令、内容规范、状态管理）全塞在一个 4003 字的 SKILL.md 里，AI 每次都要读完整文件，但其实只需要用到其中一部分。

### 2.2 三维度架构

从原版学到的隐式结构，我们把它显式化、规范化：

```
xhs-publisher/
├── SKILL.md                        ← 📍 入口（~300字，只做路由）
├── workflow/
│   └── publish-flow.md             ← 🔄 流程（Step 1-6）
├── knowledge/
│   ├── safety-policy.md            ← 🧠 安全策略（频率、反bot、人审）
│   ├── content-guidelines.md       ← 🧠 内容规范（标题、正文、标签）
│   ├── cli-contract.md             ← 🧠 命令格式（sau + publish.py）
│   ├── runtime-requirements.md     ← 🧠 环境安装
│   └── troubleshooting.md          ← 🧠 故障排查
├── scripts/
│   └── .gitkeep                    ← ⚡ publish.py 占位
├── evals/
│   └── evals.json                  ← 📋 7 个测试用例
└── state.json                      ← 📊 发帖状态
```

### 2.3 为什么这样拆

| 维度 | 解决什么 | AI 什么时候读 |
|------|---------|-------------|
| **🧠 Knowledge** | "需要知道什么" | 需要查规则/参数时按需读 |
| **🔄 Workflow** | "按什么顺序做" | 决定执行时读一次 |
| **⚡ Skill** | "具体怎么执行" | 执行到那一步时读 |

**AI 的自然思考方式就是：这是什么？ → 我该怎么做？ → 我该调什么？**

### 2.4 核心原则

1. **SKILL.md 要薄** — AI 先读入口判断要不要用，再按需读其他文件
2. **Knowledge 文件自包含** — 每个文件独立可读，不依赖其他文件
3. **跨文件引用用相对路径** — `knowledge/safety-policy.md`
4. **不要所有 skill 都拆** — 简单 skill 一个文件够用，只有复杂的才需要分层

---

## 三、Review 方法论

### 3.1 为什么用 Opus review

我们想验证重构结果的质量，但自己写自己 review 不客观。所以：

1. **spawn 一个 Opus sub-agent** — 它没有我们的对话上下文，更客观
2. **不给任何预设信息** — 只告诉它"这是重构后的 skill，帮我 review"
3. **6 个维度** — 架构、内容准确性、一致性、eval 覆盖率、完整性、质量

### 3.2 遇到的问题：Opus 读到旧文件

前两次 Opus review 结果完全错误（说没有 workflow/ 和 knowledge/ 目录、SKILL.md 还是 4003 字、频率限制还是 2 篇），原因是 **sub-agent 的 prompt cache 带了旧内容**。

| 尝试 | 结果 | 原因 |
|------|------|------|
| v1: 让 Opus 自己读文件 | ❌ 5/10，全部误判 | 读到了旧缓存 |
| v2: 强制先 find 再 read | ❌ 6/10，仍然误判 | 还是读到了旧缓存 |
| v3: 把所有文件内容直接塞进 prompt | ✅ 7/10，终于准确 | 没有缓存干扰 |

### 3.3 经验教训

> **让 AI review 文件时，把文件内容直接塞进 prompt，不要让它自己读。**
> 
> Sub-agent 的 prompt cache 可能包含旧版本的文件内容，导致 AI 基于错误信息做判断。只有把正确内容直接放在 prompt 里，才能保证 review 的准确性。

---

## 四、Review 结果（Opus v3）

### 4.1 最终评分：7/10

### 4.2 🟢 做得好的

- SKILL.md 够薄，路由清晰
- knowledge 文件自包含，可独立阅读
- 人审门控在 3 个文件里都强调了（关键规则适当重复）
- publish.py 命令在 cli-contract.md 和 publish-flow.md 里完全一致
- 中文表达自然
- eval 5-7 覆盖了超发模式的确认/取消分支

### 4.3 🟡 应该修的（5 个）

| # | 问题 | 状态 |
|---|------|------|
| 1 | publish.py 没有 `--account` 参数，但 sau 命令需要 | ⏳ 待修 |
| 2 | state.json 示例时间是 `"02:11"`，在禁止时段 00:00-06:00 内 | ⏳ 待修 |
| 3 | 多图语法不清晰 — content-guidelines 说"空格分隔"但 cli-contract 只展示单张 | ⏳ 待修 |
| 4 | ±30 分钟偏移在 safety-policy 里提了但没说明怎么实现 | ⏳ 待修 |
| 5 | 缺少"2 小时间隔违规"的 eval 测试用例 | ⏳ 待修 |

### 4.4 🔴 必须修的（1 个）

| 问题 | 说明 |
|------|------|
| publish.py 不在 repo 里 | 整个安全策略依赖这个脚本，但它是本地文件（含路径写死），不适合公开 |

**结论：** 这不是 bug，publish.py 存在于本地 `~/.openclaw/skills/xhs-publisher/scripts/` 但不适合放进公开 repo。需要在 SKILL.md 或 cli-contract.md 里明确说明。

### 4.5 💡 可以改进的

- 加一个视频上传的 eval 测试用例
- troubleshooting 加上小红书反 bot 检测时的表现
- SKILL.md 加个"快速检查"一行命令

---

## 五、下一步

1. ✅ ~~重构 SKILL.md 为三层架构~~ 完成
2. ✅ ~~清理 workspace-claude 路径~~ 完成
3. ✅ ~~Opus review~~ 完成
4. ⏳ 修复 5 个 🟡 问题
5. ⏳ Commit & Push
6. ⏳ 验证 AI 实际使用效果

---

## 六、对其他 Skill 的启示

这次重构验证了三维度架构的可行性。可以推广到其他复杂 skill：

- 简单 skill（一个文件够用）→ 不需要拆
- 复杂 skill（安全策略、状态管理、多步骤流程）→ 用 Knowledge / Workflow / Skill 三层

**Skill 的本质不是代码，而是"给 AI 的结构化说明书"。写好说明书的关键是：薄的入口 + 按需翻页。**
