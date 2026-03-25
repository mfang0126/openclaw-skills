# Upgrade Plan: audio-timestamp-verifier

## Pattern: Reviewer
## 理由: 该 skill 接受已有的时间戳+文本输入，重新转录并比对打分，核心功能是「检查/审核」现有数据的准确性。

## 缺少的文件
- [ ] _meta.json
- [ ] evals/evals.json
- [ ] SKILL.md Pattern 标注
（README.md 已存在 ✅）

## README 要点
（README.md 已存在，但可补充以下内容）
- 与完整转录流程的集成方式（作为后处理 reviewer 而非主流程）
- 批量验证的并发限制（最多 5 个并行 API 请求）
- LemonFox API key 安全处理建议（env var 而非硬编码）
- 典型误报场景：silence/crosstalk 导致低分但时间戳正确
- window 参数调优指南：短语越长 window 越大，默认 2.0s 适合大多数场景

## Evals 测试用例（草案）
- eval 1: 高匹配场景 — 提供正确时间戳和对应文本，期望 match_score ≥ 0.85，diagnosis = HIGH_MATCH
- eval 2: 低匹配/时间戳漂移 — 提供偏移 3 秒的错误时间戳，期望 match_score < 0.70，diagnosis = LOW_MATCH，suggestion 含搜索范围
- eval 3: 边界处理 — 时间戳在音频开头 1.5s（window=2.0），期望 segment_start = 0.0 而非负数，不报错
