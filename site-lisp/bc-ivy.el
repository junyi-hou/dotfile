;;; bc-ivy.el --- config for ivy -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(require 'bc-core)

(use-package ivy
  :config
  (setq ivy-do-completion-in-region nil
        ivy-wrap t
        ivy-count-format ""
        ivy-initial-inputs-alist nil
        ivy-re-builders-alist '((t . ivy--regex-ignore-order))
        ivy-format-function #'ivy-format-function-line
        ivy-magic-slash-non-match-action nil
        projectile-completion-system 'ivy)
  :init
  (ivy-mode 1)
  :general
  (:keymaps 'ivy-minibuffer-map
   "M-j" 'ivy-next-line
   "M-k" 'ivy-previous-line))

(use-package counsel
    :after ivy
    :general
    (:keymaps '(normal visual motion)
     :prefix "SPC"
     "js" 'counsel-ag
     "jr" (lambda () (interactive)
            (counsel-ag (symbol-name (symbol-at-point))))))

;; (use-package ivy-posframe
;;     :after ivy
;;     :config
;;     (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-point)))
;;     (ivy-posframe-mode 1))


(provide 'bc-ivy)
;;; bc-ivy.el ends here
