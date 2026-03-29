;;; open-terminal.el --- Open default terminal at current buffer's directory -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Kaito Muraoka

;; Author: Kaito Muraoka
;; Version: 0.1.0
;; Package-Requires: ((emacs "30.0"))
;; Keywords: tools, terminal
;; URL: TBD

;;; Commentary:
;; open-terminal provides commands to open your preferred terminal
;; application at the directory of the current buffer.
;;
;; Commands:
;;   M-x open-term           — Open terminal at current buffer's directory
;;   M-x open-terminal-setup — Interactively select and set the terminal app
;;
;; Directory resolution:
;;   - File buffer  : the directory containing the current file
;;   - Dired buffer : the directory currently displayed
;;   - Other buffers: the home directory (~)
;;
;; Supported terminals:
;;   - Terminal.app (macOS built-in) — opens a new window
;;   - iTerm2                        — new tab when running, new window when not
;;   - WezTerm                       — new tab when running, new window when not
;;   - Ghostty                       — opens a new window
;;   - Any other app                 — fallback: `open -a <app> .'
;;
;; Quick setup:
;;   Run `M-x open-terminal-setup' to select your terminal interactively.
;;
;; Configuration via init.el:
;;
;;   ;; Simple setq:
;;   (setq open-terminal-app "WezTerm")
;;
;;   ;; With use-package:
;;   (use-package open-terminal
;;     :load-path "/path/to/open-terminal"
;;     :config
;;     (setq open-terminal-app "WezTerm"))   ; "Terminal" "iTerm2" "WezTerm" "Ghostty"
;;
;;   ;; With leaf:
;;   (leaf open-terminal
;;     :load-path "/path/to/open-terminal"
;;     :config
;;     (setq open-terminal-app "Ghostty"))
;;
;;   ;; Optional key binding:
;;   (global-set-key (kbd "C-c t") #'open-term)

;;; Code:

(defgroup open-terminal nil
  "Open a terminal application at the current buffer's directory."
  :group 'tools
  :prefix "open-terminal-")

(defcustom open-terminal-app "Terminal"
  "Name of the terminal application to open.

Terminals with AppleScript control (macOS):
  \"Terminal\"  — macOS built-in Terminal.app (always opens a new window)
  \"iTerm2\"    — iTerm2 (new tab when running, new window when not)

Terminals with CLI-based control:
  \"WezTerm\"   — WezTerm (new tab when running, new window when not)
  \"Ghostty\"   — Ghostty (always opens a new window)

Any other value falls back to `open -a <app> .' (new window only).

Use `open-terminal-setup' to change this setting interactively."
  :type 'string
  :group 'open-terminal)

(defconst open-terminal--supported-apps
  '("Terminal" "iTerm2" "WezTerm" "Ghostty")
  "Terminal applications with dedicated support in open-terminal.")

;;; --- Internal helpers ---

(defun open-terminal--get-directory ()
  "Return the directory to open in the terminal.

Resolution order:
  1. Dired buffer      -> the directory Dired is displaying
  2. File buffer       -> the directory containing the visited file
  3. All other buffers -> the home directory (~)"
  (cond
   ((derived-mode-p 'dired-mode)
    (expand-file-name default-directory))
   ((buffer-file-name)
    (file-name-directory (expand-file-name (buffer-file-name))))
   (t
    (expand-file-name "~"))))

(defun open-terminal--running-p (app-name)
  "Return non-nil if a process whose name exactly matches APP-NAME is running."
  (= 0 (call-process "pgrep" nil nil nil "-x" app-name)))

(defun open-terminal--applescript-escape-path (dir)
  "Return DIR escaped for embedding in a single-quoted shell string in AppleScript.
Single quotes in DIR are replaced with the shell escape sequence `\\'\\''
and the result is wrapped in single quotes.
Example: \"/Users/kai/it's/\" => \"\\='/Users/kai/it\\'\\''s/\\'\"."
  (concat "'"
          (replace-regexp-in-string "'" "'\\''" dir nil t)
          "'"))

(defun open-terminal--open-terminal-app (dir)
  "Open Terminal.app at DIR in a new window.
Uses the macOS `open -a' command to launch Terminal.app at the given
directory.  This avoids AppleScript and works regardless of Emacs build."
  (let ((default-directory dir))
    (call-process "open" nil nil nil "-a" "Terminal" ".")))

(defun open-terminal--open-iterm2 (dir)
  "Open iTerm2 at DIR.
Opens a new tab when iTerm2 is already running;
opens a new window otherwise."
  (if (open-terminal--running-p "iTerm2")
      (do-applescript
       (format
        "tell application \"iTerm2\"
  activate
  tell current window
    create tab with default profile
    tell current session of current tab
      write text \"cd %s\"
    end tell
  end tell
end tell"
        (open-terminal--applescript-escape-path dir)))
    (do-applescript
     (format
      "tell application \"iTerm2\"
  activate
  create window with default profile
  tell current session of current tab of current window
    write text \"cd %s\"
  end tell
end tell"
      (open-terminal--applescript-escape-path dir)))))

(defun open-terminal--open-wezterm (dir)
  "Open WezTerm at DIR.
Opens a new tab in the running WezTerm instance via `wezterm cli spawn';
starts a new WezTerm window via `wezterm start' when not running.
Detects a running instance by checking for the `wezterm-gui' process."
  (if (open-terminal--running-p "wezterm-gui")
      (start-process "open-terminal-wezterm" nil "wezterm" "cli" "spawn" "--cwd" dir)
    (start-process "open-terminal-wezterm" nil "wezterm" "start" "--cwd" dir)))

(defun open-terminal--open-ghostty (dir)
  "Open Ghostty at DIR in a new window.
Uses the `--working-directory' flag of the ghostty CLI."
  (start-process "open-terminal-ghostty" nil "ghostty"
                 (concat "--working-directory=" dir)))

(defun open-terminal--open-generic (app-name dir)
  "Open APP-NAME terminal at DIR using `open -a' (fallback for unsupported terminals).
Note: new-tab control is not available in this fallback mode."
  (let ((default-directory dir))
    (call-process "open" nil nil nil "-a" app-name ".")))

;;; --- Public commands ---

;;;###autoload
(defun open-term ()
  "Open the configured terminal at the current buffer's directory.

The terminal is determined by `open-terminal-app' (default: \"Terminal\").
Use `open-terminal-setup' to change it interactively.

Supported terminals (dedicated support):
  Terminal  — macOS built-in Terminal.app (new window)
  iTerm2    — new tab when running, new window when not
  WezTerm   — new tab when running, new window when not
  Ghostty   — new window via CLI

Any other value in `open-terminal-app' uses `open -a' as a fallback."
  (interactive)
  (let ((dir (open-terminal--get-directory)))
    (pcase open-terminal-app
      ("Terminal" (open-terminal--open-terminal-app dir))
      ("iTerm2"   (open-terminal--open-iterm2 dir))
      ("WezTerm"  (open-terminal--open-wezterm dir))
      ("Ghostty"  (open-terminal--open-ghostty dir))
      (_          (open-terminal--open-generic open-terminal-app dir)))))

;;;###autoload
(defun open-terminal-setup ()
  "Interactively select and configure the terminal application to use.
Presents supported terminals with completion and sets `open-terminal-app'
for the current Emacs session.

To persist the setting across sessions, add to your init.el:
  (setq open-terminal-app \"<chosen-terminal>\")"
  (interactive)
  (let ((choice (completing-read
                 (format "Select terminal app (current: %s): "
                         open-terminal-app)
                 open-terminal--supported-apps
                 nil nil nil nil
                 open-terminal-app)))
    (customize-set-variable 'open-terminal-app choice)
    (message "open-terminal-app set to: %s  (add to init.el to persist)" choice)))

(provide 'open-terminal)

;;; open-terminal.el ends here
