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
             (and (> inst 399) (< inst 600)))
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
         (let ((pc-branch (nth (- inst 600) mem)))
           (list 'state
                 :acc acc
                 :pc pc-branch
                 :mem mem
                 :in in
                 :out out
                 :flag flag)))
        ;; BRANCH IF ZERO
        ((and (> inst 699) (< inst 800))
         (let ((pc-branch (nth (- inst 700) mem)))
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
         (let ((pc-branch (nth (- inst 800) mem)))
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
           (list 'state
                 :acc acc-new
                 :pc pc-inc
                 :mem mem
                 :in in-new
                 :out out
                 :flag flag)))
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
               :flag flag))
        ))
    )
  )
