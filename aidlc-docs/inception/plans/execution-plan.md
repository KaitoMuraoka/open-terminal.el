# Execution Plan: open-terminal Emacs Plugin（修正・拡張セッション）

## Detailed Analysis Summary

### Transformation Scope
- **Transformation Type**: Single component（単一ファイル修正）
- **Primary Changes**: `open-terminal.el` のバグ修正 + 機能拡張
- **Related Components**: なし（外部依存ライブラリなし）

### Change Impact Assessment
- **User-facing changes**: Yes — ①Terminal.appバグ修正、②WezTerm/Ghostty対応追加、③新コマンド2件追加
- **Structural changes**: No — 単一ファイルの修正のみ
- **Data model changes**: No
- **API changes**: No（既存コマンド `open-term` の動作は維持）
- **NFR impact**: No

### Risk Assessment
- **Risk Level**: Low
- **Rollback Complexity**: Easy（前バージョンの `open-terminal.el` に戻すだけ）
- **Testing Complexity**: Simple（手動でコマンド呼び出しを確認）

---

## Workflow Visualization

```
INCEPTION PHASE
+------------------------+--------+
| Workspace Detection    | DONE   |
| Reverse Engineering    | DONE   |
| Requirements Analysis  | DONE   |
| User Stories           | SKIP   |
| Workflow Planning      | DONE   |
| Application Design     | SKIP   |
| Units Generation       | SKIP   |
+------------------------+--------+

CONSTRUCTION PHASE
+------------------------+--------+
| Functional Design      | SKIP   |
| NFR Requirements       | SKIP   |
| NFR Design             | SKIP   |
| Infrastructure Design  | SKIP   |
| Code Generation        | EXECUTE|
| Build and Test         | EXECUTE|
+------------------------+--------+

OPERATIONS PHASE
+------------------------+-------------+
| Operations             | PLACEHOLDER |
+------------------------+-------------+
```

---

## Phases to Execute

### INCEPTION PHASE
- [x] Workspace Detection (COMPLETED)
- [x] Reverse Engineering (COMPLETED - artifacts exist)
- [x] Requirements Analysis (COMPLETED)
- [-] User Stories (SKIP)
  - **Rationale**: 単一ユーザー・単一コマンドのシンプルなプラグイン
- [x] Workflow Planning (COMPLETED)
- [-] Application Design (SKIP)
  - **Rationale**: 既存コンポーネント内の変更のみ、新コンポーネントなし
- [-] Units Generation (SKIP)
  - **Rationale**: 単一ユニット（1ファイル）のみ

### CONSTRUCTION PHASE
- [-] Functional Design (SKIP)
  - **Rationale**: ロジックがシンプル、要件から実装が自明
- [-] NFR Requirements (SKIP)
  - **Rationale**: ローカルプラグイン、NFR懸念なし
- [-] NFR Design (SKIP)
- [-] Infrastructure Design (SKIP)
  - **Rationale**: クラウドインフラなし
- [ ] Code Generation (EXECUTE - ALWAYS)
  - **Rationale**: `open-terminal.el` のバグ修正 + 機能拡張実装
- [ ] Build and Test (EXECUTE - ALWAYS)
  - **Rationale**: テスト手順の更新

### OPERATIONS PHASE
- [ ] Operations (PLACEHOLDER)

---

## Code Generation - 変更内容サマリー

| # | 変更種別 | 内容 |
|---|---|---|
| 1 | Bug Fix | `open-terminal--applescript-quote` ヘルパー追加（AppleScript向けパスエスケープ） |
| 2 | Bug Fix | Terminal.app の `do script` と `activate` の順序修正 |
| 3 | Bug Fix | 新タブ AppleScript を `selected tab of front window` ベースに改善 |
| 4 | Enhancement | `open-terminal--open-wezterm` 関数追加（wezterm CLI使用） |
| 5 | Enhancement | `open-terminal--open-ghostty` 関数追加（ghostty CLI使用） |
| 6 | Enhancement | `open-term` の `pcase` に "WezTerm" / "Ghostty" ブランチ追加 |
| 7 | Enhancement | `open-terminal-diagnose` コマンド追加 |
| 8 | Enhancement | `open-terminal-setup` コマンド追加 |
| 9 | Enhancement | Commentary に init.el / use-package 設定例を追加 |

---

## Success Criteria
- **Primary Goal**: バグなしで `M-x open-term` が全バッファタイプで動作する
- **Key Deliverables**:
  - `open-terminal.el`（修正・拡張版）
  - 更新された `build-and-test/` ドキュメント
- **Quality Gates**:
  - Terminal.app で AppleScript エラーなしに起動
  - WezTerm / Ghostty で正しいディレクトリに起動
  - `M-x open-terminal-diagnose` が正しく情報を表示
  - `M-x open-terminal-setup` で設定が変更できる
