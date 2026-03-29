# Code Generation Plan: open-terminal（修正・拡張セッション）

## Unit Context
- **Unit Name**: open-terminal
- **Target File**: `open-terminal.el`（修正・in-place）
- **Language**: Emacs Lisp
- **Target OS**: macOS
- **Emacs Version**: 30.0+
- **Change Type**: Brownfield - modify existing file in-place

## Requirements Traceability
- BUG-01: Terminal.app AppleScript エラー修正
- FR-05: WezTerm サポート（wezterm CLI）
- FR-06: Ghostty サポート（ghostty CLI）
- FR-07: `open-terminal-diagnose` コマンド追加
- FR-08: `open-terminal-setup` コマンド追加
- FR-09: Commentary に init.el 設定例を追加

---

## 変更内容の設計

### BUG-01: Terminal.app AppleScript 修正

**問題**: `do script "cd <path>"` 実行時に `AppleScript error 1` が発生する。

**修正内容**:
1. `open-terminal--applescript-escape-path` ヘルパーを追加（`shell-quote-argument` の代替）
2. `activate` の前に `do script` を実行する順序に変更
3. System Events `keystroke` を廃止し `do script "cd 'DIR'"` のみに統一（Accessibility権限不要）

### WezTerm サポート
- 起動中（`wezterm-gui` プロセス検出）: `wezterm cli spawn --cwd <dir>`
- 未起動: `wezterm start --cwd <dir>`

### Ghostty サポート
- 常に: `ghostty --working-directory=<dir>`

---

## Generation Steps

- [x] **Step 1**: `open-terminal--applescript-escape-path` ヘルパー関数の追加
- [x] **Step 2**: `open-terminal--open-terminal-app` 関数の修正（Terminal.app BUG FIX）
- [x] **Step 3**: `open-terminal--open-iterm2` 関数のパスエスケープ修正
- [x] **Step 4**: `open-terminal--open-wezterm` 関数の追加（WezTerm 新規サポート）
- [x] **Step 5**: `open-terminal--open-ghostty` 関数の追加（Ghostty 新規サポート）
- [x] **Step 6**: `open-terminal-app` の docstring 更新
- [x] **Step 7**: `open-term` の `pcase` に `"WezTerm"` / `"Ghostty"` ブランチ追加
- [x] **Step 8**: `open-terminal-diagnose` コマンドの追加
- [x] **Step 9**: `open-terminal-setup` コマンドの追加
- [x] **Step 10**: Commentary 更新（init.el / use-package / leaf 設定例）
- [x] **Step 11**: コードサマリードキュメントの更新

---

## File Locations
- **Application Code**: `/Users/kaitomuraoka/product/open-terminal/open-terminal.el`（in-place 修正）
- **Documentation**: `/Users/kaitomuraoka/product/open-terminal/aidlc-docs/construction/open-terminal/code/summary.md`
