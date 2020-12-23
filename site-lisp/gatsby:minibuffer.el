;;; gatsby:minibuffer.el --- enhancement of minibuffer -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(use-package prescient
  :init
  (setq prescient-save-file (concat no-littering-var-directory "prescient-save.el"))
  :config
  (prescient-persist-mode 1))

(use-package selectrum
  :defines (selectrum-minibuffer-bindings selectrum-should-sort-p)
  :init
  (selectrum-mode 1)

  (defun gatsby:selectrum--remove-until-slash (bound n)
    "Return the position of the backwards Nth slash until BOUND.
If no slash was found, return BOUND."
    (save-excursion
      (if-let ((found (search-backward "/" bound 'noerror n)))
          (1+ found)
        bound)))

  (defun gatsby:selectrum-better-backspace ()
    "If `point' is at \"/\", delete till the last \"/\"."
    (interactive)
    (cond ((thing-at-point-looking-at "~/")
           (progn
             (delete-region (minibuffer-prompt-end) (point))
             (insert "/home/")))
          ((string= (buffer-substring (minibuffer-prompt-end) (point)) "/")
           (call-interactively #'backward-delete-char))
          ((thing-at-point-looking-at "/")
           (delete-region (gatsby:selectrum--remove-until-slash
                           selectrum--start-of-input-marker 2)
                          (point)))
          (t (call-interactively #'backward-delete-char))))

  (defun gatsby:selectrum-next-candidate-cycle ()
    "Move selection to next candidate, if at the end, go to the top."
    (interactive)
    (when selectrum--current-candidate-index
      (setq selectrum--current-candidate-index
            (if (= selectrum--current-candidate-index
                   (1- (length selectrum--refined-candidates)))
                (if selectrum--match-required-p 0 -1)
              (1+ selectrum--current-candidate-index)))))

  (defun gatsby:selectrum-previous-candidate-cycle ()
    "Move selection to previous candidate, if at the beginning, go to the end."
    (interactive)
    (when selectrum--current-candidate-index
      (setq selectrum--current-candidate-index
            (if (= selectrum--current-candidate-index
                   (if selectrum--match-required-p 0 -1))
                (1- (length selectrum--refined-candidates))
              (1- selectrum--current-candidate-index)))))

  (defun gatsby:selectrum-unified-tab ()
    "<tab> does the following things
1. if there is a common part among candidates, complete the common part;
2. if there is only one candidate, select the candidate
3. if the last command is `gatsby:selectrum-unified-tab', `gatsby:selectrum-previous-candidate-cycle' or `gatsby:selecturm-next-candidate-cycle', then select the current candidate"
    (interactive)
    (when selectrum--current-candidate-index
      (let* ((input (buffer-substring-no-properties
                     selectrum--start-of-input-marker
                     selectrum--end-of-input-marker))
             (common (try-completion "" selectrum--refined-candidates)))
        (cond
         ;; case 2/3
         ((or (memq last-command '(gatsby:selectrum-unified-tab
                                   gatsby:selectrum-next-candidate-cycle
                                   gatsby:selectrum-previous-candidate-cycle))
              (= 1 (length selectrum--refined-candidates)))
          (selectrum-select-current-candidate))
         ;; case 1
         ((not (string= common ""))
          (progn
            (delete-region (gatsby:selectrum--remove-until-slash
                            selectrum--start-of-input-marker 1)
                           selectrum--end-of-input-marker)
            (insert common)))))))

  :config
  (setq selectrum-minibuffer-bindings
        (append selectrum-minibuffer-bindings
                '(("M-j" . gatsby:selectrum-next-candidate-cycle)
                  ("M-k" . gatsby:selectrum-previous-candidate-cycle)
                  ("<backspace>" . gatsby:selectrum-better-backspace)
                  ("<tab>" . gatsby:selectrum-unified-tab))))

  :custom
  (selectrum-fix-minibuffer-height t)

  :general
  (:keymaps '(motion normal visual emacs insert)
   :prefix "SPC"
   :non-normal-prefix "s-SPC"
   "oo" 'find-file
   "or" (lambda () (interactive)
          (let ((selectrum-should-sort-p nil))
            (find-file (completing-read "Recent file: "
                                        (mapcar #'abbreviate-file-name recentf-list)
                                        nil t))))
   "ob" 'switch-to-buffer
   "om" (lambda () (interactive)
          (switch-to-buffer-other-window (get-buffer-create "*Messages*")))))

(use-package selectrum-prescient
  :after selectrum
  :config
  (selectrum-prescient-mode 1))

(provide 'gatsby:minibuffer)
;;; gatsby:minibuffer.el ends here
