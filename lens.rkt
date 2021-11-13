#lang racket

(require "./gen-lens.rkt")

(provide (all-from-out "./gen-lens.rkt") ; re-export from gen-lens
         (contract-out [make-lens (-> (-> any/c any/c) (-> any/c any/c any/c) lens?)])
         (contract-out [lens-compose (->* () #:rest (listof lens?) lens?)]))

(struct simple-lens (view set)
  #:methods gen:lens
  [(define (lens-view l s) ((simple-lens-view l) s))
   (define (lens-set l s t) ((simple-lens-set l) s t))])


;; alias for constructor
(define make-lens simple-lens)

;; A lens whose structure and target are the same value. setting just returns the structure
(define identity-lens (simple-lens identity (lambda (s t) t)))

;; Compose lenses, outermost lens first, innermost last
;; Composing a [Lens S T1] and a [Lens T1 T] produces a [Lens S T]
;; Ex: (lens-compose rectangle-top-left posn-x) focuses on the x-coordinate of the left side of a rectangle
(define (lens-compose . lenses)
  (define (lens-compose/bin outer inner)
    (make-lens (lambda (s) (lens-view inner (lens-view outer s)))
               (lambda (s t-inner) (lens-transform outer s (lambda (t-middle) (lens-set inner t-middle t-inner))))))
  ;; Need to flip arguments because foldl takes in the accumulator second. So the left argument is the current
  ;; one, which is always the next innermost lens
  (define (lens-compose/bin/flipped inner outer) (lens-compose/bin outer inner))
  (foldl lens-compose/bin/flipped identity-lens lenses))


(module+ example
  (provide car-lens cdr-lens)
  (define car-lens (make-lens car (lambda (p x) (cons x (cdr p)))))
  (define cdr-lens (make-lens cdr (lambda (p x) (cons (car p) x)))))

(module+ test
  (require (submod ".." example)
           rackunit)
  (test-equal? "view car"
               (lens-view car-lens (cons 1 2))
               1)
  (test-equal? "view cdr"
               (lens-view cdr-lens (cons 1 2))
               2)
  (test-equal? "view id"
               (lens-view identity-lens 'a)
               'a)
  (test-equal? "set car"
               (lens-set car-lens (cons 1 2) 3)
               (cons 3 2))
  (test-equal? "set cdr"
               (lens-set cdr-lens (cons 1 2) 3)
               (cons 1 3))
  (test-equal? "set id"
               (lens-set identity-lens 'a 3)
               3)
  (test-equal? "transform car"
               (lens-transform car-lens (cons 1 #t) add1)
               (cons 2 #t))
  (test-equal? "transform cdr"
               (lens-transform cdr-lens (cons #t 1) add1)
               (cons  #t 2))
  (test-equal? "transform id"
               (lens-transform identity-lens 3 add1)
               4)
  (test-equal? "car.cdr view"
               (lens-view (lens-compose car-lens cdr-lens) (cons (cons 'a 1) 'b))
               1)
  (test-equal? "car.cdr set"
               (lens-set (lens-compose car-lens cdr-lens) (cons (cons #f 1) #f) 10)
               (cons (cons #f 10) #f))
  (test-equal? "car.cdr.cdr view"
               (lens-view (lens-compose car-lens cdr-lens cdr-lens) (cons (cons #f (cons #f 1)) #f))
               1)
  (test-equal? "car.cdr.cdr set"
               (lens-set (lens-compose car-lens cdr-lens cdr-lens) (cons (cons #f (cons #f 1)) #f) 2)
               (cons (cons #f (cons #f 2)) #f))
  (test-equal? "car.cdr.cdr transform"
               (lens-transform (lens-compose car-lens cdr-lens cdr-lens) (cons (cons #f (cons #f 1)) #f) add1)
               (cons (cons #f (cons #f 2)) #f))
  (test-equal? "car.id view"
               (lens-view (lens-compose car-lens identity-lens) (cons 1 2))
               1)
  (test-equal? "car.id set"
               (lens-set (lens-compose car-lens identity-lens) (cons 1 2) 'a)
               (cons 'a 2))
  (test-equal? "id.car view"
               (lens-view (lens-compose identity-lens car-lens) (cons 1 2))
               1)
  (test-equal? "id.car set"
               (lens-set (lens-compose identity-lens car-lens) (cons 1 2) 'a)
               (cons 'a 2))
  (test-equal? "id.id.car.id.cdr.id.id transform"
               (lens-transform (lens-compose identity-lens
                                             identity-lens
                                             car-lens
                                             identity-lens
                                             cdr-lens
                                             identity-lens
                                             identity-lens)
                               (cons (cons 'a 1) 'b)
                               add1)
               (cons (cons 'a 2) 'b)))

