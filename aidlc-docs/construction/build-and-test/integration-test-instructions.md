# Integration Test Instructions: open-terminal

## 概要
Emacs と macOS ターミナルアプリ間のエンドツーエンド動作を手動で確認します。

---

## 事前準備
1. `open-terminal.el` をロード済みであること（build-instructions.md 参照）
2. macOS 上の Emacs（NS ビルド）で実行していること

---

## シナリオ 1: ファイルバッファ → Terminal.app（未起動時）

**前提**: Terminal.app が起動していない状態

**手順**:
1. Terminal.app を終了しておく
2. Emacs で任意のファイルを開く（例: `C-x C-f ~/Downloads/test.txt`）
3. `M-x open-term` を実行

**期待結果**:
- Terminal.app が新しいウィンドウで起動する
- 作業ディレクトリが `~/Downloads/` になっている（`pwd` で確認）

---

## シナリオ 2: ファイルバッファ → Terminal.app（起動済み時）

**前提**: Terminal.app がすでに起動している状態

**手順**:
1. Terminal.app を起動しておく
2. Emacs で `~/Documents/notes.org` を開く
3. `M-x open-term` を実行

**期待結果**:
- Terminal.app が新しいウィンドウを開く（v0.1.0 以降: 起動中でも新ウィンドウ）
- 作業ディレクトリが `~/Documents/` になっている

> **注意**: v0.1.0 では Terminal.app は常に新ウィンドウで開きます（新タブ方式は
> Accessibility 権限を必要とするため廃止しました）。

---

## シナリオ 3: Diredバッファからの起動

**手順**:
1. Emacs で `M-x dired RET ~/Projects/ RET`
2. `M-x open-term` を実行

**期待結果**:
- `~/Projects/` でターミナルが開く

---

## シナリオ 4: 非ファイルバッファ（`*scratch*`）からの起動

**手順**:
1. `C-x b *scratch* RET` で scratch バッファに移動
2. `M-x open-term` を実行

**期待結果**:
- ホームディレクトリ `~` でターミナルが開く

---

## シナリオ 5: WezTerm での起動（WezTerm がインストール済みの場合）

**手順**:
1. `M-x open-terminal-setup RET WezTerm RET` で設定
2. WezTerm を起動しておく（新タブのテスト用）
3. 任意のファイルバッファで `M-x open-term` を実行

**期待結果（起動中）**:
- WezTerm に新しいタブが追加され、バッファのディレクトリで開く

**手順（未起動テスト）**:
1. WezTerm を終了しておく
2. `M-x open-term` を実行

**期待結果（未起動）**:
- WezTerm が新しいウィンドウで起動し、バッファのディレクトリで開く

---

## シナリオ 6: Ghostty での起動（Ghostty がインストール済みの場合）

**手順**:
1. `M-x open-terminal-setup RET Ghostty RET` で設定
2. 任意のファイルバッファで `M-x open-term` を実行

**期待結果**:
- Ghostty が新しいウィンドウで起動し、バッファのディレクトリで開く

---

## シナリオ 7: スペースを含むパスでの動作

**手順**:
1. スペースを含むディレクトリで `M-x open-term` を実行
   （例: `~/My Documents/` などの Dired バッファから）

**期待結果**:
- AppleScript エラーなしにターミナルが開き、該当ディレクトリに移動している

---

## シナリオ 8: `open-terminal-setup` の動作確認

**手順**:
1. `M-x open-terminal-setup` を実行
2. 補完候補「Terminal / iTerm2 / WezTerm / Ghostty」が表示されることを確認
3. 任意のターミナルを選択
4. `M-x describe-variable RET open-terminal-app RET` で変数が更新されていることを確認

**期待結果**:
- 選択したターミナル名が `open-terminal-app` に反映されている
- `*Messages*` に "open-terminal-app set to: XXX (add to init.el to persist)" が表示される

---

## テスト結果記録

| シナリオ | 期待結果 | 実際の結果 | 合否 |
|----------|----------|------------|------|
| 1 | 新ウィンドウ + ~/Downloads/ | | |
| 2 | 新ウィンドウ + ~/Documents/ | | |
| 3 | Diredのディレクトリで開く | | |
| 4 | ホームディレクトリで開く | | |
| 5 | WezTerm で開く（タブ/ウィンドウ） | | |
| 6 | Ghostty で開く | | |
| 7 | スペース含むパスで正常動作 | | |
| 8 | setup コマンドで設定変更 | | |
