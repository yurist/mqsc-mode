;;; mqsc-mode.el --  comint for IBM MQ runmqsc

(require 'comint)

(defgroup MQSC nil
  "Executing IBM MQ `runmqsc' within Emacs buffers."
  :group 'tools
  :group 'processes)

(defcustom mqsc-command-path "/usr/bin/runmqsc"
  "`runmqsc' executable path"
  :type 'string
  :group 'MQSC)

(defcustom mqsc-channel "SYSTEM.DEF.SVRCONN"
  "Server connection channel"
  :type 'string
  :group 'MQSC)

(defcustom mqsc-host "localhost"
  "Queue manager host"
  :type 'string
  :group 'MQSC)

(defcustom mqsc-port "1414"
  "Queue manager listener port"
  :type 'string
  :group 'MQSC)

(defcustom mqsc-qmgr nil
  "Queue manager name"
  :type 'string
  :group 'MQSC)

(defvar mqsc-mode-map
  (let ((map (nconc (make-sparse-keymap) comint-mode-map)))
    map)
  "Mode map for `runmqsc'")

(defun mqsc-run ()
  "Run inferior `runmqsc' process inside Emacs."
  (interactive)
  (let* ((buffer (comint-check-proc "MQSC"))
         (mqsc-args (nconc '("-c") (and mqsc-qmgr `("-m" ,mqsc-qmgr)))))
    (pop-to-buffer-same-window
     (if (or buffer (not (derived-mode-p 'mqsc-mode))
             (comint-check-proc (current-buffer)))
         (get-buffer-create (or buffer "*MQSC*"))
       (current-buffer))) 
    (unless buffer
      (setenv "MQSERVER"
              (concat mqsc-channel "/TCP/" mqsc-host "(" mqsc-port ")"))
      (apply 'make-comint-in-buffer "MQSC" buffer
             mqsc-command-path nil mqsc-args)
      (mqsc-mode))))

(defun mqsc--initialize ()
  "MQSC mode initialization"
  (setq comint-process-echoes t))

(define-derived-mode mqsc-mode comint-mode "MQSC"
  "Major mode for IBM MQ `runmqsc'.

\\<mqsc-mode-map>"
  nil "MQSC"
  )

(add-hook 'mqsc-mode-hook 'mqsc--initialize)
