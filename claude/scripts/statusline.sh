#!/usr/bin/env bash
# Claude Code Statusline — Catppuccin Mocha + Nerdfont v3
# Reads JSON from Claude Code stdin; fetches live usage from Anthropic OAuth API.
#
# OS COMPATIBILITY NOTES:
#   macOS  — works out of the box (uses Keychain, BSD date/stat)
#   Linux  — requires 3 small changes, marked with [LINUX] comments below

# ── Catppuccin Mocha truecolor palette ──────────────────────────────────────
R='\033[0m'
BOLD='\033[1m'
C_MAUVE='\033[38;2;203;166;247m'    # model name
C_BLUE='\033[38;2;137;180;250m'     # cost
C_GREEN='\033[38;2;166;227;161m'    # bar low
C_YELLOW='\033[38;2;249;226;175m'   # bar mid
C_PEACH='\033[38;2;250;179;135m'    # 5h block
C_RED='\033[38;2;243;139;168m'      # bar high
C_TEXT='\033[38;2;205;214;244m'     # general text
C_SUBTEXT='\033[38;2;163;167;186m'  # weekly
C_OVERLAY='\033[38;2;108;112;134m'  # separators

SEP="${C_OVERLAY}│${R}"

# ── Read Claude Code JSON from stdin ────────────────────────────────────────
INPUT=$(cat)

MODEL=$(echo "$INPUT"    | jq -r '.model.display_name // ""'              2>/dev/null)
USED_PCT=$(echo "$INPUT" | jq -r '.context_window.used_percentage // 0'  2>/dev/null)
TOTAL_COST=$(echo "$INPUT" | jq -r '.cost.total_cost_usd // 0'           2>/dev/null)

# Shorten model: "claude-sonnet-4-6" → "sonnet-4-6"
MODEL_SHORT=$(echo "$MODEL" | sed 's/^claude-//')
[ -z "$MODEL_SHORT" ] && MODEL_SHORT="claude"

# ── Progress bar helper ───────────────────────────────────────────────────────
BAR_W=10

make_bar() {
    local pct=$1 filled empty bar=""
    filled=$(( pct * BAR_W / 100 ))
    empty=$(( BAR_W - filled ))
    [ "$filled" -gt "$BAR_W" ] && filled=$BAR_W
    [ "$filled" -lt 0 ] && filled=0
    [ "$empty"  -lt 0 ] && empty=0
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=0; i<empty;  i++)); do bar="${bar}░"; done
    echo "$bar"
}

bar_color() {
    local pct=$1
    if   [ "$pct" -lt 50 ]; then echo "$C_GREEN"
    elif [ "$pct" -lt 80 ]; then echo "$C_YELLOW"
    else                          echo "$C_RED"
    fi
}

# ── Context window bar ────────────────────────────────────────────────────────
CTX_PCT=$(printf "%.0f" "${USED_PCT:-0}" 2>/dev/null || echo 0)
[ "$CTX_PCT" -gt 100 ] && CTX_PCT=100
CTX_BAR=$(make_bar "$CTX_PCT")
CTX_COLOR=$(bar_color "$CTX_PCT")

# ── Session cost ─────────────────────────────────────────────────────────────
COST_STR=$(printf '$%.4f' "${TOTAL_COST:-0}" 2>/dev/null || echo '$0.0000')

# ── Live usage via Anthropic OAuth API ───────────────────────────────────────
CACHE_DIR="$HOME/.cache"
API_CACHE="$CACHE_DIR/claude-usage-api.json"
LOCK_FILE="$CACHE_DIR/claude-usage-api.lock"
[ -d "$CACHE_DIR" ] || mkdir -p "$CACHE_DIR"

# [LINUX] Replace this function body with:
#   mod=$(stat -c '%Y' "$1" 2>/dev/null) || { echo 9999; return; }
#   echo $(( $(date +%s) - mod ))
get_file_age() {
    local mod
    mod=$(stat -f '%m' "$1" 2>/dev/null) || { echo 9999; return; }
    echo $(( $(date +%s) - mod ))
}

fetch_usage() {
    # Return cache if < 60s old
    if [ -f "$API_CACHE" ]; then
        local age; age=$(get_file_age "$API_CACHE")
        [ "$age" -lt 60 ] && { cat "$API_CACHE"; return; }
    fi
    # Rate-limit: one real request per 30s
    if [ -f "$LOCK_FILE" ]; then
        local lock_age; lock_age=$(get_file_age "$LOCK_FILE")
        [ "$lock_age" -lt 30 ] && { [ -f "$API_CACHE" ] && cat "$API_CACHE"; return; }
    fi
    touch "$LOCK_FILE"

    # [LINUX] Replace the next 2 lines with:
    #   local creds_file="$HOME/.claude/.credentials.json"
    #   local token; token=$(jq -r '.claudeAiOauth.accessToken // empty' "$creds_file" 2>/dev/null)
    local keychain
    keychain=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
    [ -z "$keychain" ] && { [ -f "$API_CACHE" ] && cat "$API_CACHE"; return; }
    local token
    token=$(echo "$keychain" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
    [ -z "$token" ] && { [ -f "$API_CACHE" ] && cat "$API_CACHE"; return; }

    local claude_ver
    claude_ver=$(claude -v 2>/dev/null || echo "2.1.69")

    local resp
    resp=$(curl -s --max-time 5 "https://api.anthropic.com/api/oauth/usage" \
        -H "Authorization: Bearer $token" \
        -H "anthropic-beta: oauth-2025-04-20" \
        -H "User-Agent: claude-code/$claude_ver" 2>/dev/null)

    if [ -n "$resp" ]; then
        echo "$resp" | tee "$API_CACHE"
    else
        [ -f "$API_CACHE" ] && cat "$API_CACHE"
    fi
}

# [LINUX] Replace this function body with:
#   local clean; clean=$(echo "$1" | sed 's/\.[0-9]*//; s/+00:00//; s/Z$//')
#   local reset_ts; reset_ts=$(date -u -d "$clean" +%s 2>/dev/null)
#   [ -n "$reset_ts" ] && echo $(( reset_ts - $(date +%s) )) || echo ""
iso_secs_left() {
    local iso="$1"
    local clean; clean=$(echo "$iso" | sed 's/\.[0-9]*//; s/+00:00//; s/Z$//')
    local reset_ts; reset_ts=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "$clean" "+%s" 2>/dev/null)
    [ -n "$reset_ts" ] && echo $(( reset_ts - $(date +%s) )) || echo ""
}

fmt_hm() {
    local s=${1:-0}; [ "$s" -le 0 ] && s=0
    local h=$(( s / 3600 )) m=$(( (s % 3600) / 60 ))
    printf "%dh%02dm" "$h" "$m"
}

fmt_dhm() {
    local s=${1:-0}; [ "$s" -le 0 ] && s=0
    local d=$(( s / 86400 )) h=$(( (s % 86400) / 3600 ))
    [ "$d" -gt 0 ] && printf "%dd%02dh" "$d" "$h" || fmt_hm "$s"
}

# ── Fetch and parse ───────────────────────────────────────────────────────────
USAGE=$(fetch_usage)

SESSION_PCT=0; SESSION_RESET="—"
WEEK_PCT=0;    WEEK_RESET="—"

if [ -n "$USAGE" ]; then
    RAW_5H=$(echo "$USAGE"  | jq -r '.five_hour.utilization  // empty' 2>/dev/null)
    RAW_7D=$(echo "$USAGE"  | jq -r '.seven_day.utilization  // empty' 2>/dev/null)
    RST_5H=$(echo "$USAGE"  | jq -r '.five_hour.resets_at    // empty' 2>/dev/null)
    RST_7D=$(echo "$USAGE"  | jq -r '.seven_day.resets_at    // empty' 2>/dev/null)

    if [ -n "$RAW_5H" ] || [ -n "$RAW_7D" ]; then
        SESSION_PCT=${RAW_5H%.*}; SESSION_PCT=${SESSION_PCT:-0}
        WEEK_PCT=${RAW_7D%.*};    WEEK_PCT=${WEEK_PCT:-0}
        [ -n "$RST_5H" ] && { secs=$(iso_secs_left "$RST_5H"); SESSION_RESET=$(fmt_hm  "$secs"); }
        [ -n "$RST_7D" ] && { secs=$(iso_secs_left "$RST_7D"); WEEK_RESET=$(fmt_dhm "$secs"); }
    fi
fi

# ── Bars ──────────────────────────────────────────────────────────────────────
[ "$SESSION_PCT" -gt 100 ] && SESSION_PCT=100
[ "$WEEK_PCT"    -gt 100 ] && WEEK_PCT=100
SESSION_BAR=$(make_bar "$SESSION_PCT"); SESSION_COLOR=$(bar_color "$SESSION_PCT")
WEEK_BAR=$(make_bar    "$WEEK_PCT");    WEEK_COLOR=$(bar_color    "$WEEK_PCT")

# ── Current working directory (shortened) ────────────────────────────────────
CWD="${PWD:-$OLDPWD}"
CWD="${CWD/#$HOME/\~}"
IFS='/' read -ra PARTS <<< "$CWD"
N=${#PARTS[@]}
if [ "$N" -gt 4 ]; then
    CWD="${PARTS[0]}/${PARTS[1]}/…/${PARTS[$((N-2))]}/${PARTS[$((N-1))]}"
fi

# ── Current git branch + status ──────────────────────────────────────────────
GIT_BRANCH=$(git -C "${PWD:-$OLDPWD}" rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$GIT_BRANCH" ]; then
    if git -C "${PWD:-$OLDPWD}" diff --quiet 2>/dev/null && \
       git -C "${PWD:-$OLDPWD}" diff --cached --quiet 2>/dev/null && \
       [ -z "$(git -C "${PWD:-$OLDPWD}" ls-files --others --exclude-standard 2>/dev/null)" ]; then
        GIT_STATUS="✅"
    else
        GIT_STATUS="❌"
    fi
fi

# ── Powerline segment colors — indexed ANSI (mirrors p10k: DIR_BG=4, VCS_BG=2/3) ──
# Uses terminal's own color palette so the segments match your shell theme automatically.
BG_PATH='\033[48;5;4m'       # terminal color 4 (blue — p10k DIR_BACKGROUND=4)
FG_SEG='\033[38;5;254m'      # terminal color 254 (light gray — p10k DIR_FOREGROUND=254)

BG_VCS_CLEAN='\033[48;5;2m'  # terminal color 2 (green  — p10k VCS_CLEAN_BACKGROUND=2)
BG_VCS_MOD='\033[48;5;3m'    # terminal color 3 (yellow — p10k VCS_MODIFIED_BACKGROUND=3)

PL=' '  # U+E0BC + space (POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR)

# Separators: FG = prev segment BG index, BG = next segment BG index (or default)
PL_PATH_VCS_CLEAN='\033[38;5;4m\033[48;5;2m'"${PL}"
PL_PATH_VCS_MOD='\033[38;5;4m\033[48;5;3m'"${PL}"
PL_VCS_CLEAN_END='\033[38;5;2m\033[49m'"${PL}"
PL_VCS_MOD_END='\033[38;5;3m\033[49m'"${PL}"
PL_PATH_END='\033[38;5;4m\033[49m'"${PL}"

# ── Assemble output line ─────────────────────────────────────────────────────
OUT=""

# Path segment
OUT+="${BG_PATH}${FG_SEG} 󰉋 ${CWD} ${R}"

# Git segment (if in a repo)
if [ -n "$GIT_BRANCH" ]; then
    if [ "$GIT_STATUS" = "✅" ]; then
        OUT+="${PL_PATH_VCS_CLEAN}${BG_VCS_CLEAN}${FG_SEG} on   ${GIT_BRANCH} ${GIT_STATUS} ${R}${PL_VCS_CLEAN_END}"
    else
        OUT+="${PL_PATH_VCS_MOD}${BG_VCS_MOD}${FG_SEG} on   ${GIT_BRANCH} ${GIT_STATUS} ${R}${PL_VCS_MOD_END}"
    fi
else
    OUT+="${PL_PATH_END}"
fi

OUT+="${R}  ${SEP}  ${C_MAUVE}${BOLD}󱙺 ${MODEL_SHORT}${R}"
OUT+="  ${SEP}  ${C_TEXT}context: ${CTX_COLOR}${CTX_BAR}${R} ${C_TEXT}${CTX_PCT}%${R}"
OUT+="  ${SEP}  ${C_BLUE}${COST_STR}${R}"
OUT+="  ${SEP}  ${C_PEACH}session (${SESSION_RESET}): ${SESSION_COLOR}${SESSION_BAR}${R} ${C_TEXT}${SESSION_PCT}%${R}"
OUT+=",  ${C_SUBTEXT}weekly (${WEEK_RESET}): ${WEEK_COLOR}${WEEK_BAR}${R} ${C_TEXT}${WEEK_PCT}%${R}"

printf "%b\n" "$OUT"
