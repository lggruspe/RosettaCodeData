(defun 100-doors ()
  (let ((doors (make-array 100)))
    (dotimes (i 10)
      (setf (svref doors (* i i)) t))
    (dotimes (i 100)
      (format t "door ~a: ~:[closed~;open~]~%" (1+ i) (svref doors i)))))