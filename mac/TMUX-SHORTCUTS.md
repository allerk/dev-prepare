# Tmux Shortcuts

> Most tmux shortcuts start with **`Ctrl + B`** (hold Ctrl, press B, release both), then press the next key.

---

## Windows

| Action | Shortcut |
|---|---|
| New window | `Ctrl+B` then `c` |
| Switch to window 1 | `Ctrl+B` then `1` |
| Switch to window 2 | `Ctrl+B` then `2` |
| Switch to window N | `Ctrl+B` then `N` |
| Next window | `Ctrl+B` then `n` |
| Previous window | `Ctrl+B` then `p` |
| List all windows (visual picker) | `Ctrl+B` then `w` |
| Rename current window | `Ctrl+B` then `,` |
| Close current window | `Ctrl+B` then `&` |

---

## Panes (splits)

| Action | Shortcut |
|---|---|
| Split into left/right panes | `Ctrl+B` then `%` |
| Split into top/bottom panes | `Ctrl+B` then `"` |
| Switch to next pane | `Ctrl+B` then `o` |
| Switch pane by direction | `Ctrl+B` then Arrow keys |
| Zoom pane (toggle fullscreen) | `Ctrl+B` then `z` |
| Close current pane | `Ctrl+B` then `x` |

---

## Scrolling

| Action | Shortcut |
|---|---|
| Enter scroll mode | `Ctrl+B` then `[` |
| Scroll up (line by line) | Arrow Up or `k` |
| Scroll down (line by line) | Arrow Down or `j` |
| Scroll up (page) | `Page Up` or `Ctrl+U` |
| Scroll down (page) | `Page Down` or `Ctrl+D` |
| Jump to top of history | `g` |
| Jump to bottom of history | `G` |
| Exit scroll mode | `q` or `Escape` |

> If `set -g mouse on` is in your `tmux.conf`, you can scroll with the mouse wheel directly (no scroll mode needed).

---

## Sessions

| Action | Shortcut |
|---|---|
| Detach from session | `Ctrl+B` then `d` |
| Switch between sessions (visual) | `Ctrl+B` then `s` |
| New session (from terminal) | `tmux new -s <name>` |
| List sessions (from terminal) | `tmux ls` |
| Attach to session (from terminal) | `tmux attach -t <name>` |

---

## Misc

| Action | Shortcut |
|---|---|
| Show all key bindings | `Ctrl+B` then `?` |
| Command prompt | `Ctrl+B` then `:` |
| Reload config | `Ctrl+B` then `:` → type `source-file ~/.tmux.conf` |
