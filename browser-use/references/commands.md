# browser-use Full Command Reference

## Navigation & Tabs
```bash
browser-use open <url>                    # Navigate to URL
browser-use back                          # Go back in history
browser-use scroll down                   # Scroll down
browser-use scroll up                     # Scroll up
browser-use scroll down --amount 1000     # Scroll by specific pixels (default: 500)
browser-use switch <tab>                  # Switch to tab by index
browser-use close-tab                     # Close current tab
browser-use close-tab <tab>              # Close specific tab
```

## Page State
```bash
browser-use state                         # Get URL, title, and clickable elements
browser-use screenshot                    # Take screenshot (outputs base64)
browser-use screenshot path.png           # Save screenshot to file
browser-use screenshot --full path.png    # Full page screenshot
```

## Interactions
```bash
browser-use click <index>                 # Click element
browser-use type "text"                   # Type text into focused element
browser-use input <index> "text"          # Click element, then type text
browser-use keys "Enter"                  # Send keyboard keys
browser-use keys "Control+a"              # Send key combination
browser-use select <index> "option"       # Select dropdown option
browser-use hover <index>                 # Hover over element (triggers CSS :hover)
browser-use dblclick <index>              # Double-click element
browser-use rightclick <index>            # Right-click element (context menu)
```

Use indices from `browser-use state`.

## JavaScript & Data
```bash
browser-use eval "document.title"         # Execute JavaScript, return result
browser-use get title                     # Get page title
browser-use get html                      # Get full page HTML
browser-use get html --selector "h1"      # Get HTML of specific element
browser-use get text <index>              # Get text content of element
browser-use get value <index>             # Get value of input/textarea
browser-use get attributes <index>        # Get all attributes of element
browser-use get bbox <index>              # Get bounding box (x, y, width, height)
```

## Cookies
```bash
browser-use cookies get                   # Get all cookies
browser-use cookies get --url <url>       # Get cookies for specific URL
browser-use cookies set <name> <value>    # Set a cookie
browser-use cookies set name val --domain .example.com --secure --http-only
browser-use cookies set name val --same-site Strict  # SameSite: Strict, Lax, or None
browser-use cookies set name val --expires 1735689600  # Expiration timestamp
browser-use cookies clear                 # Clear all cookies
browser-use cookies clear --url <url>     # Clear cookies for specific URL
browser-use cookies export <file>         # Export all cookies to JSON file
browser-use cookies export <file> --url <url>  # Export cookies for specific URL
browser-use cookies import <file>         # Import cookies from JSON file
```

## Wait Conditions
```bash
browser-use wait selector "h1"            # Wait for element to be visible
browser-use wait selector ".loading" --state hidden  # Wait for element to disappear
browser-use wait selector "#btn" --state attached    # Wait for element in DOM
browser-use wait text "Success"           # Wait for text to appear
browser-use wait selector "h1" --timeout 5000  # Custom timeout in ms
```

## Python Execution
```bash
browser-use python "x = 42"               # Set variable
browser-use python "print(x)"             # Access variable (outputs: 42)
browser-use python "print(browser.url)"   # Access browser object
browser-use python --vars                 # Show defined variables
browser-use python --reset                # Clear Python namespace
browser-use python --file script.py       # Execute Python file
```

The Python session maintains state across commands. The `browser` object provides:
- `browser.url`, `browser.title`, `browser.html` — page info
- `browser.goto(url)`, `browser.back()` — navigation
- `browser.click(index)`, `browser.type(text)`, `browser.input(index, text)`, `browser.keys(keys)` — interactions
- `browser.screenshot(path)`, `browser.scroll(direction, amount)` — visual
- `browser.wait(seconds)`, `browser.extract(query)` — utilities

## Agent Tasks (Remote Mode)

```bash
# Specify LLM model
browser-use -b remote run "task" --llm gpt-4o
browser-use -b remote run "task" --llm claude-sonnet-4-20250514

# Proxy configuration (default: us)
browser-use -b remote run "task" --proxy-country uk

# Session reuse
browser-use -b remote run "task 1" --keep-alive        # Keep session alive after task
browser-use -b remote run "task 2" --session-id abc-123 # Reuse existing session

# Execution modes
browser-use -b remote run "task" --flash       # Fast execution mode
browser-use -b remote run "task" --wait        # Wait for completion (default: async)

# Advanced options
browser-use -b remote run "task" --thinking    # Extended reasoning mode
browser-use -b remote run "task" --no-vision   # Disable vision (enabled by default)

# Task configuration
browser-use -b remote run "task" --start-url https://example.com
browser-use -b remote run "task" --allowed-domain example.com
browser-use -b remote run "task" --metadata key=value
browser-use -b remote run "task" --skill-id skill-123
browser-use -b remote run "task" --secret key=value

# Structured output and evaluation
browser-use -b remote run "task" --structured-output '{"type":"object"}'
browser-use -b remote run "task" --judge
browser-use -b remote run "task" --judge-ground-truth "expected answer"
```

## Task Management
```bash
browser-use task list                     # List recent tasks
browser-use task list --limit 20          # Show more tasks
browser-use task list --status finished   # Filter by status (finished, stopped)
browser-use task list --session <id>      # Filter by session ID
browser-use task list --json              # JSON output

browser-use task status <task-id>         # Get task status (latest step only)
browser-use task status <task-id> -c      # All steps with reasoning
browser-use task status <task-id> -v      # All steps with URLs + actions
browser-use task status <task-id> --last 5  # Last N steps only
browser-use task status <task-id> --step 3  # Specific step number
browser-use task status <task-id> --reverse # Newest first

browser-use task stop <task-id>           # Stop a running task
browser-use task logs <task-id>           # Get task execution logs
```

## Cloud Session Management
```bash
browser-use session list                  # List cloud sessions
browser-use session get <session-id>      # Get session details + live URL
browser-use session stop <session-id>     # Stop a session
browser-use session stop --all            # Stop all active sessions

browser-use session create                          # Create with defaults
browser-use session create --profile <id>           # With cloud profile
browser-use session create --proxy-country uk       # With geographic proxy
browser-use session create --start-url https://example.com
browser-use session create --screen-size 1920x1080
browser-use session create --keep-alive
browser-use session create --persist-memory

browser-use session share <session-id>              # Create public share URL
browser-use session share <session-id> --delete     # Delete public share
```

## Tunnels
```bash
browser-use tunnel <port>           # Start tunnel (returns URL)
browser-use tunnel list             # Show active tunnels
browser-use tunnel stop <port>      # Stop tunnel
browser-use tunnel stop --all       # Stop all tunnels
```

## Profile Management

### Local Chrome Profiles (`--browser real`)
```bash
browser-use -b real profile list          # List local Chrome profiles
browser-use -b real profile cookies "Default"  # Show cookie domains in profile
```

### Cloud Profiles (`--browser remote`)
```bash
browser-use -b remote profile list            # List cloud profiles
browser-use -b remote profile get <id>        # Get profile details
browser-use -b remote profile create --name "My Profile"
browser-use -b remote profile update <id> --name "New"
browser-use -b remote profile delete <id>
```

### Syncing
```bash
browser-use profile sync --from "Default" --domain github.com  # Domain-specific
browser-use profile sync --from "Default"                      # Full profile
browser-use profile sync --from "Default" --name "Custom Name" # With custom name
```

## Server Control
```bash
browser-use server logs                   # View server logs
```
