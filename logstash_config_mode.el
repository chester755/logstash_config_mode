;; ;;; Allows the user to run their own code when your mode is run.
;; ;;(defvar logstash-config-mode-hook nil)

;; ;;; Created a keymap
;; (defvar logstash-config-mode-map
;; 	(let ((map (make-keymap)))
;; 		(define-key map "\C-j" 'newline-and-indent)
;; 		map)
;; 	"Keymap for logstash-config major mode")

;; ;;; Add auto load mode to the .conf file 
;; (add-to-list 'auto-mode-alist '("\\.conf'" . logstash-config-mode))

;; ;;; Syntax highlight
;; (defconst logstash-config-font-lock-keywords-1
;; 	(list
;; 	 '("\\<\\(add_\\(?:field\\|tag\\)\\|break_on_match\\|enable_metric\\|grok\\|i[df]\\|keep_empty_captures\\|match\\|named_captures_only\\|overwrite\\|p\\(?:atterns_\\(?:dir\\|\files_glob\\)\\|eriodic_flush\\)\\|remove_\\(?:field\\|tag\\)\\|tag_on_\\(?:failure\\|timeout\\)\\)\\>" . font-lock-builtin-face))
;; 	"highlight expression for logstash grok, will need to add more in the future")

;; (defun logstash-config-mode-indent-line ()
;; 	"Indent current line as logstash config code"
;; 	(interactive)
;; 	(beginning-of-line)
;; 	(if (bobp)  ; Check for rule 1
;; 			(indent-line-to 0)
;; 		(let ((not-indented t) cur-indent)
	

;; ;;; The regexp-opt generate correct regexp for higlight
;; ;;(regexp-opt '("if" "grok" "match" "break_on_match" "keep_empty_captures" "overwrite" "named_captures_only" "patterns_dir" "patterns_files_glob" "tag_on_failure" "tag_on_timeout" "add_field" "add_tag" "enable_metric" "id" "periodic_flush" "remove_field" "remove_tag") t)

;;;; Now use derived approach, as it is much easier.

(eval-when-compile
  (require 'cl-lib))
(eval-when-compile
  (require 'cc-mode))
(eval-when-compile
  (require 'js))

(defvar logstash-config-keywords
	'("if"
		;;"grok" "match" "break_on_match" "keep_empty_captures" "overwrite" "named_captures_only" "patterns_dir" "patterns_files_glob" "tag_on_failure" "tag_on_timeout" "add_field" "add_tag" "enable_metric" "id" "periodic_flush" "remove_field" "remove_tag"
		))

;;;; Now defined variable
(defvar logstash-config-constants
	'("grok" "match" "break_on_match" "keep_empty_captures" "overwrite" "named_captures_only" "patterns_dir" "patterns_files_glob" "tag_on_failure" "tag_on_timeout" "add_field" "add_tag" "enable_metric" "id" "periodic_flush" "remove_field" "remove_tag"))

;;;; tab width for this mode
(defvar logstash-config-tab-width 2)

(defcustom logstash-indent 2
  "indent-offset"
  :type 'integer)

;; Confirmed work and fast, nicked it from js-indent-line function but I think I would need to modify it. 
(defun logstash-indent-line ()
  "Indent the current line as JavaScript."
  (interactive)
  (let* ((parse-status
          (save-excursion (syntax-ppss (point-at-bol))))
         (offset (- (point) (save-excursion (back-to-indentation) (point)))))
    (unless (nth 3 parse-status)
      (indent-line-to (js--proper-indentation parse-status))
      (when (> offset 0) (forward-char offset)))))

;; Now borrowed the c-comment-indent from the tex-mode as it's very similar
(defun py--comment-indent-function ()
  "Python version of `comment-indent-function'."
  ;; This is required when filladapt is turned off.  Without it, when
  ;; filladapt is not used, comments which start in column zero
  ;; cascade one character to the right
  (save-excursion
    (beginning-of-line)
    (let ((eol (line-end-position)))
      (and comment-start-skip
           (re-search-forward comment-start-skip eol t)
           (setq eol (match-beginning 0)))
      (goto-char eol)
      (skip-chars-backward " \t")
            (max comment-column (+ (current-column) (if (bolp) 0 1))))))

;;;; set the face lock
(defvar logstash-config-font-lock-defaults
	`((("\"\\.\\*\\?" . font-lock-string-face)
		 (":\\|,\\|;\\|{\\|}\\|=>\\|@\\|$\\|=\\|(\\|)" . font-lock-keyword-face)
		 ( ,(regexp-opt logstash-config-keywords 'words) . font-lock-builtin-face)
		 ( ,(regexp-opt logstash-config-keywords 'words) . font-lock-constant-face))))


(define-derived-mode logstash-config-mode fundamental-mode "logstash config mode"
	"This is mean to be a lightweight major mode for editing logstash config file derived from fundatmental model"
	(setq font-lock-defaults logstash-config-font-lock-defaults)
																				;(when logstash-config-tab-width
																				;	(setq tab-width logstash-config-tab-width))
	;;(local-set-key (kbd "TAB") 'dabbrev-expand);;'indent-code-rigidly)  
	;l(setq-default comment-start "#")
	;(setq-default comment-end "\n")    
  (setq-local comment-start "# ")
  (setq-local comment-start-skip "\\(#+\\|/\\*+\\)\\s *")
  (setq-local comment-end "")
  (setq c-block-comment-prefix "* "
        c-comment-prefix-regexp "#+\\|\\**")  
  (setq comment-indent-function 'py--comment-indent-function)  
	(setq indent-line-function 'logstash-indent-line)
  (eval-after-load 'folding
    '(when (fboundp 'folding-add-to-marks-list)
       (folding-add-to-marks-list 'logstash-config-mode "# {{{" "# }}}" )))
  
	;(setq-default comment-start "#")
	;(setq-default comment-end "\n")  
  (setq-default indent-tabs-mode nil)	
	(setq-default tab-always-indent t)
	
	)

(provide 'logstash-config-mode)
