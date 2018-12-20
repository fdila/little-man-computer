;(defun state (&key acc pc)
;  (list 'state acc pc))
;(defun h-state (&key acc pc)
;  (list 'h-state acc pc))
;
;  (cond ((eql (nth 0 state) 'state)
;    (state :acc (+ (nth 1 state) (nth 2 state)) :pc (+ (nth 2 state) 1)))))

(defun one-instruction (state)
  (let
    ((acc (nth 2 state))
     (pc (nth 4 state))
     (mem (nth 6 state))
     (in (nth 8 state))
     (out (nth 10 state))
     (flag (nth 12 state)))
  (+ acc pc)))
