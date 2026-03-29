# Unit Test Instructions: open-terminal

## テスト方針
open-terminal は macOS 固有の AppleScript / シェルコマンドを呼び出すため、
自動テストは純粋な Emacs Lisp 関数（ディレクトリ解決・パスエスケープ）に絞り、
ターミナル起動系は手動テストで確認します。

---

## 自動テスト（ERT）

### テストファイルのロード

Emacs で以下を実行してテストを走らせます：

```elisp
(require 'ert)
(require 'open-terminal)

;; --- open-terminal--get-directory のテスト ---

(ert-deftest test-get-directory/file-buffer ()
  "ファイルバッファではファイルのディレクトリを返す。"
  (with-temp-buffer
    (setq buffer-file-name "/tmp/test/foo.txt")
    (should (equal (open-terminal--get-directory) "/tmp/test/"))))

(ert-deftest test-get-directory/no-file-buffer ()
  "非ファイルバッファではホームディレクトリを返す。"
  (with-temp-buffer
    (setq buffer-file-name nil)
    (should (equal (open-terminal--get-directory) (expand-file-name "~")))))

(ert-deftest test-get-directory/dired-buffer ()
  "Diredバッファでは default-directory を返す。"
  (let ((test-dir (expand-file-name "~/Downloads/")))
    (with-temp-buffer
      (setq default-directory test-dir)
      (dired-mode)
      (should (equal (open-terminal--get-directory)
                     (expand-file-name test-dir))))))

;; --- open-terminal--applescript-escape-path のテスト ---

(ert-deftest test-applescript-escape-path/simple ()
  "シングルクォートを含まない通常のパスはそのままシングルクォートで囲まれる。"
  (should (equal (open-terminal--applescript-escape-path "/Users/kai/project/")
                 "'/Users/kai/project/'")))

(ert-deftest test-applescript-escape-path/with-spaces ()
  "スペースを含むパスは正しくシングルクォートで囲まれる。"
  (should (equal (open-terminal--applescript-escape-path "/Users/kai/my project/")
                 "'/Users/kai/my project/'")))

(ert-deftest test-applescript-escape-path/with-single-quote ()
  "シングルクォートを含むパスは '\\'' に正しくエスケープされる。"
  (should (equal (open-terminal--applescript-escape-path "/Users/kai/it's/")
                 "'/Users/kai/it'\\''s/'")))

;; テスト実行
(ert-run-tests-batch-and-exit "test-get-directory/.*\\|test-applescript-escape-path/.*")
```

### コマンドラインでの実行

```bash
emacs -Q --batch \
  --eval "(add-to-list 'load-path \"/path/to/open-terminal\")" \
  --eval "(require 'open-terminal)" \
  --eval "(require 'ert)" \
  --eval "
(ert-deftest test-get-directory/file-buffer ()
  (with-temp-buffer
    (setq buffer-file-name \"/tmp/test/foo.txt\")
    (should (equal (open-terminal--get-directory) \"/tmp/test/\"))))

(ert-deftest test-get-directory/no-file ()
  (with-temp-buffer
    (setq buffer-file-name nil)
    (should (equal (open-terminal--get-directory) (expand-file-name \"~\")))))

(ert-deftest test-applescript-escape-path/simple ()
  (should (equal (open-terminal--applescript-escape-path \"/tmp/test/\")
                 \"'/tmp/test/'\")))

(ert-deftest test-applescript-escape-path/single-quote ()
  (should (equal (open-terminal--applescript-escape-path \"/tmp/it's/\")
                 \"'/tmp/it'\\\\''s/'\")))
" \
  --eval "(ert-run-tests-batch-and-exit)"
```

### 期待される出力
```
Running 4 tests (2026-03-29 ...)
   passed  test-get-directory/file-buffer
   passed  test-get-directory/no-file
   passed  test-applescript-escape-path/simple
   passed  test-applescript-escape-path/single-quote

Ran 4 tests, 4 results as expected
```

---

## `open-terminal--running-p` のスモークテスト

```elisp
;; Emacs 自身は必ず起動中 → t を返すはず
(open-terminal--running-p "Emacs")   ; => non-nil

;; 存在しないプロセス → nil を返すはず
(open-terminal--running-p "NonExistentApp12345")  ; => nil
```

`*scratch*` バッファで `C-x C-e` で評価して結果を確認します。
