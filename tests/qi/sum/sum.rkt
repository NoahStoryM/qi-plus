#lang racket

(require qi/sum
         rackunit)


(let ()
  ;;  t : #t
  ;;  f : #f
  ;;  B : t ∪ f
  ;;  1 : (values)
  ;;  d : (A×B)+(A×C) -> A×(B+C)
  ;; ¬d : A×(B+C) -> (A×B)+(A×C)
  (define  d (>>> 2))
  (define ¬d (<<< 2))
  (define string->symbol/list
    (☯                                      ; str × (t ∪ f) = str × B
      (~> (==* id bool->1+1)                ; str × (1 + 1)
          ¬d                                ; str + str
          (==+ string->list string->symbol) ; lst + sym
          (>- _ _))))                       ; lst ∪ sym
  (check-equal? (values->list (string->symbol/list "hello" #t)) '(hello))
  (check-equal? (values->list (string->symbol/list "hello" #f)) '((#\h #\e #\l #\l #\o))))


(for ([f
       (in-list
        (list
         (☯                                ;   1 + 1 + 1 + 1
           (~> (==+ (>- #f #t) (>- #f #t)) ;       B + B
               (==+ (-< #f id) (-< #t id)) ; (f × B) + (t × B)
               (>- _ _)))                  ; (f × B) ∪ (t × B) = B × B

         (☯
           (~> (==+ (~> (>- #f #t) (-< #f id))
                    (~> (>- #f #t) (-< #t id)))
               (>- _ _)))

         (☯
           (~> (==+ (~> (>- #f #t) (-< #f id))
                    (~> (>- #f #t) (-< #t id)))
               (fanin 2)))
         ))])

  (check-equal? (values->list (~> () 1< f)) '(#f #f))
  (check-equal? (values->list (~> () 2< f)) '(#f #t))
  (check-equal? (values->list (~> () 3< f)) '(#t #f))
  (check-equal? (values->list (~> () 4< f)) '(#t #t))

  (check-equal? (values->list (~> () (==+ _ ≂ ≂ ≂) f)) '(#f #f))
  (check-equal? (values->list (~> () (==+ ≂ _ ≂ ≂) f)) '(#f #t))
  (check-equal? (values->list (~> () (==+ ≂ ≂ _ ≂) f)) '(#t #f))
  (check-equal? (values->list (~> () (==+ ≂ ≂ ≂ _) f)) '(#t #t)))


(for ([¬f
       (in-list
        (list
         (☯                                ;       B × B
           (~> (==* bool->1+1 id)          ; (1 + 1) × B
               (<<< 1)                     ;       B + B
               (==+ bool->1+1 bool->1+1))) ;   1 + 1 + 1 + 1

         (☯                              ;       B × B
           (~> (==* bool->1+1 bool->1+1) ; (1 + 1) × (1 + 1)
               (<<< 1)                   ; (1 + 1) + (1 + 1)
               (==+ +0< +1<)))           ;   1 + 1 + 1 + 1

         (☯                              ;       B × B
           (~> (==* bool->1+1 bool->1+1) ; (1 + 1) × (1 + 1)
               (<<< 1)                   ; (1 + 1) + (1 + 1)
               (==+ (==+ _ ≂) _)))       ;   1 + 1 + 1 + 1

         (☯                              ;       B × B
           (~> (==* bool->1+1 bool->1+1) ; (1 + 1) × (1 + 1)
               (<<< 1)                   ; (1 + 1) + (1 + 1)
               (<> (==+ _ ≂))))          ;   1 + 1 + 1 + 1
         ))])

  (define *n* (☯ (~> ¬f (>- 1 2 3 4))))
  (check-eq? (*n* #f #f) 1)
  (check-eq? (*n* #f #t) 2)
  (check-eq? (*n* #t #f) 3)
  (check-eq? (*n* #t #t) 4)

  (define *and* (☯ (~> ¬f (>- #t #f #f #f))))
  (check-eq? (*and* #f #f) #t)
  (check-eq? (*and* #f #t) #f)
  (check-eq? (*and* #t #f) #f)
  (check-eq? (*and* #t #t) #f))


(for ([t
       (in-list
        (list
         (λ (arg)
           (cond
             [(number? arg) 'number]
             [(string? arg) 'string]))

         (☯                             ;     num ∪ str
           (~> (=< number? string?)     ;       1 + 1
               (==+ 'number 'string)    ; 'number + 'string
               (fanin 2)))              ; 'number ∪ 'string

         (☯                             ;     num ∪ str
           (~> (=< number? string?)     ;       1 + 1
               (>- 'number 'string)))   ; 'number ∪ 'string
         ))])
  (check-equal? (t 123) 'number)
  (check-equal? (t "0") 'string))


(for ([t
       (in-list
        (list
         (λ (arg)
           (cond
             [(number? arg) (- arg)]
             [(string? arg) (string-append "-" arg)]))

         (☯                                  ;     num ∪ str
           (~> (-< (=< number? string?) _)   ; (1 + 1) × (num ∪ str)
               (<<< 1)                       ;     num + str
               (==+ - (string-append "-" _)) ;     num + str
               (fanin 2)))                   ;     num ∪ str
         ))])
  (check-equal? (t 123) -123)
  (check-equal? (t "0") "-0"))


(for ([min
       (in-list
        (list
         (λ (arg1 arg2)
           (cond
             [(<= arg1 arg2) arg1]
             [(>  arg1 arg2) arg2]))

         (☯                             ;          real × real
           (~> (-< (=< <= >) _)         ;       (1 + 1) × (real × real)
               (<<< 1)                  ; (real × real) + (real × real)
               (==+ 1> 2>)              ;          real + real
               (fanin 2)))              ;          real ∪ real
         ))])
  (check-eq? (min  123  123)  123)
  (check-eq? (min -123  123) -123)
  (check-eq? (min  123 -123) -123))


(for ([i (in-list '(1 2 3 4))])
  (check-eq? (~> (i) (n< i) ▷ cdr) (sub1 i))
  (check-eq? (~> (i) (n< i) ▷ car (_)) i)
  (check-eq? (~> (1) (n< i) ((f0->f add1) _)) i)
  (check-eq? (~> ("1") (n< i) (f0->f string->number add1)) i))


(for ([factorial
       (in-list
        (list
         (λ (n)
           (define loop
             (λ (p m)
               (cond
                 [(=  m 0) p]
                 [(>= m 1) (loop (* p m) (sub1 m))])))
           (loop 1 n))

         (let ()
           (define factorial
             (let ([factorial (λ _ (apply factorial _))])
               (☯ ; n + p × m + p
                 (>- (~>             ; n
                       (-< 1 _)      ; p × m  (p = 1, m = n)
                       +1< factorial)
                     (~>                                ;   p × m
                       (==* _ (-< _ (=< (>= 1) (= 0)))) ;   p × m   × (1 + 1)
                       (<<< 3)                          ;   p × m   +  p × m
                       (==+ (-< * (~> 2> sub1)) 1>)     ; p*m × m-1 +  p
                       +1< factorial)
                     _ ; p
                     ))))
           factorial)

         (let ()
           (define-flow (factorial n)  ; n + p × m + p
             (>- (~> (-< 1 _) +1< factorial)
                 (~>                                ;   p × m
                   (==* _ (-< _ (=< (>= 1) (= 0)))) ;   p × m   × (1 + 1)
                   (<<< 3)                          ;   p × m   +  p × m
                   (==+ (-< * (~> 2> sub1)) 1>)     ; p*m × m-1 +  p
                   +1< factorial)
                 _))
           factorial)

         #;(☯
             (~> (let/cc (==* _ _ 1))           ; loop × n × res
                 (if (~> 2> zero?)
                     3>
                     (~> (==* _ (-< _ _) _)     ; loop × n × n × res
                         (==* (-< _ _) sub1 *)  ; loop × loop × (sub1 n) × (* n res)
                         (_ _ _ _)))))

         #;(☯
             (~> (let/cc (==* _ _ 1))           ; loop × n × res
                 (==* _ (-< _ (=< zero? #t)) _) ; loop × n × (1 + 1) × res
                 (<<< 3)                        ; loop × n × res + loop × n × res
                 (==+ 3>                        ;            res + (loop loop (sub1 n) (* n res))
                      (~> (==* _ (-< _ _) _)
                          (==* (-< _ _) sub1 *)
                          (_ _ _ _)))
                 (fanin 2)))))])

  (check-eq? (factorial 0) 1)
  (check-eq? (factorial 1) 1)
  (check-eq? (factorial 2) 2)
  (check-eq? (factorial 3) 6)
  (check-eq? (factorial 4) 24)
  (check-eq? (factorial 5) 120)
  (check-eq? (factorial 6) 720)
  (check-eq? (factorial 7) 5040)
  (check-eq? (factorial 8) 40320)
  (check-eq? (factorial 9) 362880))


(let ()
  (define f
    (☯                           ; Int
      (~> (-< _ (=< (= 0) #t))   ; Int × (1 + 1)
          (<<< 2)                ; Int + Int
          (==+ ⏚ _))))           ; 1 + Int

  (define g
    (☯                           ; Int
      (~> (-< _ (=< (= 100) #t)) ; Int × (1 + 1)
          (<<< 2)                ; Int + Int
          (==+ ⏚ _))))           ; 1 + Int

  (for ([h
         (in-list
          (list
           (☯ (~> f (>- _ g)))
           (☯ (~> f (esc (f0->f g))))
           ))])

    (check-equal? (~> (0)   h (fanin 2) ▽) '())
    (check-equal? (~> (100) h (fanin 2) ▽) '())
    (check-equal? (~> (123) h (fanin 2) ▽) '(123))

    (check-equal? (~> (0)   h maybe->list) '())
    (check-equal? (~> (100) h maybe->list) '())
    (check-equal? (~> (123) h maybe->list) '(123))

    (check-eq? (~> (0)   h maybe->option) #f)
    (check-eq? (~> (100) h maybe->option) #f)
    (check-eq? (~> (123) h maybe->option) 123)

    (check-equal? (~> (0)   h (esc (f0->f number->string)) ▽) '())
    (check-equal? (~> (100) h (esc (f0->f number->string)) ▽) '())
    (check-equal? (~> (123) h (esc (f0->f number->string)) ▽) '("123"))))

(let ()
  (define map-maybe (λ (f) (☯ (~> △ (>< (~> f (fanin 2))) ▽))))
  (define lookup
    (λ (ls)
      (☯
        (~> (assoc _ ls)
            (-< _ (=< not #t))
            (<<< 2)
            (==+ ⏚ cadr)))))
  (check-equal? ((map-maybe (lookup '([1 "11"] [2 "22"] [3 "33"])))
                 '(1 3 5))
                '("11" "33")))

(let ()
  ;;; (Pair A) = A × (List A)
  ;;; (List A) = 1 + (Pair A)

  (define list->List
    (let ([list->List (λ _ (apply list->List _))])
      (☯
        (~> (-< _ (=< null? pair?))
            (<<< 2)
            (==+ ⏚ (-< car (~> cdr list->List)))))))

  (define List->list
    (let ([List->list (λ _ (apply List->list _))])
      (☯ (>- '() (~> (==* _ List->list) cons)))))

  (~> ('(1 2 3)) list->List List->list) ; '(1 2 3)

  (define (Map f)
    ;; g : (Pair A) -> (Pair A)
    ;; h : (List A) -> (List A)
    (define-values (g h)
      (let ([g (λ _ (apply g _))]
            [h (λ _ (apply h _))])
        (values
         (☯ (==* f h))
         (☯ (==+ _ g)))))
    h)

  (check-equal? (~> ('(1 2 3)) list->List (Map sub1) List->list)
                '(0 1 2)))

(let ()
  ;;; Nat = 1 + Nat
  ;;; 0 = 1
  ;;; 1 = 1 + (1)             != 1 + 1
  ;;; 2 = 1 + (1 + (1))       != 1 + 1 + 1
  ;;; 3 = 1 + (1 + (1 + (1))) != 1 + 1 + 1 + 1

  (define num->nat
    (let ([num->nat (λ _ (apply num->nat _))])
      (☯
        (~> (-< _ (=< zero? exact-positive-integer?))
            (<<< 2)
            (==+ ⏚ (~> sub1 (clos num->nat) (cons _ 0) ◁))))))
  (define nat->num
    (let ([nat->num (λ _ (apply nat->num _))])
      (☯ (>- 0 (~> nat->num add1)))))

  (check-eq? (~> (9) num->nat nat->num) 9))

(let ()
  ;;; Env : 1 + Var × (Box Val) × Env


  ;; empty-environment : * -> Env
  (define empty-environment (☯ (~> ⏚ 1<)))

  ;; extend-environment : Var × Val × Env -> Env
  (define extend-environment (☯ (~> (==* id box id) 2<)))

  ;; lookup-variable-value : Var × Env -> Val
  (define lookup-variable-value
    (let ([lookup-variable-value (λ _ (apply lookup-variable-value _))])
      (☯
        (~> (<<< 2) ; Var + Var × Var × (Box Val) × Env
            (>- (error
                 'lookup-variable-value
                 "no value found for key\n  key: ~a" _)
                (~> (-< 1> (group 2 (~> eq? bool->1+1) _)) ; Var × (1 + 1) × (Box Val) × Env
                    (<<< 2)
                    (>- (~> (==* id ⏚ id) lookup-variable-value)
                        (~> 2> unbox))))))))


  (define env
    (~> () empty-environment
        (-< 'a 0 _) extend-environment
        (-< 'b 1 _) extend-environment))

  (check-eq? (~> (env) (-< 'a _) lookup-variable-value) 0)
  (check-eq? (~> (env) (-< 'b _) lookup-variable-value) 1))