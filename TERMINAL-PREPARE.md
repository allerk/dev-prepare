# Гайд: Настройка профессионального терминала на macOS (Zsh + P10k + Tmux + Claude)

Этот документ содержит пошаговую инструкцию по созданию интерфейса терминала с Zsh, Powerlevel10k, Tmux и Claude Code, как на скриншоте.

---

## 1. Подготовка: Установка Homebrew

Если менеджер пакетов Homebrew еще не установлен, выполните эту команду:

```bash
/bin/bash -c "$(curl -fsSL [https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh](https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh))"
```

---

## 2. Шрифты (Nerd Fonts)

Для корректного отображения иконок (Apple, Git, стрелочки) необходим специальный шрифт, иначе вместо иконок будут квадраты.

1. Установите шрифт через brew:
```bash
brew install --cask font-jetbrains-mono-nerd-font
```

2. **Настройка приложения:** Зайдите в настройки вашего терминала (iTerm2 или стандартный Terminal) -> **Profiles** -> **Text** -> **Font** и выберите **JetBrainsMono Nerd Font**.

---

## 3. Настройка оболочки Zsh и темы Powerlevel10k

1. Установите **Oh My Zsh**:
```bash
sh -c "$(curl -fsSL [https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh](https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh))"
```

2. Скачайте тему **Powerlevel10k**:
```bash
git clone --depth=1 [https://github.com/romkatv/powerlevel10k.git](https://github.com/romkatv/powerlevel10k.git) ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

3. Активируйте тему в конфиге:
- Откройте файл конфигурации: `nano ~/.zshrc`
- Найдите строку `ZSH_THEME="..."` и замените её на: `ZSH_THEME="powerlevel10k/powerlevel10k"`
- Сохраните изменения (Ctrl+O, Enter, Ctrl+X).

4. Перезапустите терминал. Автоматически запустится мастер настройки (`p10k configure`). Выбирайте стиль **Rainbow** и разделители **Slanted** для эффекта "стрелочек".

---

## 4. Полезные плагины (Автодополнение и подсветка)

Установите плагины, чтобы терминал подсказывал команды серым цветом:

```bash
git clone [https://github.com/zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone [https://github.com/zsh-users/zsh-syntax-highlighting.git](https://github.com/zsh-users/zsh-syntax-highlighting.git) ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

Откройте `nano ~/.zshrc`, найдите строку `plugins=(git)` и замените её на:
```text
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
```
После этого примените изменения командой: `source ~/.zshrc`

---

## 5. Настройка Tmux (Нижний статус-бар)

1. Установите **tmux** и менеджер плагинов **TPM**:
```bash
brew install tmux
git clone [https://github.com/tmux-plugins/tpm](https://github.com/tmux-plugins/tpm) ~/.tmux/plugins/tpm
```

2. Создайте файл конфигурации: `nano ~/.tmux.conf` и вставьте туда следующий блок:
```tmux
set -g mouse on
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'catppuccin/tmux'
set -g @catppuccin_flavour 'mocha'
set -g @catppuccin_window_tabs_enabled on
run '~/.tmux/plugins/tpm/tpm'
```
3. Сохраните файл. Запустите tmux командой `tmux`. Находясь в tmux, нажмите `Ctrl + B`, отпустите, а затем нажмите `I` (заглавную), чтобы установить тему Catppuccin.

---

## 6. Установка Claude Code (Инструмент со скрина)

1. Установите Node.js (если его еще нет): 
```bash
brew install node
```

2. Установите Claude Code:
```bash
npm install -g @anthropic-ai/claude-code
```

3. Для запуска просто введите:
```bash
claude
```

---

## Финальный результат

Чтобы получить вид ровно как на скриншоте, ваш сценарий использования будет таким:
1. Открываете терминал.
2. Вводите `tmux` (появляется фиолетовая нижняя панель с вкладками).
3. Вводите `claude` (запускается интерфейс ИИ-ассистента).
