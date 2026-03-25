# agent-browser

> Zero-token browser automation CLI for AI agents. Navigate, interact, capture — all without consuming image tokens.

**Pattern: Tool Wrapper** (Google ADK)

## Install

`agent-browser` must be in PATH. Verify with:
```bash
agent-browser --version
```

## How It Works

`agent-browser` wraps Playwright with a CLI designed for AI agents. The key insight: **snapshot -i returns a text DOM with numbered refs** (`@e1`, `@e2`, …), letting the agent interact with pages without ever taking (or consuming) a screenshot.

```
User request
  → agent-browser open <url>
  → agent-browser snapshot -i          ← text DOM with @refs (zero tokens)
  → agent-browser fill/click/select @ref
  → [DOM changes?] re-snapshot
  → agent-browser screenshot out.png   ← saved to file, not injected into context
```

## Core Workflow

```bash
agent-browser open https://example.com/form
agent-browser snapshot -i
# → @e1 [input] "Email", @e2 [input] "Password", @e3 [button] "Sign In"

agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "secret"
agent-browser click @e3
agent-browser wait --load networkidle
agent-browser snapshot -i   # always re-snapshot after navigation
```

## Design Decisions

- **Text refs over screenshots**: `snapshot -i` returns `@e1`…`@eN` element references — no image tokens consumed
- **File-based screenshots**: `screenshot out.png` saves to disk; the agent sends the file via `message send media=` if the user needs to see it
- **Persistent sessions**: Browser stays open between commands; use `--session NAME` for parallel browsers
- **State save/load**: `state save auth.json` / `state load auth.json` for login persistence across runs
- **iOS via Appium**: `-p ios` delegates to Appium + XCUITest — unique capability not in other tools

## Exclusive Capabilities

| Feature | agent-browser | browser-use | browser (built-in) |
|---------|:---:|:---:|:---:|
| Video recording | ✅ | ❌ | ❌ |
| iOS simulator | ✅ | ❌ | ❌ |
| Geo location mock | ✅ | ❌ | ❌ |
| Trace recording | ✅ | ❌ | ❌ |
| AI autonomous mode | ❌ | ✅ | ❌ |
| Cloud remote browser | ❌ | ✅ | ❌ |
| OpenClaw cookie profile | ❌ | ❌ | ✅ |

## Ref Lifecycle

Refs (`@e1`, `@e2`, …) are **invalidated on any DOM/navigation change**. Always re-snapshot after:
- Clicking a link or button that navigates
- Form submission
- Dynamic content loading (dropdowns, modals)

## Limitations

- No AI autonomous mode — for "do this complex task by yourself" use `browser-use run "task"`
- No cloud/remote browser — sessions run on the local machine
- No proxy country switching — use `browser-use --proxy-country` for that
- iOS requires macOS + Xcode + Appium (`npm install -g appium && appium driver install xcuitest`)
- Refs expire on DOM change; failing to re-snapshot is the most common error

## Related Skills

- `browser-routing` — Decide which browser tool to use before starting any web task
- `browser-use` — AI autonomous agent mode + cloud remote browser
- `html2img` — Convert HTML/Markdown to PNG without a live browser session
