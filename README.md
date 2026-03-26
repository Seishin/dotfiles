# dotfiles

My personal configuration for shell, editor, and terminal.

## What’s included

- **Zsh**: `.zshrc`
  - Oh My Zsh + Powerlevel10k
  - macOS light/dark theme detection (switches `p10k` config + fzf colors)
  - Common tool init: `rbenv`, `zoxide`, `fzf`, Ghostty shell integration
  - Aliases wired to modern CLI tools (`eza`, `fd`, `rg`)
- **Vim/Neovim**: `.vimrc`
  - `vim-plug` plugin setup (theme, statusline, fzf, NERDTree, coc.nvim)
  - macOS light/dark theme sync via `defaults read -g AppleInterfaceStyle`
  - A few keybinds + auto-create parent dirs on save
- **Ghostty**: `ghostty/`
  - `ghostty/config` chooses theme by OS appearance:
    - `light:SolarizedLight`
    - `dark:SolarizedDark`
  - Theme definitions in `ghostty/themes/`
- **Git ignore**: `.gitignore` (local nvim state such as `.netrwhist`, undo dir, `.DS_Store`)

## Install

Use the installer to **symlink** the files into your home directory so edits in this repo apply immediately (and it will back up anything it overwrites).

```bash
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run
./install.sh
```

To also install common dependencies (macOS + Homebrew):

```bash
./install.sh --brew
```

### Ghostty config location (macOS)

Ghostty typically reads:

- `~/Library/Application Support/com.mitchellh.ghostty/config`

`install.sh` links `ghostty/config` and `ghostty/themes` into that directory automatically.

## Prerequisites (recommended)

Install what you actually use from these configs:

- **Zsh**
  - [Oh My Zsh](https://ohmyz.sh/)
  - [Powerlevel10k](https://github.com/romkatv/powerlevel10k) (and `~/.p10k-dark.zsh`, `~/.p10k-light.zsh` if you want autoswitching)
  - Plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`
  - Tools referenced by aliases/init: `eza`, `fd`, `ripgrep`, `fzf`, `zoxide`
- **Vim/Neovim**
  - Neovim recommended (`vim` is aliased to `nvim` in `.zshrc`)
  - [`vim-plug`](https://github.com/junegunn/vim-plug)
  - `node` for `coc.nvim`
- **Ghostty**
  - [Ghostty](https://ghostty.org/)

## Notes

- **macOS theme switching**: both `.zshrc` and `.vimrc` read `AppleInterfaceStyle` and adjust behavior based on light vs dark mode.
- **Paths are opinionated**: `.zshrc` sets SDK paths (Android SDK, Zulu JDK 17, Homebrew Ruby/OpenJDK) and adds them to `PATH`.

