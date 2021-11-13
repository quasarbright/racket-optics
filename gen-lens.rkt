#lang racket

(require racket/generic)

(provide gen:lens
         lens?
         lens-view
         lens-set
         lens-transform
         (rename-out [lens/c/st lens/c]))

;; A [Lens S T] is a getter and a setter on a structure S with a single target T
(define-generics lens
  ;; Get the target of the lens in structure `s`
  (lens-view lens s)
  ;; Set the target of the lens in structure `s` to `t`
  (lens-set lens s t)
  ;; Transform the target of the lens in structure `s` by applying `f` to the target
  (lens-transform lens s f)
  #:fallbacks [(define/generic super-view lens-view)
               (define/generic super-set lens-set)
               (define/generic super-transform lens-transform)
               (define (lens-transform lens s f) (super-set lens s (f (super-view lens s))))
               (define (lens-set lens s t) (super-transform lens s (const t)))])

;; A lens with structure s/c and target t/c
(define (lens/c/st s/c t/c)
  (make-flat-contract
   #:name `(lens/c ,s/c ,t/c)
   #:first-order (lens/c [lens-view (-> lens? s/c t/c)]
                         [lens-set (-> lens? s/c t/c s/c)]
                         [lens-transform (-> lens? s/c (-> t/c t/c) s/c)])))
