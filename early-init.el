;; -*- lexical-binding: t; -*-

;; Load customizations as early as possible so use take effect before
;; they are used.
(setq custom-file (locate-user-emacs-file "custom.el"))
(unless (file-exists-p custom-file)
  (with-temp-buffer
    (insert ";;; -*- lexical-binding: t; -*-\n\n")
    (write-file custom-file)))
(load custom-file 'noerror 'nomessage)

(setq frame-inhibit-implied-resize t)
(setq frame-resize-pixelwise t)

;; In PGTK, this timeout introduces latency. Reducing it from the default 0.1
;; improves responsiveness of childframes and related packages.
(when (boundp 'pgtk-wait-for-event-timeout)
  (setq pgtk-wait-for-event-timeout 0.001))


;; Disables unused UI Elements
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
;; (if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
;; (if (fboundp 'tooltip-mode) (tooltip-mode -1))
;; (if (fboundp 'fringe-mode) (fringe-mode -1))
