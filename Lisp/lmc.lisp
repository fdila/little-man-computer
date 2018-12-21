(defun one-instruction (state)
  (let
    ((acc (nth 2 state))
     (pc (nth 4 state))
     (mem (nth 6 state))
     (in (nth 8 state))
     (out (nth 10 state))
     (flag (nth 12 state)))
    (let
      ((inst (nth pc mem))
       (new-pc (mod (+ pc 1) 100)))
      (cond
        ;; ADD
        ((and (> inst 99) (< inst 200))
         (let ((sum (+ acc (nth (- inst 100) mem))))
           (if (< sum 1000)
             (list 'state
                   :acc sum
                   :pc new-pc
                   :mem mem
                   :in in
                   :out out
                   :flag 'noflag)
             (list 'state
                   :acc (mod sum 1000)
                   :pc new-pc
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
                   :pc new-pc
                   :mem mem
                   :in in
                   :out out
                   :flag 'noflag)
             (list 'state
                   :acc (mod sub 1000)
                   :pc new-pc
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
                 :pc new-pc
                 :mem mem
                 :in in
                 :out out
                 :flag flag)))
        ))
    )
  )
