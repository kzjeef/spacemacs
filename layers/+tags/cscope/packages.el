;;; packages.el --- cscope Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(setq cscope-packages '(helm-cscope
                        xcscope))

(defun cscope/init-xcscope ()
  (use-package xcscope
    :commands (cscope-index-files cscope/run-pycscope)
    :init
    (progn
      ;; for python projects, we don't want xcscope to rebuild the databse,
      ;; because it uses cscope instead of pycscope
      (setq cscope-option-do-not-update-database t
            cscope-display-cscope-buffer nil)

      (defun cscope//safe-project-root ()
        "Return project's root, or nil if not in a project."
        (and (fboundp 'projectile-project-root)
             (projectile-project-p)
             (projectile-project-root)))

      (defun cscope/run-pycscope (directory)
        (interactive (list (file-name-as-directory
                            (read-directory-name "Run pycscope in directory: "
                                                 (cscope//safe-project-root)))))
        (let ((default-directory directory))
          (shell-command
           (format "pycscope -R -f '%s'"
                   (expand-file-name "cscope.out" directory))))))))

(when (configuration-layer/layer-usedp 'spacemacs-helm)
  (defun cscope/init-helm-cscope ()
    (use-package helm-cscope
      :defer t
      :init
      (defun spacemacs/setup-helm-cscope (mode)
        "Setup `helm-cscope' for MODE"
        (spacemacs/set-leader-keys-for-major-mode mode
          "sc" 'helm-cscope-find-called-function
          "sC" 'helm-cscope-find-calling-this-funtcion
          "sd" 'helm-cscope-find-global-definition
          "se" 'helm-cscope-find-egrep-pattern  ;; follow xcscope key code
          "sf" 'helm-cscope-find-this-file
          "sF" 'helm-cscope-find-files-including-file
          "ss" 'helm-cscope-find-this-symbol  ;; follow the xcscope key code
          "sp" 'helm-cscope-pop-mark
          "s=" 'helm-cscope-find-assignments-to-this-symbol
          "st" 'helm-cscope-find-this-text-string))
      :config
      (defadvice helm-cscope-find-this-symbol (before cscope/goto activate)
        (evil--jumps-push)))))
