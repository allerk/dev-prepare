# Guide: Setting up a professional terminal on macOS (Zsh + P10k + Tmux + Claude)

This document is a step-by-step guide for setting up a terminal environment with Zsh, Powerlevel10k, Tmux and Claude Code.

---

## 1. Prerequisites: Install Homebrew

If the Homebrew package manager is not installed yet, run this command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

---

## 2. Fonts (Nerd Fonts)

A Nerd Font is required for icons (Apple logo, Git symbols, arrows) to render correctly. Without it you will see empty squares instead of icons.

1. Install the font via Homebrew:
```bash
brew install --cask font-jetbrains-mono-nerd-font
```

2. **Apply in your terminal app:** Open your terminal settings (iTerm2 or the default Terminal) → **Profiles** → **Text** → **Font** and select **JetBrainsMono Nerd Font**.

---

## 3. Zsh shell and Powerlevel10k theme

1. Install **Oh My Zsh**:
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

2. Clone the **Powerlevel10k** theme:
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

3. Activate the theme:
- Open your config: `nano ~/.zshrc`
- Find the line `ZSH_THEME="..."` and replace it with: `ZSH_THEME="powerlevel10k/powerlevel10k"`
- Save and exit (Ctrl+O, Enter, Ctrl+X).

4. Restart the terminal. The setup wizard (`p10k configure`) will launch automatically. Choose the **Rainbow** style and **Slanted** separators to get the arrow segment effect.

---

## 4. Useful plugins (autosuggestions and syntax highlighting)

Install plugins to get inline gray command suggestions as you type:

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

Open `nano ~/.zshrc`, find the line `plugins=(git)` and replace it with:
```text
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
```
Then apply the changes: `source ~/.zshrc`

---

## 5. Tmux (bottom status bar)

1. Install **tmux** and the **TPM** plugin manager:
```bash
brew install tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

2. Create the config file: `nano ~/.tmux.conf` and paste the following:
```tmux
set -g mouse on
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'catppuccin/tmux'
set -g @catppuccin_flavour 'mocha'
set -g @catppuccin_window_tabs_enabled on
run '~/.tmux/plugins/tpm/tpm'
```
3. Save the file. Start tmux with `tmux`. Inside tmux, press `Ctrl+B`, release, then press `I` (uppercase) to install the Catppuccin theme.

---

## 6. Install Claude Code

1. Install Node.js if not already installed:
```bash
brew install node
```

2. Install Claude Code:
```bash
npm install -g @anthropic-ai/claude-code
```

3. Launch it:
```bash
claude
```

---

## End result

To get the full setup running:
1. Open the terminal.
2. Type `tmux` — the Catppuccin status bar appears at the bottom.
3. Type `claude` — the Claude Code interface launches.
