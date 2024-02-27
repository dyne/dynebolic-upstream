;;; unobtrusive-magit-theme.el --- An unobtrusive Magit theme  -*- lexical-binding: t; -*-

;; Copyright (C) 2016 Thomas A. Brown

;; Author: Thomas A. Brown <tabsoftwareconsulting@gmail.com>
;; URL: https://github.com/tee3/unobtrusive-magit-theme
;; Keywords: faces, vc, magit
;; Package-Requires: ((emacs "24.1"))
;; Version: 0.2

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.
;;

;;; Commentary:

;; An Emacs theme to support Magit and related modes by inheriting
;; from standard Emacs faces such as those provided by `vc` and
;; `diff`.

;;; Code:

(deftheme unobtrusive-magit
  "An unobtrusive Magit theme.
This theme replaces Magit faces with faces inherited from
standard Emacs components.")

(let ()
  (custom-theme-set-faces
   'unobtrusive-magit

   `(git-commit-summary				((t (:inherit log-edit-summary))))
   `(git-commit-overlong-summary		((t (:inherit warning))))
   `(git-commit-nonempty-second-line		((t (:inherit warning))))
   `(git-commit-note				((t (:inherit default))))
   `(git-commit-pseudo-header			((t (:inherit log-edit-unknown-header))))
   `(git-commit-known-pseudo-header		((t (:inherit git-commit-pseudo-header))))
   `(git-commit-comment-action			((t (:inherit font-lock-comment-face))))
   `(git-commit-comment-branch-local		((t (:inherit font-lock-comment-face))))
   `(git-commit-comment-branch-remote		((t (:inherit font-lock-comment-face))))
   `(git-commit-comment-detached		((t (:inherit font-lock-comment-face))))
   `(git-commit-comment-file			((t (:inherit font-lock-comment-face))))
   `(git-commit-comment-heading			((t (:inherit font-lock-comment-face))))
   `(git-commit-comment-keyword			((t (:inherit font-lock-comment-face))))

   `(magit-dimmed				((t (:inherit shadow))))
   `(magit-hash					((t (:inherit log-view-message))))
   `(magit-keyword				((t (:inherit default))))
   `(magit-tag					((t (:inherit change-log-list))))
   `(magit-head					((t (:inherit change-log-list :inverse-video t))))
   `(magit-filename				((t (:inherit change-log-file))))

   `(magit-section-heading			((t (:inherit font-lock-type-face))))
   `(magit-section-heading-selection		((t (:weight bold))))
   `(magit-section-heading-secondary-heading	((t (:inherit magit-section-heading-selection))))
   `(magit-section-highlight			((t ())))

   `(magit-diff-file-heading			((t (:inherit diff-file-headxoer))))
   `(magit-diff-file-heading-highlight		((t (:inherit magit-diff-file-heading))))
   `(magit-diff-file-heading-selection		((t (:inherit magit-diff-file-heading))))

   `(magit-diff-hunk-heading			((t (:inherit diff-hunk-header))))
   `(magit-diff-hunk-heading-highlight		((t (:inherit magit-diff-hunk-heading))))
   `(magit-diff-hunk-heading-selection		((t (:inherit magit-diff-hunk-heading))))
   `(magit-diff-hunk-region			((t (:inherit default))))

   `(magit-diff-lines-boundary			((t (:inherit default))))
   `(magit-diff-lines-heading			((t (:inherit heading-line))))

   `(magit-diff-added				((t (:inherit diff-added))))
   `(magit-diff-added-highlight			((t (:inherit magit-diff-added))))

   `(magit-diff-removed				((t (:inherit diff-removed))))
   `(magit-diff-removed-highlight		((t (:inherit magit-diff-removed))))

   `(magit-diff-context				((t (:inherit diff-context))))
   `(magit-diff-context-highlight		((t (:inherit magit-diff-context))))

   `(magit-diff-our				((t (:inherit ediff-current-diff-A))))
   `(magit-diff-our-highlight			((t (:inherit magit-diff-our))))

   `(magit-diff-base				((t (:inherit ediff-current-diff-Ancestor))))
   `(magit-diff-base-highlight			((t (:inherit magit-diff-base))))

   `(magit-diff-their				((t (:inherit ediff-current-diff-C))))
   `(magit-diff-their-highlight			((t (:inherit magit-diff-their))))

   `(magit-diff-whitespace-warning		((t (:inherit trailing-whitespace))))

   `(magit-diffstat-added			((t (:inherit diff-added))))
   `(magit-diffstat-removed			((t (:inherit magit-diffstat-removed))))

   `(magit-process-ok				((t (:inherit success))))
   `(magit-process-ng				((t (:inherit error))))

   `(magit-log-author				((t (:inherit change-log-name))))
   `(magit-log-date				((t (:inherit change-log-date))))
   `(magit-log-graph				((t (:inherit default))))

   `(magit-sequence-pick			((t (:inherit warning))))
   `(magit-sequence-stop			((t (:inherit default :weight bold))))
   `(magit-sequence-part			((t (:inherit default))))
   `(magit-sequence-head			((t (:inherit default :weight bold))))
   `(magit-sequence-drop			((t (:inherit error))))
   `(magit-sequence-done			((t (:inherit success))))
   `(magit-sequence-onto			((t (:inherit success :weight bold))))

   `(magit-bisect-good				((t (:inherit success))))
   `(magit-bisect-skip				((t (:inherit warning))))
   `(magit-bisect-bad				((t (:inherit error))))

   `(magit-blame-heading			((t (:inherit header-line))))
   `(magit-blame-hash				((t (:inherit log-view-message))))
   `(magit-blame-name				((t (:inherit change-log-name))))
   `(magit-blame-date				((t (:inherit change-log-date))))
   `(magit-blame-summary			((t (:inherit default))))
   `(magit-blame-dimmed				((t (:inherit shadow))))

   `(magit-refname				((t (:inherit change-log-list))))
   `(magit-refname-stash			((t (:inherit magit-refname))))
   `(magit-refname-wip				((t (:inherit magit-refname))))

   `(magit-branch-local				((t (:inherit change-log-list))))
   `(magit-branch-current			((t (:inherit magit-branch-local :weight bold))))
   `(magit-branch-remote			((t (:inherit change-log-list))))
   `(magit-branch-remote-head			((t (:inherit magit-branch-remote :weight bold))))
   `(magit-branch-upstream			((t (:inherit change-log-list :inverse-video t))))

   `(magit-mode-line-process			((t (:inherit mode-line-emphasis))))
   `(magit-mode-line-process-error		((t (:inherit error))))

   `(magit-signature-bad			((t (:inherit error))))
   `(magit-signature-error			((t (:inherit error :weight bold))))
   `(magit-signature-expired			((t (:inherit warning))))
   `(magit-signature-expired-key		((t (:inherit warning))))
   `(magit-signature-good			((t (:inherit success))))
   `(magit-signature-revoked			((t (:inherit warning))))
   `(magit-signature-untrusted			((t (:inherit warning :weight bold))))

   `(magit-cherry-unmatched			((t (:inherit warning))))
   `(magit-cherry-equivalent			((t (:inherit success))))

   `(magit-reflog-commit			((t (:inherit log-view-message))))
   `(magit-reflog-amend				((t (:inherit log-view-message))))
   `(magit-reflog-merge				((t (:inherit log-view-message))))
   `(magit-reflog-checkout			((t (:inherit log-view-message))))
   `(magit-reflog-reset				((t (:inherit log-view-message))))
   `(magit-reflog-rebase			((t (:inherit log-view-message))))
   `(magit-reflog-cherry-pick			((t (:inherit log-view-message))))
   `(magit-reflog-remote			((t (:inherit log-view-message))))
   `(magit-reflog-other				((t (:inherit log-view-message))))))

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'unobtrusive-magit)
(provide 'unobtrusive-magit-theme)
;;; unobtrusive-magit-theme.el ends here
