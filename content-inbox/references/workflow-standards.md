# Workflow Standards — 每步 Done 标准

> 5 步流程：Capture → Draft → Approve & Route → Adapt → Publish + Track

---

## Step 1: Capture

**输入：** 任何形式 — URL、语音笔记、文字想法、视频链接
**输出：** `data/drafts/inbox/YYYY-MM-DD-slug.md`
**SLA：** 即时处理，不过夜

### Done Checklist
- [ ] 是什么？（视频/文章/想法/链接）
- [ ] 来源是哪？
- [ ] 为什么值得留？（一句话）
- [ ] 标记了 `status: capture`

### 不够好的信号
只存了个链接，两周后不知道这是什么

---

## Step 2: Draft

**输入：** Capture 阶段的素材
**输出：** `data/drafts/inbox/YYYY-MM-DD-slug.md`（status 更新为 `draft`）
**SLA：** Capture 后 7 天内完成 draft，否则标记 `archived`（冷藏）

### Done Checklist
- [ ] 有一句话核心观点？
- [ ] 不认识你的人读完能理解？
- [ ] 有例子或证据支撑？
- [ ] 有明确的读者画像？
- [ ] 标记了 `evergreen` 还是 `timely`？
- [ ] 标记了建议 `content_pillar`？
- [ ] 标记了 `language: en/zh/both`？

### 不够好的信号
三天后自己回来读也要想半天"我当时要说什么"

---

## Step 3: Approve & Route

**输入：** 完成的 draft
**输出：** `status: ready` + 确定的 `target_platforms`
**SLA：** Draft 完成后 3 天内审批

### Done Checklist
- [ ] 观点站得住？
- [ ] 语气对？
- [ ] 没有说错的事实？
- [ ] 愿意署名？
- [ ] 选了目标平台，且有一句话理由？
- [ ] 移到 `data/drafts/ready/`

### AI 预审（Agent 自动检查）
- 事实性：有没有可验证的错误？
- 敏感词：有没有平台可能降权的词？
- 字数：适合哪些平台？

### 不够好的信号
"差不多吧"但说不出哪里不对；为了发而发没想过谁会看

---

## Step 4: Adapt

**输入：** Ready 的 draft + 目标平台列表
**输出：** 每个平台一份适配版本

### Done Checklist
- [ ] 字数在平台甜区内？
- [ ] 有 3+ 平台特色元素（hashtag、emoji、格式）？
- [ ] 语言正确（英文平台英文，中文平台中文）？
- [ ] 语气符合平台调性？
- [ ] 看起来像原生内容，不像复制粘贴？

### 不够好的信号
一眼看出是同一篇复制到不同平台的

---

## Step 5: Publish + Track

**输入：** 适配完成的各平台版本
**输出：** 发布成功 + 效果记录

### Publish Checklist
- [ ] Ming 确认了才发（**绝对不自动发**）
- [ ] 在目标时间窗口内发出？
- [ ] API 返回成功 / 帖子可见？
- [ ] 记录到 `data/published/YYYY-MM-DD-slug-platform.md`

### 发布后互动（1h 内）
- [ ] 回复早期评论
- [ ] 保持在线（算法看早期参与）

### Track Checklist
- [ ] 24h 快报：基础数据（阅读/点赞/评论）
- [ ] 7d 复盘：效果总结 + 学到了什么
- [ ] 更新 `data/calendar.md` 状态

### 不够好的信号
发完就忘了，不知道效果，不迭代
