# Claude Code Statusline

A custom statusline for [Claude Code](https://claude.ai/claude-code) that shows:

- Current directory and git branch (Powerline-styled, matches your shell theme)
- Model name
- Context window usage bar
- Session cost
- 5-hour session usage bar + time until reset
- 7-day weekly usage bar + time until reset

Usage and reset times are fetched live from the Anthropic OAuth API — same data shown on your claude.ai dashboard.

Preview:
```
 ~/dev/my-project  on   main ✅   │  sonnet-4-6  │  context: ████░░░░░░ 38%  │  $0.0312  │  session (2h14m): ███░░░░░░░ 28%,  weekly (4d08h): █░░░░░░░░░ 10%
```

---

## Requirements

| Tool      | Purpose                          |
|-----------|----------------------------------|
| `claude`  | Claude Code CLI                  |
| `jq`      | JSON parsing                     |
| `curl`    | Anthropic API requests           |
| `git`     | Branch/status detection          |
| `bash`    | Shell (v4+)                      |
| Nerdfont  | Icons (e.g. JetBrainsMono Nerd Font) |

---

## Installation

### 1. Copy the script

```bash
mkdir -p ~/.claude/scripts
cp claude/scripts/statusline.sh ~/.claude/scripts/
chmod +x ~/.claude/scripts/statusline.sh
```

### 2. Register it in Claude Code settings

Add the following to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/scripts/statusline.sh"
  }
}
```

If `settings.json` already has other keys, just add the `statusLine` block alongside them.

### 3. Restart Claude Code

The statusline appears at the bottom of the Claude Code interface after restart.

---

## OS-specific changes

The script works out of the box on **macOS**. On **Linux** and **Windows**, specific lines need to be changed — see each section below.

### Windows

There are two ways to run the script on Windows:

**Option A — WSL (recommended):** Use the Linux instructions below as-is. WSL provides a full Linux environment; no further changes needed.

**Option B — Git Bash:** Git Bash ships with GNU coreutils, so `stat` and `date` behave the same as Linux. Apply the same Linux changes for all three functions. The only difference is the credentials path — see Change 2 below.

> Git Bash requires bash 4+. The default bash shipped with Git for Windows is usually sufficient.
> Check with `bash --version`.

For the Claude Code settings file on Windows, the path is:
```
C:\Users\<you>\.claude\settings.json
```
In Git Bash this is `~/.claude/settings.json` — same as macOS/Linux.

---

### Change 1 — `get_file_age()` — file modification time

**macOS (default, BSD stat):**
```bash
get_file_age() {
    local mod
    mod=$(stat -f '%m' "$1" 2>/dev/null) || { echo 9999; return; }
    echo $(( $(date +%s) - mod ))
}
```

**Linux / Windows Git Bash (GNU stat):**
```bash
get_file_age() {
    local mod
    mod=$(stat -c '%Y' "$1" 2>/dev/null) || { echo 9999; return; }
    echo $(( $(date +%s) - mod ))
}
```

---

### Change 2 — `fetch_usage()` — reading the OAuth token

Claude Code stores credentials differently per OS.

**macOS (default, Keychain):**
```bash
local keychain
keychain=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
[ -z "$keychain" ] && { [ -f "$API_CACHE" ] && cat "$API_CACHE"; return; }
local token
token=$(echo "$keychain" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
```

**Linux / WSL / Windows Git Bash (credentials file):**
```bash
local creds_file="$HOME/.claude/.credentials.json"
local token
token=$(jq -r '.claudeAiOauth.accessToken // empty' "$creds_file" 2>/dev/null)
```

> The credentials file path may vary depending on your Claude Code version.
> Check `~/.claude/` for a file named `.credentials.json` or `credentials.json`.
>
> On Windows (Git Bash), `$HOME` resolves to `C:\Users\<you>`, so the full path would be
> `C:\Users\<you>\.claude\.credentials.json`.

---

### Change 3 — `iso_secs_left()` — parsing ISO 8601 timestamps

**macOS (default, BSD date):**
```bash
iso_secs_left() {
    local iso="$1"
    local clean; clean=$(echo "$iso" | sed 's/\.[0-9]*//; s/+00:00//; s/Z$//')
    local reset_ts; reset_ts=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "$clean" "+%s" 2>/dev/null)
    [ -n "$reset_ts" ] && echo $(( reset_ts - $(date +%s) )) || echo ""
}
```

**Linux / WSL / Windows Git Bash (GNU date):**
```bash
iso_secs_left() {
    local iso="$1"
    local clean; clean=$(echo "$iso" | sed 's/\.[0-9]*//; s/+00:00//; s/Z$//')
    local reset_ts; reset_ts=$(date -u -d "$clean" +%s 2>/dev/null)
    [ -n "$reset_ts" ] && echo $(( reset_ts - $(date +%s) )) || echo ""
}
```

---

## Customisation

### Powerline segment colors

The directory and git segments use **indexed ANSI terminal colors** (not hardcoded RGB), so they automatically match your terminal's color scheme.

The indices mirror Powerlevel10k defaults:

| Variable       | Index | Meaning                        |
|----------------|-------|--------------------------------|
| `BG_PATH`      | 4     | Terminal blue (directory bg)   |
| `BG_VCS_CLEAN` | 2     | Terminal green (clean repo)    |
| `BG_VCS_MOD`   | 3     | Terminal yellow (dirty repo)   |
| `FG_SEG`       | 254   | Light gray text on segments    |

To change colors, update the index numbers in the `BG_PATH`, `BG_VCS_CLEAN`, `BG_VCS_MOD` variables — and update the matching separator lines (`PL_*`) to use the same indices.

### Catppuccin accent colors

The rest of the statusline (model, bars, cost) uses Catppuccin Mocha truecolor values defined at the top of the script. Replace the `C_*` variables with your preferred palette if needed.
