;;; dev-evil.el -- evil mode related settings

;;; Commentary:

;;; Code:

;; load pkgs

(use-package general
  :commands general-define-key)

(use-package evil
  :config
  (setq evil-normal-state-modes (append evil-emacs-state-modes evil-normal-state-modes))
  :init
  (setq evil-want-C-u-scroll t
        evil-want-C-d-scroll t)
  (evil-mode 1))

(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

(use-package evil-indent-textobject :after evil)

(use-package evil-nerd-commenter
  :after evil
  :commands evilnc-comment-or-uncomment-lines)

;; functions

(defun dev--eshell-here ()
  "Opens up a new shell in the directory associated with the current buffer's file.  The eshell is renamed to match that directory to make multiple eshell windows easier."
  (interactive)
  (let* ((parent (if (buffer-file-name)
                     (file-name-directory (buffer-file-name))
                   default-directory))
         (height (/ (window-total-height) 3))
         (name   (car (last (split-string parent "/" t)))))
    (split-window-vertically (- height))
    (evil-window-down 1)
    (let* ((eshell-name (concat "*eshell: " name "*")))
           (if (member eshell-name (mapcar 'buffer-name (buffer-list)))
               (switch-to-buffer eshell-name)
             (progn
               (eshell "new")
               (rename-buffer (concat "*eshell: " name "*"))
               (insert (concat "ls"))
               (eshell-send-input))))))

(defun dev-evil--is-user-buffer ()
  "Determine whether the current buffer is a user-buffer by looking at the first char.  Return t if current buffer is not a dired tree or is a user-buffer (include *scratch* buffer)."
  (let ((name (buffer-name)))
    (cond ((string-equal "*scratch*" name) t)
          ((string-equal "*" (substring name 0 1)) nil)
          ((string-equal major-mode "dired-mode") nil)
          (t t))))

(defun dev-evil-next-user-buffer ()
  "Jump to the next user buffer."
  (interactive)
  (let ((current (buffer-name)))
    (next-buffer)
    (if (not (dev-evil--is-user-buffer))
      (dev-evil-next-user-buffer)
      )))

(defun dev-evil-previous-user-buffer ()
  "Jump to the previous user buffer."
  (interactive)
  (let ((current (buffer-name)))
    (previous-buffer)
    (if (not (dev-evil--is-user-buffer))
      (dev-evil-previous-user-buffer)
      )))

(evil-define-motion dev-evil-next-three-lines ()
  (interactive)
  (evil-next-visual-line 3)
  )

(evil-define-motion dev-evil-previous-three-lines ()
  (interactive)
  (evil-previous-visual-line 3)
  )

(defun dev-evil-smart-tab ()
  "Assign tab key to:
`indent-region` if in visual line mode;
`evil-jump-items` if in visual or normal mode."
  (interactive)
  (if (and (evil-visual-state-p) (eq evil-visual-selection 'line))
      (indent-region (region-beginning) (region-end))
    (evil-jump-item)))

(defun dev--search-point-or-region ()
  "Search the word under the cursor if in normal mode, or search the region if in visual mode."
  (interactive)
  (if (evil-visual-state-p)
      (evil-search (buffer-substring (region-beginning) (region-end)) t)
    (evil-search (thing-at-point 'word t) t)))

(defun dev-evil-set-leader-keymap (&key keymaps &optional states)
  "Set the standard leader keymaps I use for KEYMAP and optionally STATE."
  (general-define-key
    :keymaps keymaps
    :states states
    "" nil
    "SPC" nil)

  (general-define-key
    :keymaps keymaps
    :states states
    :prefix "SPC"

    ;; execute
    "ee"  'execute-extended-command
    "eE"  'evil-ex
    "el"  'eval-last-sexp

    ;; repl runs
    ;; need to be remapped for different languages
    ;; "rr" 'dev-run-buffer-or-visual
    ;; "rl" 'dev-run-line-or-visual
    ;; "ro" 'dev-open-repl-or-switch-to-repl
    ;; "rO" 'dev-open-remote-repl

    ;; helps
    "hf" 'describe-function
    "hw" 'where-is
    "hk" 'describe-key
    "hv" 'describe-variable
    "hm" 'describe-mode
    "hh" 'help-for-help

    ;; basic function
    "w"  'evil-write
    "k"  'delete-window
    "q"  (lambda () (interactive) (kill-buffer (current-buffer)))

    ;; buffer related
    "n"  'dev-evil-next-user-buffer
    "N"  'dev-evil-previous-user-buffer

    ;; split
    "\\"  (lambda () (interactive) (evil-window-vsplit) (evil-window-right 1))
    "|"   (lambda () (interactive) (evil-window-vsplit) (evil-window-right 1))
    "-"   (lambda () (interactive) (evil-window-split) (evil-window-down 1))
    "_"   (lambda () (interactive) (evil-window-split) (evil-window-down 1))

    ;; open stuffs
    "of" 'find-file
    "ob" 'ivy-switch-buffer
    "oo" 'projectile-find-file
    "os" 'dev--eshell-here
    "op" 'projectile-switch-project

    ;; jump to
    "jg" 'dumb-jump-go-other-window
    "jG" 'dumb-jump-go
    "jb" 'dumb-jump-back
    "jj" 'dumb-jump-quick-look

    ;; search and replace

    ;; other uses
    "t" 'evilnc-comment-or-uncomment-lines
    "f" 'evil-toggle-fold
    ))

(defun dev-evil-cursor-movement-keymap (&key keymaps &optional states)
  "Set standard movement keymaps I use for KEYMAP and optionally, STATES."
  (general-define-key
    :states states
    :keymaps keymaps

    "j" 'evil-next-visual-line
    "k" 'evil-previous-visual-line

    "H" 'evil-first-non-blank-of-visual-line
    "J" 'dev-evil-next-three-lines
    "K" 'dev-evil-previous-three-lines
    "L" 'evil-end-of-visual-line

    "TAB" 'dev-evil-smart-tab
    "<tab>" 'dev-evil-smart-tab
    ))

(defun dev-evil-window-movement-keymap (&key keymaps &optional states)
  "Set standard window movement key I use for KEYMAP and optionally, STATES." 
  (general-define-key
   :states states
   :keymaps keymaps
    "C-h" 'evil-window-left
    "C-j" 'evil-window-down
    "C-k" 'evil-window-up
    "C-l" 'evil-window-right

    "C-e" (lambda () (interactive) (evil-scroll-line-down 5))
    "C-y" (lambda () (interactive) (evil-scroll-line-up 5))))

;;; set keymaps for most of the modes
(dev-evil-set-leader-keymap
 :keymaps '(motion normal visual))
(dev-evil-cursor-movement-keymap
 :keymaps '(motion normal visual))
(dev-evil-window-movement-keymap
 :keymaps '(motion normal visual emacs insert))

;; help in the insert mode
(general-define-key
 :keymaps 'insert
 "C-1" 'describe-key
 )


(provide 'dev-evil)
;;; dev-evil.el ends here
