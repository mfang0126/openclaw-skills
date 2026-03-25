# Upgrade Plan: douyin-dl

## Pattern: Tool Wrapper
## 理由: 包装 TikHub API + 本地下载脚本，检测抖音链接/ID 后按需调用

## 缺少的文件
- [ ] README.md
- [ ] _meta.json
- [ ] evals/evals.json
- [ ] SKILL.md Pattern 标注（当前无 "Pattern: Tool Wrapper" 标签）
- [ ] SKILL.md 缺少 `Prerequisites` section（需要 TikHub token）
- [ ] SKILL.md 缺少 `Error Handling` table（token 无效、链接失效、API 限速等场景）
- [ ] SKILL.md 缺少 `Quick Start` section（最常见的一行命令）

## README 要点
- 工作原理：短链解析 → TikHub API 获取真实视频 URL → wget/curl 下载到本地
- 设计决策：为什么选 TikHub 而非 Playwright 爬取（稳定、无需登录、速度快）
- TikHub 免费 token 申请方式及配额限制
- 支持的输入格式（短链/完整链接/modal_id）对照表
- 局限性：不支持直播流、图集（图文帖），不支持私密视频

## Evals 测试用例（草案）
- eval 1: 用户发送 `https://v.douyin.com/iABCxyz/`（短链）→ 应解析出 modal_id 并返回视频直链或下载到 ~/Downloads/douyin/
- eval 2: 用户发送 bare modal_id `7615599455526585067` → 应识别为视频 ID 并直接调用脚本下载
- eval 3: TikHub token 未配置（config.json 缺少 tikhub_api_token）→ 应明确提示"需要配置 TikHub token"，并附上申请链接，不应抛出原始 Python 错误
