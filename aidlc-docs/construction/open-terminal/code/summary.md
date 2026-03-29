# Code Summary: open-terminal（修正・拡張セッション）

## Modified File
| File | Location | Action |
|---|---|---|
| `open-terminal.el` | workspace root | Modified in-place (v0.1.0) |

---

## Function Inventory

| Function | Type | Description |
|---|---|---|
| `open-terminal--get-directory` | Internal helper | Dired/ファイル/その他バッファのディレクトリ解決 |
| `open-terminal--running-p` | Internal helper | `pgrep -x` でターミナルプロセス存在確認 |
| `open-terminal--applescript-escape-path` | Internal helper | AppleScript向けパスエスケープ（シングルクォート対応） |
| `open-terminal--open-terminal-app` | Internal helper | Terminal.app 向け AppleScript（新ウィンドウ、Accessibility不要） |
| `open-terminal--open-iterm2` | Internal helper | iTerm2 向け AppleScript（新タブ/新ウィンドウ） |
| `open-terminal--open-wezterm` | Internal helper | WezTerm CLI（新タブ/新ウィンドウ） |
| `open-terminal--open-ghostty` | Internal helper | Ghostty CLI（新ウィンドウ） |
| `open-terminal--open-generic` | Internal helper | `open -a` フォールバック（その他ターミナル） |
| `open-term` | Public command (`;;;###autoload`) | M-x で呼び出すメインコマンド |
| `open-terminal-setup` | Public command (`;;;###autoload`) | 対話的ターミナル選択・設定コマンド |

## Custom Variable & Constant
| Name | Type | Default | Description |
|---|---|---|---|
| `open-terminal-app` | `defcustom` | `"Terminal"` | 起動するターミナルアプリ名 |
| `open-terminal--supported-apps` | `defconst` | `'("Terminal" "iTerm2" "WezTerm" "Ghostty")` | 専用サポートのあるターミナル一覧 |

---

## Bug Fixes (v0.1.0 → v0.2.0)

### BUG-01: Terminal.app AppleScript エラー修正
- **原因**: `shell-quote-argument` はシェル用エスケープであり、AppleScript 内でパスに特殊文字が含まれると `error 1` が発生していた。また `activate` → `do script` の順序では Terminal.app が応答前にコマンドを受け取りエラーになるケースがあった。さらに `System Events` の `keystroke` は macOS の Accessibility 権限を必要とし、権限がない場合にエラーを引き起こしていた。
- **修正内容**:
  - `open-terminal--applescript-escape-path` を追加し、AppleScript 内のシングルクォート文字列に対応
  - `do script` を `activate` の前に実行する順序に変更
  - `System Events` + `keystroke` を廃止し、`do script "cd 'DIR'"` のみで新ウィンドウを開く方式に統一

---

## Design Decisions (v0.2.0)

### ディレクトリ解決（変更なし）
- `derived-mode-p 'dired-mode` で Dired を判定
- `expand-file-name` で絶対パスに正規化
- 非ファイルバッファは `(expand-file-name "~")` に明示フォールバック

### Terminal.app のタブ廃止
- Terminal.app で新タブを開くには `System Events` + `keystroke "t" using command down` が必要
- これは macOS の Accessibility 権限（アクセシビリティ権限）を必要とし、一般的なセットアップでは動作しない
- 信頼性を優先し、常に新ウィンドウを開く `do script "cd 'DIR'"` のみに統一

### WezTerm 対応
- `wezterm-gui` プロセスで実行中を検出（macOS での WezTerm.app プロセス名）
- 実行中: `wezterm cli spawn --cwd <dir>`（WezTerm mux server への接続）
- 未実行: `wezterm start --cwd <dir>`（新規起動）
- `start-process` を使用してノンブロッキング実行

### Ghostty 対応
- `ghostty --working-directory=<dir>` でディレクトリ指定起動
- `start-process` を使用してノンブロッキング実行

### パスエスケープ（AppleScript 向け）
- `open-terminal--applescript-escape-path` でパスをシングルクォートで囲み、パス中のシングルクォートを `'\''` にエスケープ
- `shell-quote-argument` は廃止（Terminal.app・iTerm2 の AppleScript から削除）

### 診断・セットアップ
- `open-terminal-setup`: `completing-read` + `customize-set-variable` でセッション内設定変更
