(defun one-instruction (state)
  (let
    ((state-val (nth 0 state))
     (acc (nth 2 state))
     (pc (nth 4 state))
     (mem (nth 6 state))
     (in (nth 8 state))
     (out (nth 10 state))
     (flag (nth 12 state)))
    (let
      ((inst (nth pc mem))
       (pc-inc (mod (+ pc 1) 100)))
      (cond
        ;; Gestione istruzione non esistente
        ((or (eql inst 900)
             (and (> inst 902))
             (and (> inst 399) (< inst 500)))
         (error "Errore, istruzione non valida"))
        ;; Gestione one-instruction su halted-state
        ((eql state-val 'halted-state)
         (error "Errore, istruzione non eseguibile se lo state è halted"))
        ;; ADD
        ((and (> inst 99) (< inst 200))
         (let ((sum (+ acc (nth (- inst 100) mem))))
           (if (< sum 1000)
             (list 'state
                   :acc sum
                   :pc pc-inc
                   :mem mem
                   :in in
                   :out out
                   :flag 'noflag)
             (list 'state
                   :acc (mod sum 1000)
                   :pc pc-inc
                   :mem mem
                   :in in
                   :out out
                   :flag 'flag))))
        ;; SUB
        ((and (> inst 199) (< inst 300))
         (let ((sub (- acc (nth (- inst 200) mem))))
           (if (> sub 0)
             (list 'state
                   :acc sub
                   :pc pc-inc
                   :mem mem
                   :in in
                   :out out
                   :flag 'noflag)
             (list 'state
                   :acc (mod sub 1000)
                   :pc pc-inc
                   :mem mem
                   :in in
                   :out out
                   :flag 'flag))))
        ;; STORE
        ((and (> inst 299) (< inst 400))
         (let ((addr (- inst 300)))
           (setf (nth addr mem) acc)
           (list 'state
                 :acc acc
                 :pc pc-inc
                 :mem mem
                 :in in
                 :out out
                 :flag flag)))
        ;; LOAD
        ((and (> inst 499) (< inst 600))
         (let ((new-acc (nth (- inst 500) mem)))
           (list 'state
                 :acc new-acc
                 :pc pc-inc
                 :mem mem
                 :in in
                 :out out
                 :flag flag)))
        ;; BRANCH
        ((and (> inst 599) (< inst 700))
         (let ((pc-branch (- inst 600)))
           (list 'state
                 :acc acc
                 :pc pc-branch
                 :mem mem
                 :in in
                 :out out
                 :flag flag)))
        ;; BRANCH IF ZERO
        ((and (> inst 699) (< inst 800))
         (let ((pc-branch (- inst 700)))
           (if (and (eql acc 0) (eql flag 'noflag))
             (list 'state
                   :acc acc
                   :pc pc-branch
                   :mem mem
                   :in in
                   :out out
                   :flag flag)
             (list 'state
                   :acc acc
                   :pc pc-inc
                   :mem mem
                   :in in
                   :out out
                   :flag flag))))
        ;; BRANCH IF POSITIVE
        ((and (> inst 799) (< inst 900))
         (let ((pc-branch (- inst 800)))
           (if (eql flag 'noflag)
             (list 'state
                   :acc acc
                   :pc pc-branch
                   :mem mem
                   :in in
                   :out out
                   :flag flag)
             (list 'state
                   :acc acc
                   :pc pc-inc
                   :mem mem
                   :in in
                   :out out
                   :flag flag))))
        ;; INPUT
        ((eql inst 901)
         (let ((acc-new (first in))
               (in-new (rest in)))
           (if (eql acc-new NIL)
             (error "Istruzione di input con :in vuoto")
             (list 'state
                   :acc acc-new
                   :pc pc-inc
                   :mem mem
                   :in in-new
                   :out out
                   :flag flag))))
        ;; OUT
        ((eql inst 902)
         (let ((out-new (append out (list acc))))
           (list 'state
                 :acc acc
                 :pc pc-inc
                 :mem mem
                 :in in
                 :out out-new
                 :flag flag)))
        ;; HALT
        ((and (> inst -1) (< 100))
         (list 'halted-state
               :acc acc
               :pc pc-inc
               :mem mem
               :in in
               :out out
               :flag flag))))))

(defun execution-loop (state)
  (let ((state-val (nth 0 state))
        (out (nth 10 state)))
    ; chiama ricorsivamente l'execution loop fino a che non trova halted-state
    (cond
      ((eql state-val 'state)
       (execution-loop (one-instruction state)))
      ((eql state-val 'halted-state)
       out))))

;;; Parsing

;; Apre file in una lista, ogni riga diventa un elemento
;; della lista di tipo stringa
(defun read-list-from (input-stream)
  (let ((e (read-line input-stream nil 'eof)))
    (unless (eq e 'eof)
      (append (list e) (read-list-from input-stream)))))

(defun lmc-open-file (file-name)
  (with-open-file
    (in file-name :direction :input :if-does-not-exist :error)
    (read-list-from in)))

;; rimuove commenti
(defun remove-comment (line)
  (subseq line 0 (search "//" line)))

;; lowercase e trim
(defun format-line (line)
  (string-downcase
   (string-trim '(#\Space #\Tab #\Newline)
                (remove-comment line))))

(defun remove-empty-lines (lst)
  (cond ((null lst) nil)
        ((equal (first lst) "")
         (remove-empty-lines (rest lst)))
        (T (cons (first lst) (remove-empty-lines (rest lst))))))

(defun format-list (lmc-lst)
  (let ((new-lst (mapcar 'format-line lmc-lst)))
    (remove-empty-lines new-lst)))


;; parse labels
(defun parse-labels (lst)
  (cond ((null lst) nil)
    ((eql (find (read-from-string (first lst))
                '(add sub sta lda bra brz brp inp out hlt dat)
                :test #'equal) NIL)
     (cons (read-from-string (first lst)) (parse-labels (rest lst))))
    (T (cons 0 (parse-labels (rest lst))))))

(defun remove-labels (mem lab)
  (cond ((null mem) nil)
    ((equal (find (read-from-string (first mem)) lab)
            (read-from-string (first mem)))
     (cons (string-trim '(#\Space #\Tab #\Newline)
                        (subseq (first mem) (search " " (first mem))))
           (remove-labels (rest mem) lab)))
    (T (cons (first mem) (remove-labels (rest mem) lab)))))

;; parse instruction
(defun get-op-code (mem lab)
  (cond ((null mem) nil)
    ((equal (read-from-string (first mem)) 'add)
     (cons (+ 100 (find-addr (string-trim '(#\Space #\Tab #\Newline)
                        (subseq (first mem) (search " " (first mem)))) lab))
           (get-op-code (rest mem) lab)))
    ((equal (read-from-string (first mem)) 'sub)
     (cons (+ 200 (find-addr (string-trim '(#\Space #\Tab #\Newline)
                        (subseq (first mem) (search " " (first mem)))) lab))
           (get-op-code (rest mem) lab)))
    ((equal (read-from-string (first mem)) 'sta)
     (cons (+ 300 (find-addr (string-trim '(#\Space #\Tab #\Newline)
                        (subseq (first mem) (search " " (first mem)))) lab))
           (get-op-code (rest mem) lab)))
    ((equal (read-from-string (first mem)) 'lda)
     (cons (+ 500 (find-addr (string-trim '(#\Space #\Tab #\Newline)
                        (subseq (first mem) (search " " (first mem)))) lab))
           (get-op-code (rest mem) lab)))
    ((equal (read-from-string (first mem)) 'bra)
     (cons (+ 600 (find-addr (string-trim '(#\Space #\Tab #\Newline)
                        (subseq (first mem) (search " " (first mem)))) lab))
           (get-op-code (rest mem) lab)))
    ((equal (read-from-string (first mem)) 'brz)
     (cons (+ 700 (find-addr (string-trim '(#\Space #\Tab #\Newline)
                        (subseq (first mem) (search " " (first mem)))) lab))
           (get-op-code (rest mem) lab)))
    ((equal (read-from-string (first mem)) 'brp)
     (cons (+ 800 (find-addr (string-trim '(#\Space #\Tab #\Newline)
                        (subseq (first mem) (search " " (first mem)))) lab))
           (get-op-code (rest mem) lab)))
    ((equal (read-from-string (first mem)) 'inp)
     (cons 901 (get-op-code (rest mem) lab)))
    ((equal (read-from-string (first mem)) 'out)
     (cons 902 (get-op-code (rest mem) lab)))
    ((equal (read-from-string (first mem)) 'hlt)
     (cons 000 (get-op-code (rest mem) lab)))
    ((equal (read-from-string (first mem)) 'dat)
     (if (equal (string-trim '(#\Space #\Tab #\Newline) (first mem)) "dat")
       (cons 000 (get-op-code (rest mem) lab))
       (cons (find-addr (string-trim '(#\Space #\Tab #\Newline)
                          (subseq (first mem) (search " " (first mem)))) lab)
             (get-op-code (rest mem) lab))))
    (T (cons (first mem) (remove-labels (rest mem) lab)))))

;; trova indirizzo: se la stringa è un numero ritorna l'integer
;; altrimenti trova il valore corrispondente alla label
(defun find-addr (string lab)
  (if (numberp (read-from-string string))
    (parse-integer string)
    (position (read-from-string string) lab)))
(defun pad-mem (lst)
  (append lst (make-list (- 100 (length lst)) :initial-element 0)))

(defun lmc-load (file-name)
  (let ((formatted-lst (format-list (lmc-open-file file-name))))
    (let ((label-lst (parse-labels formatted-lst)))
      (pad-mem
       (get-op-code
        (remove-labels formatted-lst label-lst) label-lst)))))

(defun lmc-run (file-name inp)
  (execution-loop (list 'state
                        :acc 0
                        :pc 0
                        :mem (lmc-load file-name)
                        :in inp
                        :out ()
                        :flag 'noflag)))
