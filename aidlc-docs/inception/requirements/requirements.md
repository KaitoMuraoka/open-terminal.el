# Requirements: open-terminal Emacs Plugin（修正・拡張セッション）

## Intent Analysis Summary
- **User Request**: ①ファイル/Diredバッファで `open-term` 実行時にターミナルが起動しない不具合の修正、②WezTerm / Ghostty サポートの追加、③init.el による設定ドキュメントの充実 + 診断・セットアップコマンドの追加
- **Request Type**: Bug Fix + Enhancement（不具合修正 + 機能拡張）
- **Scope Estimate**: Single File（`open-terminal.el` のみ）
- **Complexity Estimate**: Simple-Moderate

---

## Bug Fix Requirements

### BUG-01: Terminal.app AppleScript エラーの修正

**現象**: `M-x open-term` を実行すると Terminal.app は表示されるが、`AppleScript error 1` が発生する。

**根本原因の推定**:
- `do-applescript` 実行時の AppleScript パスエスケープが不適切
- `activate` 後すぐに `do script` を実行するタイミング問題
- `in front window` 参照がケースによっては無効

**修正方針**:
- AppleScript 向けのパスエスケープ関数を追加する（シングルクォート内のシングルクォートを適切にエスケープ）
- Terminal.app の `do script` を `activate` より先に呼ぶ順序に修正
- 新タブ用 AppleScript を `selected tab of front window` ベースに変更

---

## Functional Requirements（既存 + 更新）

### FR-01: コマンド登録（変更なし）
- `open-term` コマンドを `M-x` で呼び出せるように登録する

### FR-02: ディレクトリ解決（変更なし）
- **ファイルバッファ**: そのファイルが存在するディレクトリを使用する
- **Diredバッファ**: Diredが現在表示しているディレクトリを使用する
- **その他のバッファ**: ホームディレクトリ（`~`）を使用する

### FR-03: ターミナルの設定変数（拡張）
- `open-terminal-app` カスタマイズ変数を維持
- デフォルト値: `"Terminal"`
- 新たにサポートするターミナル: `"WezTerm"`, `"Ghostty"`

### FR-04: スマート起動（新ウィンドウ vs 新タブ）（更新）
- ターミナル起動中: 既存ウィンドウに**新しいタブ**を開く
- ターミナル未起動: **新しいウィンドウ**で開く
- 検出方法: `pgrep -x "<terminal-name>"`

### FR-05: WezTerm サポート（新規）
- **起動中の場合**: `wezterm cli spawn --cwd <dir>` を使用して新しいタブを開く
- **未起動の場合**: `wezterm start --cwd <dir>` を使用して新しいウィンドウを開く
- プロセス名検出: `pgrep -x wezterm`

### FR-06: Ghostty サポート（新規）
- **起動中・未起動ともに**: `ghostty --working-directory=<dir>` を使用
- プロセス名検出: `pgrep -x ghostty`
- 注記: Ghostty は現時点でタブ制御CLIを提供していないため、常に新しいウィンドウを開く

### FR-07: 診断コマンド（新規）
- コマンド名: `open-terminal-diagnose`（`M-x open-terminal-diagnose`）
- 実行内容:
  - 現在の `open-terminal-app` の値を表示
  - 設定されたターミナルアプリが `pgrep` で検出できるか確認
  - サポート状況（専用実装か fallback か）を表示
  - 結果を `*Messages*` バッファに出力

### FR-08: セットアップコマンド（新規）
- コマンド名: `open-terminal-setup`（`M-x open-terminal-setup`）
- 実行内容:
  - サポートターミナル一覧（Terminal, iTerm2, WezTerm, Ghostty）を補完候補として提示
  - ユーザーが選択したターミナルを `open-terminal-app` に設定（`customize-set-variable`）
  - セッション内に即反映

### FR-09: init.el ドキュメントの充実（新規）
- `;;; Commentary:` セクションに以下の設定例を追加:
  - `setq` による直接設定
  - `use-package` / `leaf` スタイル設定例
  - 各ターミナルの設定例（Terminal, iTerm2, WezTerm, Ghostty）

---

## Non-Functional Requirements（変更なし）

### NFR-01: OS サポート
- macOS 専用

### NFR-02: Emacs バージョン互換性
- Emacs 30.0 以上

### NFR-03: ターミナル互換性（macOS）
- **Terminal.app**: AppleScript（修正後）
- **iTerm2**: AppleScript
- **WezTerm**: `wezterm` CLI
- **Ghostty**: `ghostty` CLI
- **その他**: `open -a <app> .`（fallback）

### NFR-04: セキュリティ
- セキュリティ拡張ルール: スキップ（プロトタイプ段階、前回と同じ）

### NFR-05: パッケージ仕様
- `Package-Requires`: `((emacs "30.0"))`
- 外部依存: なし

---

## User Scenarios（更新）

### シナリオ 1: ファイル編集中にターミナルを開く（バグ修正後）
1. ユーザーが `~/project/main.py` を Emacs で編集中
2. `M-x open-term` を実行
3. Terminal.app が起動していない → AppleScript エラーなしで `~/project/` で新しいウィンドウを開く

### シナリオ 2: WezTerm で開く
1. `(setq open-terminal-app "WezTerm")` を設定済み
2. `M-x open-term` を実行
3. WezTerm が起動中 → `wezterm cli spawn --cwd ~/project/` で新しいタブを開く

### シナリオ 3: Ghostty で開く
1. `(setq open-terminal-app "Ghostty")` を設定済み
2. `M-x open-term` を実行
3. `ghostty --working-directory=~/project/` で新しいウィンドウを開く

### シナリオ 4: 診断コマンドで動作確認
1. `M-x open-terminal-diagnose` を実行
2. `*Messages*` に「Current terminal: WezTerm | Status: Running | Support: Native CLI」などを表示

### シナリオ 5: セットアップコマンドで設定変更
1. `M-x open-terminal-setup` を実行
2. 補完候補「Terminal / iTerm2 / WezTerm / Ghostty」から選択
3. 選択内容が即座に `open-terminal-app` に反映される

---

## Technical Notes

### Terminal.app AppleScript パスエスケープ
- AppleScript の `do script "cd '...' "` 内でパスをシングルクォートで囲む
- パス中のシングルクォートは `'\''` 形式でエスケープする専用ヘルパー関数を実装

### WezTerm CLI
- `wezterm cli spawn --cwd <dir>` は wezterm が起動中のみ使用可能
- `wezterm start --cwd <dir>` は新しいプロセスとして起動

### Ghostty CLI
- `ghostty --working-directory=<dir>` でディレクトリ指定起動
- 常に新しいウィンドウが開く（タブ制御なし）
