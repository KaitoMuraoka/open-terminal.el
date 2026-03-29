# Build Instructions: open-terminal

## Prerequisites
- **Emacs**: 30.0 以上（NS ビルド / macOS ネイティブビルド）
- **OS**: macOS
- **外部依存**: なし（標準 Emacs + macOS 標準ツールのみ）
- **WezTerm を使う場合**: `wezterm` CLI がインストールされていること
- **Ghostty を使う場合**: `ghostty` コマンドが使用可能であること

---

## インストール方法

### 方法 A: 手動ロード（開発・評価用）

#### 1. ファイルをコピーする
```bash
# open-terminal.el をEmacs のload-pathが通っているディレクトリにコピー
cp open-terminal.el ~/.emacs.d/lisp/
```

または、ワークスペースのパスを直接 `load-path` に追加します（手順 2 参照）。

#### 2. `init.el` に設定を追加する
```elisp
;; load-path にディレクトリを追加（コピーせずに使う場合）
(add-to-list 'load-path "/path/to/open-terminal/")

;; パッケージをロード
(require 'open-terminal)

;; ターミナルを設定（省略時は "Terminal" がデフォルト）
;; (setq open-terminal-app "WezTerm")   ; WezTerm
;; (setq open-terminal-app "Ghostty")   ; Ghostty
;; (setq open-terminal-app "iTerm2")    ; iTerm2
```

#### 3. Emacs を再起動する（またはバッファで `eval-buffer`）

---

### 方法 B: `use-package` + straight.el（ローカルパッケージ）

```elisp
(use-package open-terminal
  :straight (:local-repo "/path/to/open-terminal" :files ("open-terminal.el"))
  :config
  (setq open-terminal-app "WezTerm"))  ; お好みのターミナルに変更
```

---

### 方法 C: `M-x load-file`（動作確認のみ）

1. Emacs で `M-x load-file` を実行
2. `open-terminal.el` のパスを入力
3. `M-x open-terminal-setup` でターミナルを選択
4. `M-x open-terminal-diagnose` で設定を確認
5. `M-x open-term` で動作確認

---

## ロード成功の確認

```
M-x describe-function RET open-term RET
```
docstring が表示されれば正常にロードされています。

```
M-x describe-function RET open-terminal-setup RET
```
新コマンドも確認できます。

```
M-x describe-variable RET open-terminal-app RET
```
カスタマイズ変数が確認できます。

---

## クイックセットアップ（ロード後）

```
M-x open-terminal-setup
```
→ 補完付きでターミナルを選択（Terminal / iTerm2 / WezTerm / Ghostty）

---

## トラブルシューティング

### `Symbol's function definition is void: open-term`
- `require 'open-terminal` が実行されていない
- `load-path` にディレクトリが追加されているか確認

### `do-applescript: No such function`
- Emacs の NS ビルド（macOS ネイティブビルド）が必要
- `brew install emacs` または公式 GUI Emacs を使用
- NS ビルド確認: `emacs -Q --batch --eval "(prin1 (featurep 'ns))"`

### WezTerm で起動しない
- `wezterm` コマンドが PATH に存在するか確認: `which wezterm`
- `M-x open-terminal-diagnose` でプロセス状態を確認
- WezTerm が起動していない場合は `wezterm start` が使われる（プロセス名: `wezterm-gui`）

### Ghostty で起動しない
- `ghostty` コマンドが PATH に存在するか確認: `which ghostty`
- `M-x open-terminal-diagnose` でサポート種別を確認
