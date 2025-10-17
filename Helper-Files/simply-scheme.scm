;; These are helper functions needed for UC Berkely's SICP style Comp Sci course
#lang scheme
;; STRING MANIPULATION AND METHODS

;; LIST MANIPULATION
; LENGTH of a List
(define (length list-arg ) 
  (if (null? list-arg)
   0 
   (+ 1 (length (cdr list-arg)))
  )
)
; MAP a list
;; Takes a list and a lambda and applies it starting at the 0 index and returns a list of the manipulation
(define (list-map list-arg func)
  (if (null? list-arg)
    '()
    (cons (func (car list-arg)) 
        (list-map (cdr list-arg) func)
    )
  )
)
;FILTER a list to a set parameter
(define (list-filter list-arg func)
  (if (null? list-arg)
    '()
    (if (func (car list-arg))
      (cons (car list-arg) (list-filter (cdr list-arg) func)) ;; keep if
      (list-filter (cdr list-arg) func)                       ;; skip it
    )
  )
)

;List Append 
(define (list-append list-arg1 list-arg2)
  (if 
   (null? list-arg1) 
    list-arg2
    ;; Below we Create a list of chain individual list elements to attach to the front of list-arg2
    ;; (append-list '(1 2) '(3 4)) => (cons 1 (append-list '(2) '(3 4))) =>(cons 1 (cons 2 (append-list '() '(3 4))))
    (cons (car list-arg1) (list-append (cdr list-arg1) list-arg2))
  )
)
REDUCE a list
(define (list-reduce list-arg func)
  (cond
    ((null? (cdr list-arg)) (car list-arg)) ; base case: one element left
    (else 
     (list-reduce 
      (cons (func (car list-arg) (cadr list-arg)) (cddr list-arg)) ; first argument combines first two, recurse the rest(cddr)
      func)
      )
  )
)
;; -----------------------------------------------
;; 🧠 Pair and List Accessors in Scheme (Quick Guide)
;;
;; (car lst)     ; first element of lst
;; (cdr lst)     ; rest of lst after the first
;;
;; Combinations (nested access):
;; (cadr lst)    ; second element       = (car (cdr lst))
;; (caddr lst)   ; third element        = (car (cdr (cdr lst)))
;; (cadddr lst)  ; fourth element       = (car (cdr (cdr (cdr lst))))
;;
;; (cdar lst)    ; cdr of the first element = (cdr (car lst))
;; (cddr lst)    ; drop first two elements  = (cdr (cdr lst))
;; (cdddr lst)   ; drop first three         = (cdr (cdr (cdr lst)))
;;
;; You can chain up to four levels:
;; (caadr lst)   ; = (car (car (cdr lst)))
;; (cadar lst)   ; = (car (cdr (car lst)))
;; (cdadr lst)   ; = (cdr (car (cdr lst)))
;; (caddr lst)   ; = (car (cdr (cdr lst)))
;;
;; Example:
;; (define cards '(A 2 3 4))
;; (car cards)    ; A
;; (cadr cards)   ; 2
;; (cddr cards)   ; (3 4)
;; (caddr cards)  ; 3
;;
;; Tip: Think of "a" as "access" (car) and "d" as "drop" (cdr)
;; -----------------------------------------------


(list-reduce (cons (+ '(1) '(2)) (3 4)))
; Takes a string and returns its 0 index
(define (first s) (car s))
; Takes a string and removes 0 index
(define (bf s) (cdr s))
; Rename for map
(define (every fn seq)
  (map fn seq))
(define (word . args)
  (string->symbol
    (apply string-append
      (map (lambda (x)
        (cond ((string? x) x)
          ((number? x) (number->string x))
          ((symbol? x) (symbol->string x))
          (else (error "Invalid argument to word"))))
      args))))
