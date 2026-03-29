;;; open-terminal-test.el --- ERT tests for open-terminal.el -*- lexical-binding: t; -*-

;;; Commentary:
;; Run with:
;;   emacs -batch -l open-terminal.el -l open-terminal-test.el -f ert-run-tests-batch-and-exit

;;; Code:

(require 'ert)
(require 'open-terminal)

;;; ---------------------------------------------------------------
;;; open-terminal--applescript-escape-path
;;; ---------------------------------------------------------------

(ert-deftest open-terminal-test--applescript-escape-path/simple ()
  "Simple path is wrapped in single quotes without modification."
  (should (equal "'/Users/kai/projects/'"
                 (open-terminal--applescript-escape-path "/Users/kai/projects/"))))

(ert-deftest open-terminal-test--applescript-escape-path/single-quote ()
  "Single quote inside path is escaped as \\='\\=''."
  (should (equal "'/Users/kai/it'\\''s/'"
                 (open-terminal--applescript-escape-path "/Users/kai/it's/"))))

(ert-deftest open-terminal-test--applescript-escape-path/multiple-single-quotes ()
  "Multiple single quotes are each escaped independently."
  (should (equal "'/Users/a'\\''b'\\''c/'"
                 (open-terminal--applescript-escape-path "/Users/a'b'c/"))))

(ert-deftest open-terminal-test--applescript-escape-path/home-dir ()
  "Home directory path is handled correctly."
  (let ((home (expand-file-name "~")))
    (should (string-prefix-p "'" (open-terminal--applescript-escape-path home)))
    (should (string-suffix-p "'" (open-terminal--applescript-escape-path home)))))

(ert-deftest open-terminal-test--applescript-escape-path/empty-string ()
  "Empty string becomes a pair of single quotes."
  (should (equal "''" (open-terminal--applescript-escape-path ""))))

;;; ---------------------------------------------------------------
;;; open-terminal--get-directory
;;; ---------------------------------------------------------------

(ert-deftest open-terminal-test--get-directory/file-buffer ()
  "File buffer returns the directory containing the visited file."
  (let ((tmpfile (make-temp-file "open-terminal-test")))
    (unwind-protect
        (with-current-buffer (find-file-noselect tmpfile)
          (unwind-protect
              (should (equal (file-name-directory (expand-file-name tmpfile))
                             (open-terminal--get-directory)))
            (kill-buffer (current-buffer))))
      (delete-file tmpfile))))

(ert-deftest open-terminal-test--get-directory/dired-buffer ()
  "Dired buffer returns the directory Dired is displaying."
  (let* ((tmpdir (make-temp-file "open-terminal-test-dir" t))
         (buf (dired-noselect tmpdir)))
    (unwind-protect
        (with-current-buffer buf
          (should (equal (expand-file-name (file-name-as-directory tmpdir))
                         (open-terminal--get-directory))))
      (kill-buffer buf)
      (delete-directory tmpdir t))))

(ert-deftest open-terminal-test--get-directory/scratch-buffer ()
  "Non-file, non-dired buffer falls back to home directory."
  (with-temp-buffer
    (should (equal (expand-file-name "~")
                   (open-terminal--get-directory)))))

;;; ---------------------------------------------------------------
;;; open-terminal--open-* dispatch via open-term
;;; ---------------------------------------------------------------

(defmacro open-terminal-test--with-mock-dispatch (&rest body)
  "Execute BODY with all open-terminal--open-* functions replaced by recorders.
Each function records its arguments into `open-terminal-test--calls'."
  (declare (indent 0))
  `(let ((open-terminal-test--calls nil))
     (cl-letf (((symbol-function 'open-terminal--open-terminal-app)
                (lambda (dir)
                  (push (list 'terminal-app dir) open-terminal-test--calls)))
               ((symbol-function 'open-terminal--open-iterm2)
                (lambda (dir)
                  (push (list 'iterm2 dir) open-terminal-test--calls)))
               ((symbol-function 'open-terminal--open-wezterm)
                (lambda (dir)
                  (push (list 'wezterm dir) open-terminal-test--calls)))
               ((symbol-function 'open-terminal--open-ghostty)
                (lambda (dir)
                  (push (list 'ghostty dir) open-terminal-test--calls)))
               ((symbol-function 'open-terminal--open-generic)
                (lambda (app dir)
                  (push (list 'generic app dir) open-terminal-test--calls)))
               ((symbol-function 'open-terminal--get-directory)
                (lambda () "/tmp/test-dir/")))
       ,@body)))

(ert-deftest open-terminal-test--open-term/dispatches-terminal ()
  "open-term calls open-terminal--open-terminal-app for \"Terminal\"."
  (open-terminal-test--with-mock-dispatch
    (let ((open-terminal-app "Terminal"))
      (open-term)
      (should (equal '((terminal-app "/tmp/test-dir/")) open-terminal-test--calls)))))

(ert-deftest open-terminal-test--open-term/dispatches-iterm2 ()
  "open-term calls open-terminal--open-iterm2 for \"iTerm2\"."
  (open-terminal-test--with-mock-dispatch
    (let ((open-terminal-app "iTerm2"))
      (open-term)
      (should (equal '((iterm2 "/tmp/test-dir/")) open-terminal-test--calls)))))

(ert-deftest open-terminal-test--open-term/dispatches-wezterm ()
  "open-term calls open-terminal--open-wezterm for \"WezTerm\"."
  (open-terminal-test--with-mock-dispatch
    (let ((open-terminal-app "WezTerm"))
      (open-term)
      (should (equal '((wezterm "/tmp/test-dir/")) open-terminal-test--calls)))))

(ert-deftest open-terminal-test--open-term/dispatches-ghostty ()
  "open-term calls open-terminal--open-ghostty for \"Ghostty\"."
  (open-terminal-test--with-mock-dispatch
    (let ((open-terminal-app "Ghostty"))
      (open-term)
      (should (equal '((ghostty "/tmp/test-dir/")) open-terminal-test--calls)))))

(ert-deftest open-terminal-test--open-term/dispatches-generic-fallback ()
  "open-term calls open-terminal--open-generic for unknown terminal names."
  (open-terminal-test--with-mock-dispatch
    (let ((open-terminal-app "Alacritty"))
      (open-term)
      (should (equal '((generic "Alacritty" "/tmp/test-dir/")) open-terminal-test--calls)))))

;;; ---------------------------------------------------------------
;;; open-terminal-setup
;;; ---------------------------------------------------------------

(ert-deftest open-terminal-test--setup/sets-app ()
  "open-terminal-setup sets open-terminal-app to the chosen value."
  (cl-letf (((symbol-function 'completing-read)
             (lambda (_prompt _collection &rest _) "WezTerm"))
            ((symbol-function 'customize-set-variable)
             (lambda (sym val) (set sym val))))
    (let ((open-terminal-app "Terminal"))
      (open-terminal-setup)
      (should (equal "WezTerm" open-terminal-app)))))

(ert-deftest open-terminal-test--setup/preserves-current-as-default ()
  "open-terminal-setup passes the current value as the default to completing-read."
  (let (captured-default)
    (cl-letf (((symbol-function 'completing-read)
               (lambda (_prompt _collection _pred _req _init _hist default)
                 (setq captured-default default)
                 default))
              ((symbol-function 'customize-set-variable)
               (lambda (_sym _val) nil)))
      (let ((open-terminal-app "Ghostty"))
        (open-terminal-setup)
        (should (equal "Ghostty" captured-default))))))

;;; ---------------------------------------------------------------
;;; Customization / defcustom defaults
;;; ---------------------------------------------------------------

(ert-deftest open-terminal-test--default-app ()
  "open-terminal-app defaults to \"Terminal\"."
  ;; Only meaningful on a fresh load; check the standard value.
  (should (equal "Terminal"
                 (eval (car (get 'open-terminal-app 'standard-value))))))

(ert-deftest open-terminal-test--supported-apps-list ()
  "open-terminal--supported-apps contains all four documented terminals."
  (dolist (app '("Terminal" "iTerm2" "WezTerm" "Ghostty"))
    (should (member app open-terminal--supported-apps))))

(provide 'open-terminal-test)
;;; open-terminal-test.el ends here
