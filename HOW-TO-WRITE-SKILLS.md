# How to Write OpenClaw Skills

> Production-quality skill authoring guide.
> Based on Anthropic/Google/OpenAI/Meta official docs + Google ADK 5 Patterns + production lessons.
> Last updated: 2026-04-02

---

## The Core Principle

**A skill is not a prompt. It's a structured knowledge injection system.**

The goal isn't to write clever instructions — it's to define:
1. When to load this knowledge (trigger conditions)
2. What knowledge to load (content)
3. How to use it (execution flow)
4. How to maintain it (versioning)

---

## File Structure

```
your-skill-name/              # kebab-case, lowercase, no spaces
├── SKILL.md                  # ★ Only required file
├── scripts/                  # Optional: executable scripts
│   ├── main.py
│   └── validate.sh
├── references/               # Optional: loaded on demand
│   ├── api-guide.md
│   └── examples/
├── assets/                   # Optional: templates, images
└── (other folders)           # Organize as needed, reference in SKILL.md
```

**Rules:**
- Only SKILL.md is required, everything else is optional
- Folder name must be kebab-case (lowercase + hyphens only)
- Keep SKILL.md lean — put detailed docs in `references/`

---

## SKILL.md Structure

```markdown
---
name: your-skill-name
description: |
  [trigger conditions + what it does]
version: 1.0.0
license: MIT
user-invocable: true
compatibility:
  - python>=3.10
  - network-access: true
allowed-tools:
  - read-file
  - write-file
metadata:
  author: Your Name
  category: productivity
  tags: [research, automation]
---

# Skill Name

## Instructions
[core execution steps]

## Examples
[input → output pairs]

## Output Format
[exact structure of output]

## Troubleshooting
[common failures + fixes]

## References
[pointers to references/ files]
```

---

## YAML Frontmatter — Field by Field

### `name` (required)

**What**: Skill identifier. Must match folder name.

**Rules:**
- kebab-case only (lowercase + hyphens)
- Max 64 characters
- No `anthropic`, `claude`, or XML tags

**Good vs Bad:**
| ❌ Bad | ✅ Good | Why |
|--------|---------|-----|
| `ResearchPro` | `research-pro` | Must be kebab-case |
| `my_awesome_skill` | `my-awesome-skill` | No underscores |
| `claude-helper` | `research-helper` | No reserved names |

---

### `description` (required) — THE MOST IMPORTANT FIELD

**What**: Determines when the skill gets loaded. This is the trigger.

**Rules:**
- Must contain BOTH "what it does" AND "when to use it"
- Include trigger keywords in user's language (中文 + English)
- Include "does NOT trigger" cases to prevent false matches
- Max 1024 characters
- No XML tags

**How to judge if it's good:**

| Criteria | ❌ Fails | ✅ Passes |
|----------|---------|----------|
| Trigger clarity | `Helps with research` | `Triggers on: "帮我研究", "search for", "look up", competitive analysis` |
| Negative boundary | (not mentioned) | `Does NOT trigger: simple facts you already know, user gave a specific URL` |
| Specificity | `Handles various tasks` | `Executes 4-mode research pipeline (Quick/Standard/Deep/Crawl)` |
| Output hint | (missing) | `Outputs structured report with sources, key findings, and recommendations` |

**Template:**
```yaml
description: |
  [One sentence: what it does]
  
  Triggers: [keyword1], [keyword2], [keyword3], [scenario1], [scenario2]
  
  Does NOT trigger:
  - [case that looks similar but shouldn't match]
  - [case handled by another skill]
  
  Output: [what the user gets back]
```

**Conflict check:** Before finalizing, run `openclaw skills list` and compare trigger words with existing skills.

---

### `version` (optional, recommended)

**What**: Semantic version for tracking changes.

**Rules:**
- Use semver: `MAJOR.MINOR.PATCH`
- Bump MAJOR for breaking changes to output format
- Bump MINOR for new features
- Bump PATCH for fixes

**How to judge:** Does the version reflect actual changes? If the skill has been modified 10 times but version is still `1.0.0`, it's wrong.

---

### `user-invocable` (optional)

**What**: Can users trigger this skill directly?

**Rules:**
- `true` → Entry point skills (user says "run X on Y")
- Omit or `false` → Internal skills called by other skills/agents

**How to judge:**

| Skill type | Setting | Why |
|-----------|---------|-----|
| `research-pro` | `true` | User says "研究一下X" |
| `grok-search` | omit | Only called by research-pro internally |
| `soul-keeper` | `true` | User says "检查 workspace" |
| `calculator` | `true` | User says "算一下" |

**Rule of thumb:** If only other skills call it, omit. If a user would ever say "use X skill", set `true`.

---

### `license` (optional)

**What**: Open source license.

**When to use:** When publishing to GitHub or skill marketplace.
**Common choices:** `MIT`, `Apache-2.0`, `ISC`

---

### `compatibility` (optional)

**What**: Environment requirements.

**Rules:**
- List runtime dependencies (python, node, specific CLI tools)
- Note network access needs
- Note OS requirements if any

**Good example:**
```yaml
compatibility:
  - python>=3.11
  - ffmpeg
  - network-access: true
  - macos  # uses pbcopy
```

**How to judge:** Can someone on a fresh machine know exactly what to install before using this skill?

---

### `allowed-tools` (optional)

**What**: Restrict which tools this skill can use.

**When to use:** Security-sensitive skills, or to prevent hallucinated tool calls.

```yaml
allowed-tools:
  - read-file
  - write-file
  - web_search
```

**How to judge:** If the skill calls a tool not in this list, something's wrong.

---

### `metadata` (optional)

**What**: Any custom key-value pairs.

```yaml
metadata:
  author: Ming
  category: research
  tags: [ai, automation, multi-agent]
  mcp-server: your-mcp
  platform: [claude-code, gemini-cli, openai]
```

**How to judge:** Is there enough info for someone browsing a skill marketplace to understand what this is?

---

## Markdown Body — Section by Section

### `## Instructions` (required)

**What**: The core execution logic.

**Rules:**
- Numbered steps, not paragraphs
- Each step = one action
- Include gates (checkpoints) for multi-step skills
- Keep it under 50 lines — put details in `references/`

**Good vs Bad:**

❌ Bad:
```markdown
## Instructions
This skill helps you research topics. First, figure out what the user wants,
then search for it using various tools, and compile the results into a report.
```

✅ Good:
```markdown
## Instructions
1. Classify the request → Quick (1 search) / Standard (3-5) / Deep (10+)
2. ⛔ Gate: Confirm classification with user if ambiguous
3. Execute searches using tools in priority order:
   - Tavily (general) → Grok (X/Twitter) → Reddit → YouTube
4. Compile findings into structured report (see Output Format)
5. Include source URLs for every claim
```

**How to judge:**
- Can you follow the steps without guessing?
- Are there decision points with clear criteria?
- Is each step atomic (one action, not three)?

---

### `## Examples` (strongly recommended)

**What**: Concrete input → output pairs.

**Rules:**
- At least 2 success cases
- At least 1 edge case or failure case
- Show the EXACT format of input and output
- Use realistic scenarios, not toy examples

**Template:**
```markdown
## Examples

### Success Case 1
**Input**: 用户说 "帮我研究一下 MLX 在 M4 上的性能"
**Output**:
[actual output snippet, 5-10 lines]

### Edge Case
**Input**: 用户说 "search" (no topic specified)
**Action**: Ask for clarification, do NOT start searching
```

**How to judge:**
- Would a new user understand what this skill does just from the examples?
- Are edge cases covered?
- Is the output format clear from the examples?

---

### `## Output Format` (strongly recommended)

**What**: Exact structure of what the skill produces.

**Rules:**
- Use JSON Schema, Markdown template, or exact format specification
- Be specific about required fields vs optional
- Show a complete example

**Template:**
```markdown
## Output Format

```json
{
  "status": "success | error",
  "summary": "1-2 sentence summary",
  "findings": [
    {
      "claim": "string",
      "source": "URL",
      "confidence": "high | medium | low"
    }
  ],
  "recommendations": ["string"]
}
```
```

**How to judge:**
- Can you validate the output programmatically?
- Are all possible values of each field documented?
- Is there a complete example?

---

### `## Troubleshooting` (strongly recommended)

**What**: Common failures and how to fix them.

**Rules:**
- List the top 3-5 most likely failures
- Include the error message or symptom
- Include the fix

**Template:**
```markdown
## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| "API rate limited" | Too many searches in 60s | Wait 60s, or switch to fallback tool |
| Empty results | Query too specific | Broaden search terms, try synonyms |
| Timeout after 30s | Network issue | Retry once, then report failure |
```

**How to judge:** Would someone hitting this error know what to do without asking for help?

---

### `## References` (optional)

**What**: Pointers to detailed docs in `references/`.

**Rules:**
- Don't put reference content inline — point to files
- Explain WHEN to read each reference

```markdown
## References
- API syntax details → `{skillDir}/references/api-guide.md` (read before first API call)
- Example outputs → `{skillDir}/references/examples/` (read when unsure about format)
```

---

## Step 1: Pick a Pattern

Before writing anything, identify which pattern fits.

```
What does this skill need to do?
    │
    ├── Load domain knowledge on demand?
    │   → Tool Wrapper
    │
    ├── Produce consistent structured output?
    │   → Generator
    │
    ├── Evaluate existing work against criteria?
    │   → Reviewer
    │
    ├── Gather information before starting?
    │   → Inversion
    │
    └── Execute a strict multi-step process?
        → Pipeline
```

**Patterns can combine.** research-pro = Pipeline + Tool Wrapper.

| Pattern | Problem it solves | Key mechanism |
|---------|------------------|---------------|
| **Tool Wrapper** | Context bloat from always-loaded knowledge | Load only when task matches |
| **Generator** | Inconsistent output structure | Fixed template + style guide |
| **Reviewer** | Mixing "what to check" with "how to check" | Separate checklist from execution |
| **Inversion** | Agent guesses instead of asking | Gate: no output until info is complete |
| **Pipeline** | Steps get skipped in complex tasks | Explicit stages with gates |

---

## Step 2: Write and Test

### Quality Checklist

**Design**
- [ ] Pattern identified and noted in SKILL.md
- [ ] Description has trigger keywords + negative boundaries
- [ ] `user-invocable` set correctly
- [ ] No trigger conflicts with existing skills

**Content**
- [ ] Instructions are numbered steps, not paragraphs
- [ ] At least 2 examples + 1 edge case
- [ ] Output format explicitly defined
- [ ] Troubleshooting covers top 3 failures
- [ ] Reference docs in `references/`, not inline

**Portability (Generic Skill Test)**

Answer NO to ALL before publishing:
- [ ] References files outside `{skillDir}` or standard workspace paths?
- [ ] Hardcoded skill names, versions, usernames, or paths?
- [ ] Assumes tools without checking availability?
- [ ] Uses absolute paths instead of `{skillDir}` or `$HOME`?
- [ ] Fails on first run due to missing dirs/files?
- [ ] Enumerates items instead of discovering dynamically?

**Maintenance**
- [ ] Version reflects actual state
- [ ] Has git remote if GitHub-sourced
- [ ] At least 3 trigger test prompts + 1 "should NOT trigger" case

---

## Cross-Platform Compatibility

| Platform | SKILL.md Support | Notes |
|----------|-----------------|-------|
| **Anthropic (Claude Code)** | ✅ Native, standard author | Strictest validation, Progressive Disclosure |
| **Google (ADK / Gemini CLI)** | ✅ Full compat | Extra `resources` field, supports `load_skill_from_dir` |
| **OpenAI (Skills)** | ✅ High compat | Upload packaged instructions + scripts + assets |
| **Meta (Llama Tool Calling)** | ⚠️ Manual | Copy description as tool description, works directly |

**Portable skill = works on all 4 with zero changes.**

---

## Complete Template (Copy and Use)

```markdown
---
name: my-skill-name
description: |
  One sentence: what it does.
  
  Triggers: "keyword1", "keyword2", scenario description
  
  Does NOT trigger:
  - case handled elsewhere
  - ambiguous case that looks similar
  
  Output: what the user gets back
version: 1.0.0
user-invocable: true
metadata:
  author: Your Name
  category: productivity
---

# My Skill Name

## Instructions
1. Step one
2. ⛔ Gate: verify X before continuing
3. Step two
4. Step three → produce output

## Examples

### Success
**Input**: "帮我做 X"
**Output**: [exact output]

### Edge Case
**Input**: "做 X"（missing context）
**Action**: Ask for clarification

## Output Format
\```json
{
  "status": "success",
  "result": "...",
  "sources": ["url1", "url2"]
}
\```

## Troubleshooting
| Symptom | Fix |
|---------|-----|
| Empty result | Broaden query |
| Timeout | Retry once |

## References
- Detailed API docs → `{skillDir}/references/api-guide.md`
```

---

## References

- [Anthropic SKILL.md Spec](https://docs.anthropic.com) — standard author
- [Google ADK Skill Patterns](https://google.github.io/adk-docs/) — 5 pattern framework
- [OpenAI Skills & Function Calling](https://platform.openai.com/docs) — description best practices
- [agentskills.io](https://agentskills.io) — open standard
- [Generic Skills Research](workspace/research/2026-03-22-generic-skills-guide.md) — portability patterns
