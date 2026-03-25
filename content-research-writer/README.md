# content-research-writer

> Your collaborative writing partner — from outline to final draft with research, citations, and section-by-section feedback.

## Install

Already installed at `~/.openclaw/skills/content-research-writer/`. Requires web search access.

## Usage

Just describe what you want to write:

```
Help me write a blog post about AI's impact on product management
帮我写一篇关于持续探索的文章大纲
I just finished section 3, can you review it?
```

## How It Works

**Pattern: Pipeline** (Google ADK)

```
Start
  → Understand Writing Project (clarifying questions)
  → Collaborative Outlining (Hook / Body / Conclusion / Research To-Do)
  → Research & Citations (web search → credible sources → formatted refs)
  → Incremental Feedback (section-by-section: What Works / Suggestions / Edits)
  → Final Review (structure, quality, readability, pre-publish checklist)
  → Done
```

## Why Incremental Feedback?

Instead of reviewing the whole article at once, this skill reviews **each section as you write it**. This means:

- **Faster iteration**: You fix issues before they compound
- **Less overwhelm**: One section at a time, not a wall of notes
- **Momentum**: "Ready for the next section!" keeps you moving
- **Voice preservation**: Corrections stay fresh and contextual

## Voice Preservation Principle

This skill **enhances** your writing, never replaces it:
- Offers options, doesn't dictate
- Checks: "Does this sound like you?"
- Respects your choices when you prefer your version
- Learns your tone (formal/casual/technical) from examples you share

## Supported Output Formats

| Format | Example Prompts |
|--------|-----------------|
| Blog post | "帮我写一篇博客大纲" |
| Newsletter | "write a newsletter about X" |
| Thought leadership | "I want to establish authority on Y" |
| Technical documentation | "write a tutorial with code examples" |
| Case study | "help me document this customer story" |

## Quick Start

```
1. "帮我写一篇关于 [主题] 的文章大纲"
   → Skill asks: audience? tone? length?
   → Outputs structured outline with Research To-Do

2. "帮我找关于 [话题] 的最新数据"
   → Searches web → formats citations
   → Adds to outline

3. Write a section, then: "帮我看看这一节"
   → Feedback: What Works / Suggestions / Line Edits / Questions

4. "草稿完成了，帮我最终审查"
   → Full review + pre-publish checklist
```

## Design Decisions

- **No automatic publishing**: This skill stops at "publication-ready draft". Actual publishing belongs to platform-specific skills.
- **No CMS integration**: Direct CMS calls are out of scope — keeps the skill focused and platform-agnostic.
- **Text content only**: Best for articles, newsletters, docs. Not for slide decks or visual layouts.
- **Citation formats**: Supports inline, numbered, and footnote styles based on user preference.

## Limitations

- Does not automatically publish or post to CMS
- Does not generate images or visual content
- Markdown/code documentation is supported; complex code tutorials work better with the `development` skill
- Citations are sourced from web search — always verify before publishing

## Related Skills

- `development` — Technical documentation with code samples
- `html-screenshot` — Render final article as a visual image
- `deploy-artifact` — Publish the HTML version of your article
