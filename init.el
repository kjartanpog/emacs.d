;; -*- lexical-binding: t; -*-

;;; | Package initialization

(require 'package)


(setq package-archives '(("melpa"        . "https://melpa.org/packages/")
                         ("gnu"          . "https://elpa.gnu.org/packages/")
                         ("nongnu"       . "https://elpa.nongnu.org/nongnu/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")))
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(require 'use-package)

;;; | Early init

(set-fringe-mode 8)


;;; | Frame size

;; (let* ((phi 0.618)
;;        (display-w (display-pixel-width))
;;        (display-h (display-pixel-height))
;;        (frame-w (floor (* phi display-w)))
;;        (frame-h (floor (* phi display-h)))
;;        (left (/ (- display-w frame-w) 2))
;;        (top (/ (- display-h frame-h) 2)))
;;   (add-to-list 'default-frame-alist `(width . (text-pixels . ,frame-w)))
;;   (add-to-list 'default-frame-alist `(height . (text-pixels . ,frame-h)))
;;   (set-frame-size (selected-frame) frame-w frame-h t)
;;   (set-frame-position (selected-frame) left top))

;;; ├────── Better Defaults
;;; | General

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(setq-default buffer-file-coding-system 'utf-8)
;; (setq inhibit-startup-message t)
(setq ring-bell-function 'ignore)
(setq-default truncate-lines t)
(setq delete-by-moving-to-trash t)
(setq use-short-answers t)
(context-menu-mode t)
(delete-selection-mode t)
(global-auto-revert-mode t)

;;; | Editing

(use-package simple
  :ensure nil
  :bind
  (("M-J" . duplicate-dwim)
   ([remap capitalize-word] . capitalize-dwim)       ; Make M-c work on regions
   ([remap downcase-word] . downcase-dwim)           ; Make M-l work on regions
   ([remap upcase-word] . upcase-dwim)               ; Make M-u work on regions
   ([remap kill-buffer] . kill-current-buffer)       ; C-x k stops prompting for buffer to kill
   ))

;;; ├────── Stuff
;;; | History, backups, customization

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(use-package savehist
  :init
  (savehist-mode))

(use-package recentf
  :init
  (recentf-mode t))

(use-package winner
  :init
  (winner-mode t))

(use-package repeat
  :init
  (repeat-mode t))

(use-package saveplace
  :init
  (save-place-mode t))

;;; | Minibuffer

(use-package vertico
  :ensure t
  :custom
  ;; (vertico-scroll-margin 0) ;; Different scroll margin
  ;; (vertico-count 20) ;; Show more candidates
  ;; (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :init
  (vertico-mode))

(use-package vertico-mouse
  :after vertico
  :init
  (vertico-mouse-mode))

(use-package vertico-directory
  :after vertico
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package marginalia
  :ensure t
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

;;; | Completions

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil)
  (completion-pcm-leading-wildcard t))

(use-package corfu
  :ensure t
  :custom
  (corfu-cycle t)
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match 'insert) ;; Configure handling of exact matches

  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode))

(use-package cape
  :disabled t
  :ensure t
  :after corfu
  :config
  (add-to-list 'completion-at-point-functions #'cape-abbrev))

(use-package emacs
  :custom
  (tab-always-indent 'complete)
  (read-extended-command-predicate #'command-completion-default-include-p))

;;; | Line numbers

(use-package display-line-numbers
  :custom
  ;; (display-line-numbers-type 'relative)
  (display-line-numbers-width-start 3)
  :hook (prog-mode-hook . display-line-numbers-mode))

;;; | Auto indent, layout, quotes

(use-package electric
  :config
  (setq-default electric-pair-inhibit-predicate
              #'electric-pair-conservative-inhibit)
  :hook
  (prog-mode-hook . electric-layout-mode)
  (prog-mode-hook . electric-pair-mode)
  ;; (prog-mode-hook . electric-quote-local-mode-hook)
  )

;;; | Projects

(use-package project
  ;; :defer t
  :config
  (defun my/project-ignore-nix-store (dir)
    "Ignore /nix/store in project detection."
    (string-match-p "^/nix/store" dir))
  (add-to-list 'project-find-functions #'my/project-ignore-nix-store)
  (setq project-mode-line t))

;;; | Navigation, folding

(use-package consult
  :ensure t
  ;; Replace bindings. Lazily loaded by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ;; ("C-c h" . consult-history)
         ;; ("C-c k" . consult-kmacro)
         ;; ("C-c m" . consult-man)
         ;; ("C-c i" . consult-info)
         ;; ([remap Info-search] . consult-info)

         ;; C-x bindings in `ctl-x-map'
         ;; ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ;; ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ;; ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ;; ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ;; ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ;; ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ;; ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer

         ;; Custom M-# bindings for fast register access
         ;; ("M-#" . consult-register-load)
         ;; ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ;; ("C-M-#" . consult-register)

         ;; Other custom bindings
         ;; ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ;; ("M-g e" . consult-compile-error)
         ;; ("M-g r" . consult-grep-match)
         ;; ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ;; ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ;; ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ;; ("M-g m" . consult-mark)
         ;; ("M-g k" . consult-global-mark)
         ;; ("M-g i" . consult-imenu)
         ;; ("M-g I" . consult-imenu-multi)

         ;; M-s bindings in `search-map'
         ;; ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ;; ("M-s c" . consult-locate)
         ;; ("M-s g" . consult-grep)
         ;; ("M-s G" . consult-git-grep)
         ;; ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ;; ("M-s L" . consult-line-multi)
         ;; ("M-s k" . consult-keep-lines)
         ;; ("M-s u" . consult-focus-lines)

         ;; Isearch integration
         ;; ("M-s e" . consult-isearch-history)
         ;; :map isearch-mode-map
         ;; ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ;; ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ;; ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ;; ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch

         ;; Minibuffer history
         ;; :map minibuffer-local-map
         ;; ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ;; ("M-r" . consult-history))                ;; orig. previous-matching-history-element
         )
  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)
  )


(use-package outline
  ;; :disabled t
  :custom
  (outline-minor-mode-prefix (kbd "C-c C-o"))
  (outline-minor-mode-cycle t)
  (outline-minor-mode-use-buttons t)
  :init
  (defun my/elisp-outline-minor-mode-setup ()
    (setq-local outline-regexp "^;;;+")
    (outline-minor-mode t)
    (when (and (buffer-file-name)
               (string-match-p "init\\.el\\'" (buffer-file-name)))
      (outline-hide-sublevels 1))
    )
  :hook
  (emacs-lisp-mode . my/elisp-outline-minor-mode-setup)
  )

;;; | Indentation

(use-package simple
  :config
  (setq-default indent-tabs-mode nil))

;;; | Helpful infomation

(use-package which-key
  :init
  (which-key-mode t))

;;; | Theme

(use-package modus-themes
  :ensure t
  :config
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-mixed-fonts t)
  (setq modus-themes-headings
        '((1 . (variable-pitch 1.5))
          (2 . (1.3))
          (agenda-date . (1.3))
          (agenda-structure . (variable-pitch light 1.8))
          (t . (1.1))))
(let ((overrides '(;; Region
                   (bg-region bg-ochre)
                   (fg-region unspecified)
                   ;; Headings
                   (fg-heading-1 cyan))))
  (setq modus-operandi-palette-overrides overrides
        modus-vivendi-palette-overrides overrides))
  (modus-themes-include-derivatives-mode t)
  (modus-themes-load-theme 'modus-operandi))

(use-package standard-themes
  :ensure t)

;;; | UI

(use-package emacs
  :disabled t
  :config
  (tool-bar-mode -1))

(use-package emacs
  :disabled t
  :config
  (if (eq system-type 'gnu/linux)
      (setq x-gtk-stock-map nil
            tool-bar-style 'image))
  (set-window-scroll-bars (minibuffer-window) nil nil nil nil 1)
  (set-window-parameter (get-buffer-window "*Messages*") 'vertical-scroll-bars nil))

;;; | Nix

(use-package nix-ts-mode
  :ensure t
  :mode "\\.nix\\'"
  :init
  (defun my/nix-ts-mode-setup ()
    (setq-local treesit-font-lock-level 4))
  :hook
  (nix-ts-mode . my/nix-ts-mode-setup))

;;; | Abbreviations

(use-package abbrev
  :ensure nil  ;; built-in
  :custom
  (save-abbrevs nil)
  :config
  ;; (setq-default abbrev-mode t)

  (define-abbrev-table 'global-abbrev-table
    '(("today" ""
       (lambda ()
         (insert (format-time-string "%Y-%m-%d")))
       ))))

;;; ├────── Org Mode
;;; | org

(use-package org
  :defer t
  :hook (org-mode . auto-fill-mode)
  :config
  (setq org-hide-leading-stars t
        org-list-allow-alphabetical t))

;;; | org-mouse

(use-package org-mouse
  :after org)

;;; | ox-reveal

(use-package ox-reveal
  :after org
  :ensure t
  :config
  (setq org-reveal-root "https://cdn.jsdelivr.net/npm/reveal.js")
  )

;;; | org-download

(use-package org-download
  :ensure t
  :after org
  :config
  (add-hook 'org-mode-hook 'org-download-enable))

;;; | org-roam

(use-package org-roam
  :ensure t
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ;; Dailies
         ("C-c n j" . org-roam-dailies-capture-today))
  :custom
  (org-roam-directory (expand-file-name "org-roam" user-emacs-directory))
  :config
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode t)
  (add-to-list 'org-roam-capture-templates
             '("s" "skilgreining" plain
               "\n* Skilgreining\n\n%?\n\n* Heimildir\n"
               :if-new
               (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                          "#+title: ${title}\n\n")
               :unnarrowed t)))

(use-package org-roam-ui
  :after org-roam
  :ensure t
  :config
  (setq org-roam-ui-sync-theme t
          org-roam-ui-follow t
          org-roam-ui-update-on-save t
          org-roam-ui-open-on-start t))

;;; ├────── Version Control

;;; | Emacs vc

(use-package vc
  :ensure nil
  :defer t
  :config
  (setq vc-follow-symlinks t))

;;; | Gutter Indicators

(use-package diff-hl
  :ensure t
  :config
  (global-diff-hl-mode t)
  )

;;; ├────── Tree-sitter

;;; | Folding

(use-package treesit-fold
  :ensure t
  :vc (:url "https://github.com/emacs-tree-sitter/treesit-fold"
       :rev :newest))

;;; ├────── General Emacs Config
;;; | Additional keymaps

(use-package emacs
  :ensure nil
  :bind
  (("M-o" . other-window)
   ("M-g r" . recentf)
   ("C-x C-b" . ibuffer)
   ("C-þ" . undo)
   ))

;; (defun insert-buffer-name-ignoring-minibuffer ()
;;   "Gets the name of the buffer that was current before the minibuffer
;;   was activated and inserts it at point."
;;   (interactive)
;;   (insert (buffer-name (window-buffer (minibuffer-selected-window)))))
;; (global-set-key (kbd "C-c b n") #'insert-buffer-name-ignoring-minibuffer)

;; (defun insert-current-iso-date ()
;;   "Insert the current date in ISO format (YYYY-MM-DD)."
;;   (interactive)
;;   (insert (format-time-string "%Y-%m-%d")))
;; (global-set-key (kbd "C-c d") 'insert-current-iso-date)

;;; | Load additional files

(load custom-file)
;; (let ((f (expand-file-name "early-local.el" user-emacs-directory)))
;;   (if (file-exists-p f)
;;       (load f)))
;; (let ((f (expand-file-name "local.el" user-emacs-directory)))
;;   (if (file-exists-p f)
;;       (load f)))
(dolist (file '("early-local.el" "local.el"))
  (let ((path (expand-file-name file user-emacs-directory)))
    (when (file-exists-p path)
      (load path))))
