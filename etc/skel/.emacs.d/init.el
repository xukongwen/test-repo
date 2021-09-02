;;空文的emacs設置

(setq neo-theme (if (display-graphic-p) 'icons 'arrow))
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)


(setq graphic-only-plugins-setting nil)
;; 順滑鼠標
(setq scroll-conservatively 101) ;; move minimum when cursor exits view, instead of recentering
(setq mouse-wheel-scroll-amount '(1)) ;; mouse scroll moves 1 line at a time, instead of 5 lines
(setq mouse-wheel-progressive-speed nil)


;;自定義快捷鍵

;; undo
(global-set-key (kbd "C-/") 'undo)
;; c-> 移動到其他窗口
(global-set-key (kbd "C->") 'other-window)
;; node find， 這個模式是編輯之後繼續
(global-set-key (kbd "s-f") 'org-roam-node-find)
;; node capture, 這個模式就是編輯完畢後就消失
(global-set-key (kbd "s-c") 'org-roam-capture)

;; 切換buffer
(global-set-key (kbd "s-b") 'switch-to-buffer)
;; 搜索當前buffer的所有文本，類似fzf
(global-set-key  "\C-s" 'swiper)
;; 中文字數統計
(global-set-key (kbd "s-w") 'advance-words-count)
;; 退出emacs
(global-set-key (kbd "s-q") 'save-buffers-kill-terminal)

;; 中文字數統計
(defvar words-count-rule-chinese "\\cc"
  "A regexp string to match Chinese characters.")

(defvar words-count-rule-nonespace "[^[:space:]]"
  "A regexp string to match none pace characters.")

(defvar words-count-rule-ansci "[A-Za-z0-9][A-Za-z0-9[:punct:]]*"
  "A regexp string to match none pace characters.")

(defvar words-count-regexp-list
  (list words-count-rule-chinese
        words-count-rule-nonespace
        words-count-rule-ansci)
  "A list for the regexp used in `advance-words-count'.")

(defvar words-count-message-func 'message--words-count
  "The function used to format message in `advance-words-count'.")

(defun special--words-count (start end regexp)
  "Count the word from START to END with REGEXP."
  (let ((count 0))
    (save-excursion
      (save-restriction
        (goto-char start)
        (while (and (< (point) end) (re-search-forward regexp end t))
          (setq count (1+ count)))))
    count))

(defun message--words-count (list start end &optional arg)
  "Display the word count message.
Using the LIST passed form `advance-words-count'. START & END are
required to call extra functions, see `count-lines' &
`count-words'. When ARG is specified, display a verbose buffer."
  (message
   (format
    (if arg
        "
-----------~*~ Words Count ~*~----------
 Word Count .................... %d
 Characters (without Space) .... %d
 Characters (all) .............. %d
 Number of Lines ............... %d
 ANSCII Chars .................. %d
%s
========================================
"
      "總字數:%d,Ns:%d,Al:%d,行數:%d,An:%d,%s")
    (+ (car list) (car (last list)))
    (cadr list)
    (- end start)
    (count-lines start end)
    (car (last list))
    (concat
     (unless (= 0 (car list))
       (format (if arg
                   " Chinese Chars ................. %d\n"
                 "中文:%d,")
               (car list)))
     (format (if arg
                 " English Words ................. %d\n"
               "英文:%d")
             (count-words start end))))))

;;;###autoload
(defun advance-words-count (beg end &optional arg)
  "Chinese user preferred word count.
If BEG = END, count the whole buffer. If called initeractively,
use minibuffer to display the messages. The optional ARG will be
passed to `message--words-count'.

See also `special-words-count'."
  (interactive (if (use-region-p)
                   (list (region-beginning)
                         (region-end)
                         (or current-prefix-arg nil))
                 (list nil nil (or current-prefix-arg nil))))
  (let ((min (or beg (point-min)))
        (max (or end (point-max)))
        list)
    (setq list
          (mapcar
           (lambda (r) (special--words-count min max r))
           words-count-regexp-list))
    (if (called-interactively-p 'any)
        (message--words-count list min max arg)
      list)))



;;字体

;;(setq default-frame-alist '((font . "KKong3-17")))
;;先安裝字體，這個是谷歌的，免費開源的最完美字體
(set-fontset-font t 'han "KKong3")
;;(set-fontset-font t 'han "Source Han Serif SC Regular")
;;其他漢字語系的字體
(set-fontset-font t 'kana "Noto Sans CJK JP Regular")
(set-fontset-font t 'hangul "Noto Sans CJK KR Regular")
(set-fontset-font t 'cjk-misc "Noto Sans CJK KR Regular")


(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")

;; 啓動自動存檔
;; https://github.com/manateelazycat/auto-save.git
(add-to-list 'load-path "~/git/auto-save/")
(require 'auto-save)
(auto-save-enable)
(setq auto-save-silent t)   ; quietly save
(setq auto-save-delete-trailing-whitespace t)

;; 下面是設置插件下載地址和管理
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
	(package-refresh-contents))

(unless (package-installed-p 'use-package)
	(package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)


;; 安裝projectile
(use-package projectile)
(projectile-mode +1)
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
;;(define-key projectile-mode-map (kbd "s-p") 'projectile--find-file)

;; 安裝writeroom
;;(use-package writeroom-mode)
;;(global-writeroom-mode)
;;(setq writeroom-mode 1)

;;安裝jk單行設置
(use-package evil-better-visual-line
  :ensure t
  :config
  (evil-better-visual-line-on))

;;安裝ivy
(use-package ivy
			 	 :diminish
			 	 :config
			 	(ivy-mode 1))
;;安裝doom-modeline
(use-package doom-modeline
			 	 :ensure t
			 	 :init (doom-modeline-mode 1)
			 	 :custom ((doom-modeline-height 17)))

;; orgmode 的一切設置

(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(defun efs/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.4)
                  (org-level-2 . 1.2)
                  (org-level-3 . 1.05)
                  (org-level-4 . 2.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "KKong3" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

;(use-package smooth-scrolling)
;(smooth-scrolling-mode 1)

(use-package org
		:hook (org-mode . efs/org-mode-setup)
		:config
		(setq org-ellipsis " ▾")
		(efs/org-font-setup))

;;此爲快速加入代碼塊
(require 'org-tempo)

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("●" "○" "●" "○" "●" "○" "●")))

(defun efs/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . efs/org-mode-visual-fill))
;; org 裏面打開鏈接直接用回車
(setq org-return-follows-link t)
;; org 打開鏈接直接是本頁
(add-to-list 'org-link-frame-setup '(file . find-file))

;; org-roam设置
(use-package org-roam
      :ensure t
      :custom
      (org-roam-directory (file-truename "~/Dropbox/write/org-roam"))
      :bind (("C-c n l" . org-roam-buffer-toggle)
             ("C-c n f" . org-roam-node-find)
             ("C-c n g" . org-roam-graph)
             ("C-c n i" . org-roam-node-insert)
             ("C-c n c" . org-roam-capture)
             ;; Dailies
             ("C-c n j" . org-roam-dailies-capture-today))
      :config
      (org-roam-setup)
      ;; If using org-roam-protocol
      (require 'org-roam-protocol))


(setq org-roam-v2-ack t)

(setq org-roam-mode-sections
      (list #'org-roam-backlinks-section
            #'org-roam-reflinks-section
            ;; #'org-roam-unlinked-references-section
            ))

;; for org-roam-buffer-toggle
;; Recommendation in the official manual
(add-to-list 'display-buffer-alist
               '(("\\*org-roam\\*"
                  (display-buffer-in-direction)
                  (direction . right)
                  (window-width . 0.33)
                  (window-height . fit-window-to-buffer))))

;; 拖拽添加圖片
(use-package org-download
  :ensure t
  :hook ((org-mode dired-mode) . org-download-enable)
  :config
  (defun +org-download-method (link)
    (org-download--fullname (org-link-unescape link)))
  (setq org-download-method '+org-download-method)

  (setq org-download-annotate-function (lambda (_link) "")
        org-download-method 'attach
        org-download-screenshot-method "screencapture -i %s"))

;; 這個是ivy裏面，把之前使用的命令顯示在最前面，非常實用
(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-c i" . counsel-imenu)
	 :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :config
        (setq ivy-initial-inputs-alist nil)
        (use-package smex)
    )


;;evil mode
(use-package evil)
(evil-mode 1)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("83e0376b5df8d6a3fbdfffb9fb0e8cf41a11799d9471293a810deb7586c131e6" default))
 '(package-selected-packages
   '(fanyi mini-frame smooth-scrolling smex org-roam arbitools writeroom-mode use-package projectile command-log-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )




;;theme設置
(add-to-list 'load-path "~/.emacs.d/nano/")

;; Default layout (optional)
(require 'nano-layout)

;; Theming Command line options (this will cancel warning messages)
(add-to-list 'command-switch-alist '("-dark"   . (lambda (args))))
(add-to-list 'command-switch-alist '("-light"  . (lambda (args))))
(add-to-list 'command-switch-alist '("-default"  . (lambda (args))))
(add-to-list 'command-switch-alist '("-no-splash" . (lambda (args))))
(add-to-list 'command-switch-alist '("-no-help" . (lambda (args))))
(add-to-list 'command-switch-alist '("-compact" . (lambda (args))))


(cond
 ((member "-default" command-line-args) t)
 ((member "-light" command-line-args) (require 'nano-theme-dark))
 (t (require 'nano-theme-dark)))


;; Theme
(require 'nano-faces)
(nano-faces)

(require 'nano-theme)
(nano-theme)

;; Nano default settings (optional)
(require 'nano-defaults)

;; Nano session saving (optional)
(require 'nano-session)

;; Nano header & mode lines (optional)
(require 'nano-modeline)

;; Nano key bindings modification (optional)
(require 'nano-bindings)

(require 'nano-writer)

;;(require 'nano-minibuffer)
;; Compact layout (need to be loaded after nano-modeline)
(when (member "-compact" command-line-args)
  (require 'nano-compact))

;; Nano counsel configuration (optional)
;; Needs "counsel" package to be installed (M-x: package-install)
;; (require 'nano-counsel)

;; Welcome message (optional)
(let ((inhibit-message t))
  (message "Welcome to 空文")
  (message (format "初始化時間: %s" (emacs-init-time))))

;; Splash (optional)
(unless (member "-no-splash" command-line-args)
  (require 'nano-splash))

;; Help (optional)
(unless (member "-no-help" command-line-args)
  (require 'nano-help))

(provide 'nano)

(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar

;;中文rime輸入
(use-package posframe)
(use-package rime)
;;这里把rime的设置文件指定好，fcitx5的目录就是在这里，简体就在这个目录里设置
(setq rime-user-data-dir "~/Dropbox/rime-data/")
(setq rime-posframe-properties
      (list :background-color "#333333"
            :foreground-color "#dcdccc"
            :font "KKong3-17"
            :internal-border-width 5))

(setq default-input-method "rime"
      rime-show-candidate 'posframe)

(setq rime-disable-predicates
      '(rime-predicate-evil-mode-p
        rime-predicate-after-alphabet-char-p
        rime-predicate-prog-in-code-p))


;;; support shift-l, shift-r, control-l, control-r
(setq rime-inline-ascii-trigger 'shift-l)

;; writeroom
(use-package writeroom-mode)
(global-writeroom-mode)
(setq writeroom-mode 1)

;;设置code block颜色
(require 'color)
(set-face-attribute 'org-block nil :background
                    (color-darken-name
                     (face-attribute 'default :background) 3))

(setq org-src-block-face '(("emacs-lisp" (:background "white"))))

(use-package mini-frame)
;;一个比较详细的翻译功能
(use-package fanyi)


;;两个翻译功能
(require 'sdcv)
(setq sdcv-say-word-p t)               ;say word after translation

(setq sdcv-dictionary-data-dir "/usr/share/stardict/dic") ;把下载的字典放在这里

(setq sdcv-dictionary-simple-list    ;setup dictionary list for simple search
      '("懒虫简明英汉词典"
        "懒虫简明汉英词典"))

(setq sdcv-dictionary-complete-list     ;setup dictionary list for complete search
      '(
        "懒虫简明英汉词典"
        "懒虫简明汉英词典"
        ))
;;把一句中文直接转化成英文
(require 'insert-translated-name)
