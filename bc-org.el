;;; bc-org.el -- my orgmode config

;;; Commentary:

;;; Code:

;; org-capture

(use-package org
  :config

  ;; general config
  (setq org-todo-keywords
        '((sequence "TODO" "IN-PROGRESS" "WAITING" "|" "DONE")
          (sequence "|" "CANCELED" "SOMEDAY")))
  (add-hook 'org-mode-hook #'company-mode)
  (add-hook 'org-mode-hook (lambda () (setq tab-width 2)))

  ;; src block settings
  (setq org-src-fontify-natively t
        org-src-tab-acts-natively t
        org-confirm-babel-evaluate nil)
  (unless bc-venv-current-venv
    (bc-venv--enable-venv)
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((emacs-lisp . t)
       (python . t)
       (jupyter . t))))
  (advice-add 'org-edit-src-code :after (lambda () (ignore-errors (eglot-ensure))))

  ;; org-capture

  (add-hook 'org-capture-mode-hook #'evil-insert-state)
  (setq org-capture-templates
        `(("t"
           "A todo item with deadline"
           entry
           (file "todo.org"),
           (concat "* TODO %?\n"
                   "CREATED:  %t\n")
           :empty-lines 1)
          )
        )

  :general
  (:keymaps 'org-mode-map
   :states '(normal visual motion)
   :prefix "SPC"
   "r" 'org-export-dispatch)

  (:keymaps 'org-mode-map
   :states 'normal
   ;; do not need `evil-jump-item'
   "<tab>" 'org-cycle)

  (:keymaps 'org-mode-map
   :states '(normal visual motion)
   "<up>" 'org-previous-visible-heading
   "<down>" 'org-next-visible-heading
   "U" 'outline-up-heading)

  (:keymaps 'org-mode-map
   :states '(insert normal visual motion)
   "C-d" 'org-forward-heading-same-level
   "C-u" 'org-backward-heading-same-level
   "M-j" 'org-shiftdown
   "M-k" 'org-shiftup
   "M-h" 'org-shiftleft
   "M-l" 'org-shiftright))

;; functions

(defun bc-org-insert-date ()
  "Insert today's date in org-mode's format."
  (insert (concat "<"
                  (shell-command-to-string "echo -n $(date +%Y-%m-%d)")
                  ">")))

(defun bc-org-insert-date-time ()
  "Insert today's date-time in org-mode's format."
  (insert (concat "<"
                  (shell-command-to-string "echo -n $(date +%Y-%m-%d)")
                  " "
                  (shell-command-to-string "echo -n $(date +%H:%M)")
                  ">")))


(provide 'bc-org)
;;; bc-org.el ends here
