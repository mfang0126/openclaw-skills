---
name: email-classifier
description: "Daily email classifier. Categorizes inbox into 4 types (act/read/track/trash), sends summary for confirmation, learns from corrections. Use when user says 'check email', 'daily email', '查邮件', '看邮件'."
user-invocable: true
---

# Email Classifier

## 触发

- Cron 每日 9:00
- 用户说 "查邮件"、"看邮件"、"email"、"check email"、"daily email"

## 账户

支持多账户：
- **Gmail**: `himalaya envelope list` (默认)
- **Zoho**: `himalaya envelope list -a Zoho`

## 步骤

1. **拉新邮件**:
   ```bash
   himalaya envelope list          # Gmail
   himalaya envelope list -a Zoho  # Zoho
   ```
2. **逐封分类**:
   - 查发件人记忆 (`memory/{account}.json`)
   - 记忆中有且非混合型 → 直接用记忆分类
   - 记忆中无或混合型 → 读 subject 判断，不确定再读正文
3. **发摘要**（按账户分组，格式见下方）
4. **等用户确认/纠正**
5. **执行动作 + 更新记忆**

## 分类标准

| 类别 | 含义 | 判断依据 |
|------|------|---------|
| 🔔办 (act) | 需要我做什么 | 验证码、安全提醒、催款、登录通知、部署失败、需要回复的邮件 |
| 📬读 (read) | 值得看一眼 | Newsletter、楼管通知、个人邮件、工作沟通 |
| 💰记 (track) | 钱相关的记录 | 收据、账单、发票、支付确认、运单送达、订单确认 |
| 🗑️扔 (trash) | 不用看 | 促销广告、条款更新、营销、系统报告、已取消事件 |

### 关键原则

- **宁🔔勿🗑️** — 不确定是办还是扔，选办（漏提醒比多提醒严重）
- **用"没看过"的视角分类** — 假设用户从未看过这封邮件：
  - 安全相关（PIN变更、生物识别、密码重置）→ 先🔔，不管是通知还是确认
  - 服务开通/注册确认 → 先💰（可能是消费记录），不是🗑️
  - 航班/行程相关 → 先📬或🔔，不是🗑️（用户可能需要这个信息）
  - 只有**明确是广告/营销**的才🗑️（促销折扣、抽奖、"推荐给朋友"）
  - 判断标准：如果用户没看就删了，**会不会漏掉什么？** 会 → 不删
- **送达=💰，未送达=🔔** — 包裹已送达/已取件是记录，包裹待取/派送失败需操作
- **确认=💰，待确认=🔔** — 注册完成/密码已改是记录，请验证/请确认需操作
- **催款=🔔** — 任何逾期、欠款、催付都是办
- **同一发件人可能发不同类型** — Grab 发收据(💰)也发促销(🗑️)也发验证码(🔔)，看内容不看发件人

## 发件人记忆

文件: `memory/{account}.json`
- Gmail: `memory/default.json`
- Zoho: `memory/zoho.json`

结构:
```json
{
  "senders": {
    "sender@example.com": {
      "category": "track",
      "confidence": 0.95,
      "count": 10,
      "mixed": false,
      "breakdown": {"track": 10}
    }
  }
}
```

**查记忆流程**:
- `mixed: false` + `count >= 3` → 高信心，直接用
- `mixed: false` + `count < 3` → 参考但也看 subject
- `mixed: true` 或 `category: "mixed"` → 必须看 subject/正文
- 不在记忆中 → 新发件人，读 subject 判断

## 摘要格式

```
📊 今日邮件 (Gmail N封 + Zoho M封)

📧 Gmail:
🔔办 (n):
  • 主题1
  • 主题2
📬读 (n):
  • 主题1
💰记 (n):
  • 主题1
🗑️扔 (n):
  • 主题1

📧 Zoho:
🔔办 (n):
  • 主题1
🗑️扔 (n):
  • 主题1

确认删🗑️？回复「删」「删 Gmail」「删 Zoho」
纠正？回复「X 不该删」或「X 应该是🔔」
```

## 纠正处理

用户回复纠正时:
1. 解析纠正内容（哪封邮件、正确类别）
2. 直接读取对应账户的 `memory/{account}.json`
3. 更新该发件人的 breakdown 计数
4. 重新计算 category 和 confidence
5. 写回文件
6. 确认："已更新，下次 [发件人] 会分到 [类别]"

不依赖外部脚本，agent 直接操作 JSON。

## 动作

| 类别 | 自动动作 |
|------|---------|
| 🔔办 | 在摘要中高亮，验证码类立即发送 |
| 📬读 | 列在摘要中 |
| 💰记 | 列在摘要中 |
| 🗑️扔 | 列出等确认，用户说「删」后批量删除 |

**🗑️永远不自动删除，必须等用户确认。**

## himalaya 命令参考

```bash
# 列出邮件
himalaya envelope list           # Gmail (默认)
himalaya envelope list -a Zoho   # Zoho

# 读邮件正文
himalaya message read <id>
himalaya message read -a Zoho <id>

# 移动邮件到 Trash（不要用 message delete，会跳过回收站）
himalaya message move <id> "[Gmail]/Trash"          # Gmail
himalaya message move -a Zoho <id> "Trash"          # Zoho
```
