# open-terminal.el

An Emacs package that opens your preferred terminal application at the directory of the current buffer.

## Features

- **`M-x open-term`** — Opens the configured terminal at the current buffer's directory
- **`M-x open-terminal-setup`** — Interactively selects and sets the terminal app with completion
- Smart directory resolution across buffer types:
  - **File buffer** → directory containing the file
  - **Dired buffer** → directory currently displayed
  - **Other buffers** (`*scratch*`, etc.) → home directory (`~`)
- Supports new-tab / new-window control for iTerm2 and WezTerm

## Supported Terminals

| Terminal | Behavior | Method |
|---|---|---|
| Terminal.app | Always opens a new window | `open -a Terminal` |
| iTerm2 | New tab (running) / new window (not running) | AppleScript |
| WezTerm | New tab (running) / new window (not running) | `wezterm` CLI |
| Ghostty | Always opens a new window | `ghostty` CLI |
| Any other app | Always opens a new window | `open -a <app>` (fallback) |

## Requirements

- Emacs 30.0 or later
- macOS (the only supported platform)

## Installation

### Manual

1. Clone or download this repository:

```bash
git clone https://github.com/<your-username>/open-terminal.git
```

2. Add the following to your `init.el`:

```elisp
(add-to-list 'load-path "/path/to/open-terminal")
(require 'open-terminal)
```

### straight.el

```elisp
(straight-use-package
 '(open-terminal :host github :repo "<your-username>/open-terminal"))
```

### use-package + straight.el (local)

```elisp
(use-package open-terminal
  :straight (:local-repo "/path/to/open-terminal" :files ("open-terminal.el")))
```

## Configuration

Set `open-terminal-app` to the name of your preferred terminal. The default is `"Terminal"`.

### setq

```elisp
(setq open-terminal-app "WezTerm")
```

### use-package

```elisp
(use-package open-terminal
  :config
  (setq open-terminal-app "WezTerm"))  ; "Terminal" | "iTerm2" | "WezTerm" | "Ghostty"
```

### leaf

```elisp
(leaf open-terminal
  :config
  (setq open-terminal-app "Ghostty"))
```

### Key binding (optional)

```elisp
(global-set-key (kbd "C-c t") #'open-term)
```

### Interactive setup

Run `M-x open-terminal-setup` to select your terminal from a completion list without editing `init.el`. To persist the choice, add `(setq open-terminal-app "<chosen>")` to your `init.el`.

## Usage

| Command | Description |
|---|---|
| `M-x open-term` | Open terminal at current buffer's directory |
| `M-x open-terminal-setup` | Select terminal interactively |

## License

Copyright (C) 2026 Kaito Muraoka
Licensed under the GNU General Public License v3 or later.
See [GNU GPL v3](https://www.gnu.org/licenses/gpl-3.0.html) for details.
