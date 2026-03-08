# GitHub Access for Claude Code

Claude Code can interact with GitHub using the `gh` CLI — no MCP server required.

---

## How it works

Claude Code runs `gh` commands via its Bash tool. As long as `gh` is installed and authenticated, Claude can:

- View and create issues and pull requests
- Read PR diffs, reviews, and comments
- Push branches and merge PRs
- Make raw API calls via `gh api`

---

## Setup

### 1. Install `gh`

**macOS:**
```bash
brew install gh
```

**Linux:**
```bash
# Debian/Ubuntu
sudo apt install gh

# Arch
sudo pacman -S github-cli
```

**Windows:** [github.com/cli/cli/releases](https://github.com/cli/cli/releases)

### 2. Authenticate

```bash
gh auth login
```

Select **GitHub.com** → **HTTPS** → **Login with a web browser** (or paste a token).

### 3. Verify

```bash
gh auth status
```

That's it — Claude Code will pick up the `gh` session automatically.

---

## Usage examples

Once set up, you can ask Claude things like:

- "Show me issue #42 in org/repo"
- "Create a PR from this branch with a summary of changes"
- "List open PRs assigned to me"
- "Add a comment to PR #10"

Claude will use `gh` commands under the hood, e.g.:

```bash
gh issue view 42 --repo org/repo
gh pr create --title "..." --body "..."
gh pr list --assignee @me
```

---

## Why not MCP?

The [GitHub MCP server](https://github.com/github/github-mcp-server) provides a structured tool interface but requires separate installation and stores a raw GitHub token in `~/.claude.json` (plain text). The `gh` CLI is simpler, already handles token storage securely via the system keychain, and covers the same functionality.
