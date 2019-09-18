;;; bc-mail.el --- email client based on mu4e -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:
(use-package notmuch
  :ensure nil
  :defer t
  :init
  (setenv "NOTMUCH_CONFIG" (no-littering-expand-etc-file-name "notmuch.conf"))

  (dolist (mode '(notmuch-hello-mode notmuch-search-mode notmuch-show-mode notmuch-tree-mode))
    (evil-set-initial-state mode 'motion))

  (defun bc-mail-update-and-search (query)
    "Poll from the server and start searching QUERY"
    (interactive "sSearching Mail: ")
    (notmuch-poll)
    (notmuch-search query))

  (defun bc-mail-flag ()
    "Flagged selected threads."
    (interactive)
    (notmuch-search-tag '("+flagged")))

  (defun bc-mail-unflag ()
    "Unflagged selected threads."
    (interactive)
    (notmuch-search-tag '("-flagged")))

  (defun bc-mail-update-and-new ()
    "Open unread email list."
    (interactive)
    (bc-mail-update-and-search "tag:unread and tag:inbox"))

  (defun bc-mail-update-and-open-inbox ()
    "Open inbox"
    (interactive)
    (bc-mail-update-and-search "tag:inbox"))

  (defun bc-mail-compose ())

  :general
  (:keymaps '(motion normal visual emacs insert)
  :prefix "SPC"
  :non-normal-prefix "s-SPC"
  "ms" 'bc-mail-update-and-search
  "mi" 'bc-mail-update-and-open-inbox
  "mu" 'bc-mail-update-and-new
  "mn" 'bc-mail-compose)

  (:keymaps 'notmuch-hello-mode-map
   :states 'motion
   "q" 'notmuch-bury-or-kill-this-buffer
   "s" 'notmuch-search)

  (:keymaps 'notmuch-search-mode-map
   :states '(motion visual)
   "q" 'notmuch-bury-or-kill-this-buffer
   "s" 'notmuch-search
   "S" 'notmuch-search-filter

   "a" 'notmuch-search-archive-thread
   "A" (lambda () (interactive)
         (notmuch-search-archive-thread 'unarchive))
   "f" 'bc-mail-flag
   "F" 'bc-mail-unflag

   "-" 'notmuch-search-remove-tag
   "+" 'notmuch-search-add-tag
   "gr" 'notmuch-poll-and-refresh-this-buffer
   "RET" 'notmuch-search-show-thread
   "t" (lambda () (interactive)
         (notmuch-search-show-thread)
         (notmuch-tree-from-show-current-query))
   "T" 'notmuch-tree-from-search-current-query)

  (:keymaps 'notmuch-show-mode-map
   :states 'motion
   "q" 'notmuch-bury-or-kill-this-buffer
   "s" 'notmuch-search
   "t" 'notmuch-tree-from-show-current-query
   "gr" 'notmuch-show-refresh-view
   "<tab>" 'notmuch-show-next-button
   "<backtab>" 'notmuch-show-previous-button

   "f" 'notmuch-show-forward-message
   "F" 'notmuch-show-forward-open-messages
   "r" 'notmuch-show-reply-sender
   "R" 'notmuch-show-reply

   "C-y" 'notmuch-show-previous-message
   "C-e" 'notmuch-show-next-message
   "a" 'notmuch-show-archive-thread-then-next
   "A" 'notmuch-show-archive-message-then-next-or-next-thread

   "M-j" 'notmuch-show-advance
   "M-k" 'notmuch-show-rewind)

  (:keymap 'notmuch-tree-mode-map
   :states 'motion
   "q" 'notmuch-tree-quit
   "s" 'notmuch-search
   "S" 'notmuch-search-from-tree-current-query
   "RET" 'notmuch-tree-show-message
   "a" 'notmuch-tree-archive-message-then-next
   "A" 'notmuch-tree-archive-thread))

(use-package org-notmuch
  ;; require to emerge `app-emacs/org-mode' with `contrib' flag
  :ensure nil
  :after notmuch)

(provide 'bc-mail)
;;; bc-mail.el ends here
