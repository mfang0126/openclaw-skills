---
name: content-research-writer
description: |
  Assists in writing high-quality content by conducting research, adding citations, improving hooks,
  iterating on outlines, and providing real-time feedback on each section. Transforms your writing
  process from solo effort to collaborative partnership.

  USE FOR:
  - "帮我写一篇文章大纲", "help me outline", "write a blog post about"
  - "改进我的 hook", "improve my introduction", "make this more engaging"
  - "帮我看看这一节", "review this section", "give me feedback on"
  - "帮我找资料", "research this topic", "add citations"
  - "写 newsletter", "thought leadership article", "technical tutorial"
  - Collaborative writing: blog, newsletter, case study, documentation

  REQUIRES: web_search access (for research and citations)
metadata:
  openclaw:
    emoji: "✍️"
    requires:
      bins: []
---

# Content Research Writer

**Pattern: Pipeline** (Google ADK) — 理解项目 → 协作大纲 → 调研引用 → 逐段反馈 → 终稿审查

This skill acts as your writing partner, helping you research, outline, draft, and refine content while maintaining your unique voice and style.

## When to Use This Skill

- Writing blog posts, articles, or newsletters
- Creating educational content or tutorials
- Drafting thought leadership pieces
- Researching and writing case studies
- Producing technical documentation with sources
- Writing with proper citations and references
- Improving hooks and introductions
- Getting section-by-section feedback while writing

**Don't use when:** The user just needs a quick answer or factual lookup (use web search), or wants to write code (use development skill).

## What This Skill Does

1. **Collaborative Outlining**: Helps you structure ideas into coherent outlines
2. **Research Assistance**: Finds relevant information and adds citations
3. **Hook Improvement**: Strengthens your opening to capture attention
4. **Section Feedback**: Reviews each section as you write
5. **Voice Preservation**: Maintains your writing style and tone
6. **Citation Management**: Adds and formats references properly
7. **Iterative Refinement**: Helps you improve through multiple drafts

## How to Use

### Setup Your Writing Environment

Create a dedicated folder for your article:
```
mkdir ~/writing/my-article-title
cd ~/writing/my-article-title
```

Create your draft file:
```
touch article-draft.md
```

Open Claude Code from this directory and start writing.

### Basic Workflow

1. **Start with an outline**:
```
Help me create an outline for an article about [topic]
```

2. **Research and add citations**:
```
Research [specific topic] and add citations to my outline
```

3. **Improve the hook**:
```
Here's my introduction. Help me make the hook more compelling.
```

4. **Get section feedback**:
```
I just finished the "Why This Matters" section. Review it and give feedback.
```

5. **Refine and polish**:
```
Review the full draft for flow, clarity, and consistency.
```


## Instructions Summary

Follow this 8-step process for every writing session:

1. **Understand** — Ask: topic, audience, length, goal, style, existing sources
2. **Outline** — Collaborate on structure; identify research gaps; iterate until approved
3. **Research** — Search for facts, quotes, data; add properly-formatted citations
4. **Improve Hooks** — Analyze current hook; offer 3 alternatives (data/question/story)
5. **Section Feedback** — Review each section: strengths, clarity, flow, evidence, style
6. **Preserve Voice** — Learn from samples; suggest don't replace; ask "Does this sound like you?"
7. **Manage Citations** — Support inline, numbered, or footnote format; maintain running reference list
8. **Final Review** — Full draft assessment: structure, content quality, technical quality, readability

> Full step-by-step details → `references/detailed-instructions.md`

## Examples

### Example 1: Blog Outline from Scratch

**User says:** "帮我写一篇关于 AI agent 的博客大纲"
**Steps:**
1. 确认主题范围（面向开发者 or 非技术读者？目标长度？）
2. 使用 `web_search` 研究 AI agent 的最新进展、关键概念、典型案例
3. 整理结构：引言 → 核心概念 → 应用场景 → 挑战与展望 → 结论
4. 为每个 section 标注需要补充引用的研究点
**Output:** 完整 markdown 大纲，含各节标题、要点和引用占位符
**Reply:** "这是一份面向技术读者的 AI agent 博客大纲，共 5 节。已标注需要引用的关键数据点，你可以从第一节开始写，写完每节我来帮你审阅。"

### Example 2: Teresa Torres's Workflow

**User**: "I'm writing an article about continuous discovery. Help me create an outline."

**Process**:
1. Collaborates on outline structure
2. Identifies research needs
3. User starts writing introduction
4. Reviews and improves the hook
5. User writes each section
6. Provides feedback after each section
7. Conducts research and adds citations
8. Final review of complete draft
9. Polish and prep for publishing

**Result**: Well-researched, properly cited article written in Teresa's voice with strong structure and flow.

### Example 2: Research-Heavy Article

**User**: "I'm writing about AI's impact on product management. Help me find current data and examples."

**Output**:
```markdown
## Research Compiled

### Recent Data
- Gartner: 80% of PMs will use AI tools by 2025 [1]
- Survey: 45% report faster feature shipping [2]
- Case study: Airbnb's AI-assisted prioritization [3]

### Expert Quotes
- "AI amplifies PM judgment, not replaces it" - Marty Cagan
- [Additional quotes with citations]

### Real Examples
1. **Company A**: Used AI for user research synthesis
   - Result: 60% time savings
   - Source: [citation]

2. **Company B**: AI-powered roadmap analysis
   - Result: Better stakeholder alignment
   - Source: [citation]

All added to your outline with proper citations.
```

### Example 3: Hook Improvement

**User's Original Hook**:
> "Product management is changing because of AI. In this article, I'll discuss some ways AI affects product managers."

**Improved Options**:

**Option 1 (Data-driven)**:
> "Last month, I asked AI to analyze 500 customer interviews. It took 30 minutes instead of 3 weeks. Product management will never be the same."

**Option 2 (Question)**:
> "What if you could talk to every customer, read every review, and analyze every support ticket—all before your morning coffee?"

**Option 3 (Story)**:
> "Sarah spent two weeks building the wrong feature. Not because she didn't understand her users, but because she couldn't process the hundreds of interviews fast enough to spot the pattern."

### Example 4: Section Feedback

**User**: "Just finished my 'Common Mistakes' section. Thoughts?"

**Response**:
```markdown
# Feedback: Common Mistakes Section

## What Works Well ✓
- Strong examples (the Slack notification story)
- Clear structure (3 mistakes, clean layout)
- Practical advice for each mistake

## Suggestions

### Make It More Specific
Your second point says "Bad prioritization" but could be stronger:

Current:
> "Many teams prioritize badly by focusing on features instead of outcomes."

Suggested:
> "I've watched teams ship 14 features in a quarter yet move none of their key metrics. They prioritized activity over progress."

### Add Data
The third mistake would benefit from evidence:
> "[Add citation]: Studies show teams without regular user contact are 3x more likely to build unused features [needs source]"

### Flow Improvement
Consider reordering: Mistake 3 → Mistake 2 → Mistake 1
This builds from small to big impact.

Ready for the next section!
```



## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| `web_search` returns no results | Topic too niche or query too broad | Rephrase query; try different keywords or subtopics |
| Citation source is paywalled | Academic journal or premium content | Note as "[paywalled source]"; suggest open-access alternative |
| Outline scope creep | User keeps adding sections | Set scope: "Let's cap this at 5 sections for readability" |
| Voice mismatch in suggestions | Claude defaulting to formal tone | Ask user to share an existing writing sample to calibrate |
| Research returns outdated data | Web results are stale | Filter search by date; note year in citation; flag if pre-2022 |

## References

- `references/detailed-instructions.md` — Full 8-step instruction details with templates
- `references/workflows-and-tips.md` — Blog, Newsletter, Tutorial workflows; Pro Tips; File Organization; Best Practices
