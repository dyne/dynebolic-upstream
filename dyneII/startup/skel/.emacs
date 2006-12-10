;; jaromil emacs configuration
;; jaromil@dyne.org - http://dyne.org

;; uncomment below for deactivating all menubar scrollbar toolbar!
;; that is not the real way to use emacs ;)
;; (tool-bar-mode nil)
;; (menu-bar-mode nil)
;; (scroll-bar-mode nil)

;; Some macros.
(defmacro GNUEmacs (&rest x)
  (list 'if (string-match "GNU Emacs 21" (version)) (cons 'progn x)))
(defmacro XEmacs (&rest x)
  (list 'if (string-match "XEmacs 21" (version)) (cons 'progn x)))
(defmacro Xlaunch (&rest x)
  (list 'if (eq window-system 'x)(cons 'progn x)))


(GNUEmacs 
 (Xlaunch
     (define-key global-map [(delete)]    "\C-d") 
))

(GNUEmacs 
 ; XEmacs compatibility
 (global-set-key [(control tab)] `other-window)
 (global-set-key [(meta g)] `goto-line)
 (defun switch-to-other-buffer () (interactive) (switch-to-buffer (other-buffer)))
 (global-set-key [(meta control ?l)] `switch-to-other-buffer)

 (global-set-key [(meta O) ?H] 'beginning-of-line)
 (global-set-key [home] 'beginning-of-line)
 (global-set-key [(meta O) ?F] 'end-of-line)
 (global-set-key [end] 'end-of-line) 
 (setq next-line-add-newlines nil))

; X selection manipulation
(GNUEmacs (defun x-own-selection (s) (x-set-selection `PRIMARY s)))
(global-set-key [(shift insert)] '(lambda () (interactive) (insert (x-get-selection))))
(global-set-key [(control insert)] '(lambda () (interactive) (x-own-selection (buffer-substring (point) (mark)))))

; Shift-arrows a la windows...
(GNUEmacs (custom-set-variables
 '(pc-select-meta-moves-sexps t)
 '(pc-select-selection-keys-only t)
 '(pc-selection-mode t nil (pc-select))))

(XEmacs
 (if (eq window-system 'x)
     (global-set-key (read-kbd-macro "DEL") 'delete-char)
   (or (global-set-key "[3~" 'delete-char))
   ))

;; By default we starting in text mode.
(setq initial-major-mode
      (lambda ()
        (text-mode)
        (turn-on-auto-fill)
	(global-font-lock-mode)
	))

(GNUEmacs (setq revert-without-query (cons "TAGS" revert-without-query)))

; Use the following for i18n
;(standard-display-european t)
;(GNUEmacs (set-language-environment "latin-1"))
;(XEmacs (require 'x-compose))

; Some new Colors for Font-lock.
(setq font-lock-mode-maximum-decoration t)
(require 'font-lock)
(setq font-lock-use-default-fonts nil)
(setq font-lock-use-default-colors nil)
(copy-face 'default 'font-lock-string-face)
(set-face-foreground 'font-lock-string-face "Sienna")
(copy-face 'italic 'font-lock-comment-face)
(set-face-foreground 'font-lock-comment-face "Red")
(copy-face 'bold 'font-lock-function-name-face)
(set-face-foreground 'font-lock-function-name-face "MediumBlue")
(copy-face 'default 'font-lock-keyword-face)
(set-face-foreground 'font-lock-keyword-face "SteelBlue")
(copy-face 'default 'font-lock-type-face)
(set-face-foreground 'font-lock-type-face "DarkOliveGreen")
(GNUEmacs (set-face-foreground 'modeline "red")
	  (set-face-background 'modeline "lemonchiffon"))

; load color-themes extension
(require 'color-theme)
(color-theme-initialize)

(GNUEmacs
 (setq transient-mark-mode 't)
 )

(XEmacs
 (set-face-foreground 'bold-italic "Blue")
 )

(GNUEmacs
 (Xlaunch
  (make-face-bold 'bold-italic)
  ))

(set-face-foreground 'bold-italic "Blue")

(setq default-frame-alist
      '(
;;; Define here the default geometry or via ~/.Xdefaults.
;;	(width . 84) (height . 46)
	(width . 106) (height . 49)
	(cursor-color . "red")
	(cursor-type . box)
	(foreground-color . "black")
	(background-color . "honeydew")))

;; A small exemples to show how Emacs is powerfull.
; Define function to match a parenthesis otherwise insert a %

;(global-set-key "%" 'match-paren)
;(defun match-paren (arg)
;  "Go to the matching parenthesis if on parenthesis otherwise insert %."
;  (interactive "p")
;  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
;        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
;        (t (self-insert-command (or arg 1)))))

;; By default turn on colorization.
(if (fboundp 'global-font-lock-mode)
    (global-font-lock-mode t)
  )

;; Add bzip2 suffixes to info reader.
(XEmacs
 (require 'info)
 (setq Info-suffix-list
       (append '(
		 (".info.bz2" . "bzip2 -dc %s")
		 (".bz2"      . "bzip2 -dc %s")
		 )
	       Info-suffix-list))
 )

;; More information with the info file (Control-h i)
(custom-set-variables
  ;; custom-set-variables was added by Custom -- don't edit or cut/paste it!
  ;; Your init file should contain only one such instance.
 '(column-number-mode t)
 '(get-frame-for-buffer-default-instance-limit nil)
 '(line-number-mode t)
 '(pc-select-meta-moves-sexps t)
 '(pc-select-selection-keys-only t)
 '(pc-selection-mode t nil (pc-select)))
(custom-set-faces
  ;; custom-set-faces was added by Custom -- don't edit or cut/paste it!
  ;; Your init file should contain only one such instance.
 '(default ((t (:stipple nil :background "honeydew" :foreground "black" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 132 :width normal :family "adobe-courier")))))

;;; mwheel.el --- Mouse support for MS intelli-mouse type mice

(require 'custom)
(require 'cl)

(defconst mwheel-running-xemacs (string-match "XEmacs" (emacs-version)))

(defcustom mwheel-scroll-amount '(5 . 1)
  "Amount to scroll windows by when spinning the mouse wheel.
This is actually a cons cell, where the first item is the amount to scroll
on a normal wheel event, and the second is the amount to scroll when the
wheel is moved with the shift key depressed.
This should be the number of lines to scroll, or `nil' for near
full screen.
A near full screen is `next-screen-context-lines' less than a full screen."
  :group 'mouse
  :type '(cons
	  (choice :tag "Normal"
		  (const :tag "Full screen" :value nil)
		  (integer :tag "Specific # of lines"))
	  (choice :tag "Shifted"
		  (const :tag "Full screen" :value nil)
		  (integer :tag "Specific # of lines"))))

(defcustom mwheel-follow-mouse nil
  "Whether the mouse wheel should scroll the window that the mouse is over.
This can be slightly disconcerting, but some people may prefer it."
  :group 'mouse
  :type 'boolean)

(if (not (fboundp 'event-button))
    (defun mwheel-event-button (event)
      (let ((x (symbol-name (event-basic-type event))))
	(if (not (string-match "^mouse-\\([0-9]+\\)" x))
	    (error "Not a button event: %S" event))
	(string-to-int (substring x (match-beginning 1) (match-end 1)))))
  (fset 'mwheel-event-button 'event-button))

(if (not (fboundp 'event-window))
    (defun mwheel-event-window (event)
      (posn-window (event-start event)))
  (fset 'mwheel-event-window 'event-window))

(defun mwheel-scroll (event)
  (interactive "e")
  (let ((curwin (if mwheel-follow-mouse
		    (prog1
			(selected-window)
		      (select-window (mwheel-event-window event)))))
	(amt (if (memq 'shift (event-modifiers event))
		 (cdr mwheel-scroll-amount)
	       (car mwheel-scroll-amount))))
    (case (mwheel-event-button event)
      (4 (scroll-down amt))
      (5 (scroll-up amt))
      (otherwise (error "Bad binding in mwheel-scroll")))
    (if curwin (select-window curwin))))

(define-key global-map (if mwheel-running-xemacs 'button4 [mouse-4])
  'mwheel-scroll)

(define-key global-map (if mwheel-running-xemacs [(shift button4)] [S-mouse-4])
  'mwheel-scroll)

(define-key global-map (if mwheel-running-xemacs 'button5 [mouse-5])
  'mwheel-scroll)

(define-key global-map (if mwheel-running-xemacs [(shift button5)] [S-mouse-5])
  'mwheel-scroll)

(provide 'mwheel)
