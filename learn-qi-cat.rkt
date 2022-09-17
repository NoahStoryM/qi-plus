#lang racket

(require qi/cat
         rackunit)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 1. Covalues
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#|
Covalues is just the Values tagged with natural numbers.
|#

;;; n<
(check-pred covalues? (~> (123) 1<))
(check-pred covalues? (~> (123) 2<))
(check-pred covalues? (~> (123) 3<))

;;; ◁, ▷ and +n<
(check-eq? (~> (123) 1< ▷ cdr)     0)
(check-eq? (~> (123) 1< ▷ car (_)) 123)

(check-eq? (~> (123) 2< ▷ cdr)     1)
(check-eq? (~> (123) 2< ▷ car (_)) 123)

(check-eq? (~> (123) 3< ▷ cdr)     2)
(check-eq? (~> (123) 3< ▷ car (_)) 123)

(check-eq? (~> (123) (n< 6) ▷ cdr)     5)
(check-eq? (~> (123) (n< 6) ▷ car (_)) 123)

(check-pred covalues? (~> (123) (clos _) (cons 0) ◁))
(check-pred covalues? (~> (123) (clos _) (cons 1) ◁))
(check-pred covalues? (~> (123) (clos _) (cons 2) ◁))

(check-eq? (~> (123) 1< +4< ▷ cdr) 4) ; 4 = (1 - 1) + 4
(check-eq? (~> (123) 2< +4< ▷ cdr) 5) ; 5 = (2 - 1) + 4
(check-eq? (~> (123) 3< +4< ▷ cdr) 6) ; 6 = (3 - 1) + 4

(check-eq? (~> (123) 3< (+n<  4) ▷ cdr) 6) ; 6 = (3 - 1) +  4
(check-eq? (~> (123) 3< (+n< -1) ▷ cdr) 1) ; 1 = (3 - 1) + -1
(check-eq? (~> (123) 3< (+n<  0) ▷ cdr) 2) ; 2 = (3 - 1) +  0
(check-eq? (~> (123) 3< -1< ▷ cdr)      1) ; 1 = (3 - 1) + -1
(check-eq? (~> (123) 3< +0< ▷ cdr)      2) ; 2 = (3 - 1) +  0
(check-eq? (~> (123) 3< -0< ▷ cdr)      2) ; 2 = (3 - 1) +  0


#|
Procedures can be regarded as the morphisms between Covalues.
|#

;;; quotient/remainder : Integer × Integer -> Integer × Integer
(check-eq? (procedure-arity          quotient/remainder) 2)
(check-eq? (procedure-coarity        quotient/remainder) 1)
(check-eq? (procedure-result-coarity quotient/remainder) 1)

(check-eq? (procedure-coarity        (☯ 5<)) 1)
(check-eq? (procedure-result-coarity (☯ 5<)) 5)

(check-eq? (procedure-coarity        (☯ +5<)) 1)
(check-eq? (procedure-result-coarity (☯ +5<)) 6)

(check-eq? (procedure-coarity        (☯ -5<)) 6)
(check-eq? (procedure-result-coarity (☯ -5<)) 1)


#|
For f : A + B -> V + W and g : C + D -> X + Y, there are
 f+g  = (==+ f g) : A + B + C + D ->  V + W  +  X + Y
<f|g> = (>-  f g) : A + B + C + D -> (V + W) ∪ (X + Y)
|#

;;; add1 : Number -> Number
;;; sub1 : Number -> Number
(check-eq? (procedure-coarity        add1) 1)
(check-eq? (procedure-result-coarity add1) 1)

(check-eq? (procedure-coarity        sub1) 1)
(check-eq? (procedure-result-coarity sub1) 1)

;;;  add1 + sub1  : Number + Number -> Number + Number
;;; <add1 | sub1> : Number + Number -> Number
(check-eq? (procedure-coarity        (☯ (==+ add1 sub1))) 2)
(check-eq? (procedure-result-coarity (☯ (==+ add1 sub1))) 2)

(check-eq? (procedure-coarity        (☯ (>-  add1 sub1))) 2)
(check-eq? (procedure-result-coarity (☯ (>-  add1 sub1))) 1)

(check-eq? (~> (0) 1< (==+ add1 sub1) ▷ cdr)      0)
(check-eq? (~> (0) 1< (==+ add1 sub1) ▷ car (_))  1)

(check-eq? (~> (0) 2< (==+ add1 sub1) ▷ cdr)      1)
(check-eq? (~> (0) 2< (==+ add1 sub1) ▷ car (_)) -1)

(check-eq? (~> (0) 1< (>-  add1 sub1))  1)
(check-eq? (~> (0) 2< (>-  add1 sub1)) -1)

;; (☯ (fanout 3)) = (☯ (-< _ _ _))
;; (☯ (fanin  3)) = (☯ (>- _ _ _))

;;; !!! WARNING !!!
(check-eq? (procedure-coarity        (π (_) (==+ add1 sub1))) 1)
(check-eq? (procedure-result-coarity (π (_) (==+ add1 sub1))) 1)

(check-eq? (~> (0) 1< (esc (π (_) (==+ add1 sub1))) ▷ cdr)      0)
(check-eq? (~> (0) 1< (esc (π (_) (==+ add1 sub1))) ▷ car (_))  1)

(check-eq? (~> (0) 2< (esc (π (_) (==+ add1 sub1))) ▷ cdr)      1)
(check-eq? (~> (0) 2< (esc (π (_) (==+ add1 sub1))) ▷ car (_)) -1)


#|
We'll use
1 to represent the identity element of Values,
0 to represent the identity element of Covalues.

A
= 1 × A = A × 1
= 0 + A = A + 0

2 = 1 + 1
3 = 1 + 1 + 1
...
N = 1 + ... + 1
|#


;;; _ : * -> *
;;; ⏚ : * -> 1
;;; We can use ==* and ⏚ to do the same things as n>.

;; (==* _ ⏚ ⏚) : (A×B×C -> A) = (A×B×C -> A×1×1)
;; (==* ⏚ _ ⏚) : (A×B×C -> B) = (A×B×C -> 1×B×1)
;; (==* ⏚ ⏚ _) : (A×B×C -> C) = (A×B×C -> 1×1×C)

(check-eq? (~> (1 2 3) 1>) 1)
(check-eq? (~> (1 2 3) 2>) 2)
(check-eq? (~> (1 2 3) 3>) 3)

(check-eq? (~> (1 2 3) (==* _ ⏚ ⏚)) 1)
(check-eq? (~> (1 2 3) (==* ⏚ _ ⏚)) 2)
(check-eq? (~> (1 2 3) (==* ⏚ ⏚ _)) 3)


;;; Similarly:
;;; ≂ : 0 -> *
;;; We can use ==+ and ≂ to do the same things as n<.

;; (==+ _ ≂ ≂) : (A -> A+B+C) = (A+0+0 -> A+B+C)
;; (==+ ≂ _ ≂) : (B -> A+B+C) = (0+B+0 -> A+B+C)
;; (==+ ≂ ≂ _) : (C -> A+B+C) = (0+0+C -> A+B+C)

(check-eq? (~> (123) 1< ▷ cdr) 0)
(check-eq? (~> (123) 2< ▷ cdr) 1)
(check-eq? (~> (123) 3< ▷ cdr) 2)

(check-eq? (~> (123) (==+ _ ≂ ≂) ▷ cdr) 0)
(check-eq? (~> (123) (==+ ≂ _ ≂) ▷ cdr) 1)
(check-eq? (~> (123) (==+ ≂ ≂ _) ▷ cdr) 2)


;;; Differences
(check-eq? (procedure-coarity        (☯ 2<)) 1)
(check-eq? (procedure-result-coarity (☯ 2<)) 2)

(check-eq? (procedure-coarity        (☯ (==+ ≂ _ ≂))) 1)
(check-eq? (procedure-result-coarity (☯ (==+ ≂ _ ≂))) 3)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 2. Distributive Law
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; Products distribute over Sums.

(let ()
  ;;; For example, (A×B)+(A×C) and A×(B+C) are isomorphic:

  (define  d (>>> 2)) ; (A×B)+(A×C) -> A×(B+C)
  (define ¬d (<<< 2)) ; A×(B+C) -> (A×B)+(A×C)

  ;; (>>> n) : move the tag from input to its nth element.
  ;; (<<< n) : move the tag from the nth element to input.

  (check-equal?
   (~> ("A" "B")  ;  "A" × "B"
       (==+ _ ≂)) ; ("A" × "B") + ("A" × "C")
   (~> ("A" "B")         ;  "A" × "B"
       (==* _ (==+ _ ≂)) ;  "A" × ("B" + "C")
       ¬d))              ; ("A" × "B") + ("A" × "C")

  (check-equal?
   (~> ("A" "B") ;  "A" × "B"
       (==+ _ ≂) ; ("A" × "B") + ("A" × "C")
       d         ;  "A" × ("B" + "C")
       ▽)
   (~> ("A" "B")            ;  "A" × "B"
       (==* _ (==+ _ ≂))    ;  "A" × ("B" + "C")
       ▽)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 3. Conditional
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; 1 + 1 + ... + 1 (N) has n elements, so it's isomorphic to
;;; the types with n elements.

(let ()
  ;;; For example, Boolean is isomorphic to 1 + 1:
  (define (true?  arg) (eq? #t arg))
  (define (false? arg) (eq? #f arg))

  (define 1+1->bool (☯ (>- #f #t)))
  (define bool->1+1 (☯ (=< false? true?)))

  (check-eq? (~> (#f) bool->1+1 ▷ cdr)       0)
  (check-eq? (~> (#f) bool->1+1 ▷ car (_) ▽) '())

  (check-eq? (~> (#t) bool->1+1 ▷ cdr)       1)
  (check-eq? (~> (#t) bool->1+1 ▷ car (_) ▽) '())

  (check-eq? (~> () 1< 1+1->bool) #f)
  (check-eq? (~> () 2< 1+1->bool) #t))

(let ()
  ;;; "a" ∪ "b" ∪ "c" is isomorphic to 1 + 1 + 1:
  (define 1+1+1->abc (☯ (>- "a" "b" "c")))
  (define abc->1+1+1 (☯ (=< (equal? "a") (equal? "b") (equal? "c"))))

  (check-eq? (~> ("c") abc->1+1+1 ▷ cdr)       2)
  (check-eq? (~> ("c") abc->1+1+1 ▷ car (_) ▽) '())

  (check-equal? (~> () 1< 1+1+1->abc) "a")
  (check-equal? (~> () 2< 1+1+1->abc) "b")
  (check-equal? (~> () 3< 1+1+1->abc) "c"))


;;; 1 + 1 + ... + 1 can be used for conditional:
(let ()
  (define min
    (λ (x y)
      (cond
        [(<= x y) x]
        [(>  x y) y])))

  (check-eq? (min 1 1) 1)
  (check-eq? (min 2 1) 1)
  (check-eq? (min 1 2) 1))

(let ()
  (define min
    (☯                     ;       x × y
      (~> (-< (=< <= >) _) ; (1 + 1) × (x × y)
          (<<< 1)          ; (x × y) + (x × y)
          (>- 1> 2>))))    ;       x ∪ y

  (check-eq? (min 1 1) 1)
  (check-eq? (min 2 1) 1)
  (check-eq? (min 1 2) 1))


#|
The values stored in covalues can also be a covalues,
so that (1 + 1) + (1 + 1) isn't the same as 1 + 1 + 1 + 1.
This is because in some cases it's difficult to figure out
which tag should be used.

For example:
(define ¬d (<<< 1)) ; (A+B)×(C+D) -> A×(C+D) + B×(C+D)

It seems that ¬d should convert the input to
the covalues tagged with 1 if the 1st element is of type B.
But if A is 1, it seems that the input should be tagged with 2:
(1+B)×(C+D) -> 1×(C+D) + B×(C+D) = C + D + B×(C+D)
|#

;;; To convert (1 + 1) + ... to 1 + 1 + ..., we can use (==+ _ ≂).

(let ()
  (define *and*
    (☯                             ;       B × B
      (~> (==* bool->1+1 bool->1+1) ; (1 + 1) × (1 + 1)
          (<<< 1)                   ; (1 + 1) + (1 + 1)
          (<> (==+ _ ≂))            ;   1 + 1 + 1 + 1
          (>- #t #f #f #f))))       ;   t ∪ f ∪ f ∪ f
  (check-eq? (*and* #f #f) #t)
  (check-eq? (*and* #f #t) #f)
  (check-eq? (*and* #t #f) #f)
  (check-eq? (*and* #t #t) #f)

  (define *or*
    (☯                             ;       B × B
      (~> (==* bool->1+1 bool->1+1) ; (1 + 1) × (1 + 1)
          (<<< 1)                   ; (1 + 1) + (1 + 1)
          (<> (==+ _ ≂))            ;   1 + 1 + 1 + 1
          (>- #t #t #t #f))))       ;   t ∪ t ∪ t ∪ f
  (check-eq? (*or* #f #f) #t)
  (check-eq? (*or* #f #t) #t)
  (check-eq? (*or* #t #f) #t)
  (check-eq? (*or* #t #t) #f))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 4. Iteration and Recursion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; It's common to define a local loop procedure for iteration.
;;; For example:
(let ()
  (define factorial
    (λ (n)
      (define loop
        (λ (p m)
          (cond
            [(=  m 0) p]
            [(>= m 1) (loop (* p m) (sub1 m))])))
      (loop 1 n)))

  (check-eq? (factorial 0) 1)
  (check-eq? (factorial 1) 1)
  (check-eq? (factorial 2) 2)
  (check-eq? (factorial 3) 6)
  (check-eq? (factorial 4) 24)
  (check-eq? (factorial 5) 120))

;;; With covalues, we can combine factorial and loop together.
;;; If the argument of factorial is
;;;   1. tagged with 0 or no tag, it's the input of factorial.
;;;   2. tagged with 1, it's the input of loop.
;;;   3. tagged with 2, it's the result.
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
            _)))) ; p

  (check-eq? (factorial 0) 1)
  (check-eq? (factorial 1) 1)
  (check-eq? (factorial 2) 2)
  (check-eq? (factorial 3) 6)
  (check-eq? (factorial 4) 24)
  (check-eq? (factorial 5) 120))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5. Maybe
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#|
Maybe type is very common in purely functional languages.
With covalues, we can use 1 + A to represent (Maybe A).

Traditional Racket programs use (Option A) -- #f ∪ A --
which causes confusion when #f is an element of A.

Since 1 + A != A, (Maybe A) is more useful than (Option A).
|#

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

  (define h (☯ (~> f (>- _ g))))

  (check-equal? (~> (0)   h (fanin 2) ▽) '())
  (check-equal? (~> (100) h (fanin 2) ▽) '())
  (check-equal? (~> (123) h (fanin 2) ▽) '(123))

  (check-equal? (~> (0)   h maybe->list) '())
  (check-equal? (~> (100) h maybe->list) '())
  (check-equal? (~> (123) h maybe->list) '(123))

  (check-equal? (~> (0)   h maybe->option) #f)
  (check-equal? (~> (100) h maybe->option) #f)
  (check-equal? (~> (123) h maybe->option) 123))


(let ()
  (define lookup
    (λ (ls)
      (☯
        (~> (assoc ls)
            (-< _ (=< not #t))
            (<<< 2)
            (==+ ⏚ cadr)))))
  (define map-maybe (λ (f) (☯ (~> △ (>< (~> f (fanin 2))) ▽))))
  (check-equal?
   ((map-maybe (lookup '([1 "11"] [2 "22"] [3 "33"])))
    '(1 3 5))
   '("11" "33")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6. Natural Number Object
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#|
We can use the tag of covalues (n) to indicate that
applying a procedure n times.

f0 = f0
f1 = t∘f0
f2 = t∘t∘f0
...
fn = t∘...∘t∘f0
|#

(let ()
  (define t  add1)
  (define f0 string->number)
  (define f1 (☯ (~> f0 t)))
  (define f2 (☯ (~> f0 t t)))

  (define f  (f0->f f0 t))
  (define f8 (☯ (~> 9< f)))

  (check-eq? (~> ("1") f0) 1)
  (check-eq? (~> ("1") f1) 2)
  (check-eq? (~> ("1") f2) 3)
  (check-eq? (~> ("1") f8) 9))

;;; f0 is `values' by default.
(check-eq? (~> (1) (n< 123) (esc (f0->f add1))) 123)


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

  (define h (☯ (~> f (>- _ g))))

  ;;; Since (Maybe A) is just 1 + A, we can use f0->f to
  ;;; map t : A -> B to f : 1 + A -> 1 ∪ B

  (check-equal? (~> (0)   h (esc (f0->f number->string)) ▽) '())
  (check-equal? (~> (100) h (esc (f0->f number->string)) ▽) '())
  (check-equal? (~> (123) h (esc (f0->f number->string)) ▽) '("123")))


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

  ;;; map t : A -> 1 + B to f : 1 + A -> 1 + B
  (define h (☯ (~> f (esc (f0->f g)))))

  (check-equal? (~> (0)   h maybe->list) '())
  (check-equal? (~> (100) h maybe->list) '())
  (check-equal? (~> (123) h maybe->list) '(123))

  (check-eq? (~> (0)   h maybe->option) #f)
  (check-eq? (~> (100) h maybe->option) #f)
  (check-eq? (~> (123) h maybe->option) 123))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7. Recursive Types
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#|
Compared to other data structures, Values and Covalues
may be more suitable for Qi code.
|#


(require racket/fixnum)
(let ()
  ;;; A simple interpreter written in Racket style:
  (struct Exp ())
  (struct Int  Exp (value))
  (struct Prim Exp (op arg*))

  ;; parser : S-Exp -> Exp
  (define parser
    (λ (code)
      (match code
        [(? fixnum? n) (Int n)]
        [`(,rator ,rands ...)
         (Prim rator (map parser rands))])))

  (define (interp-exp e)
    (match e
      [(Int n) n]
      [(Prim 'read '()) (read)]
      [(Prim '- (list e)) (fx- 0 (interp-exp e))]
      [(Prim '+ e*) (apply fx+ (map interp-exp e*))]))

  (check-equal? (~> ('(+ 1 2 (- 4) 3)) parser interp-exp) 2))

(let ()
  ;;; Same interpreter written in Qi style:

  ;; Exp : Fixnum + 1 + Exp + Exp × ... × Exp
  ;; parser : S-Exp -> Exp
  (define parser
    (λ (code)
      (match code
        [(? fixnum? n) (~> (n) 1<)]
        [`(read) (~> () 2<)]
        [`(- ,e) (~> (e) parser 3<)]
        [`(+ ,e* ...) (~> (e*) △ (>< parser) 4<)])))

  (define-flow (interp-exp e)
    (>- _
        read
        (~> interp-exp (fx- 0 _))
        (~> (>< interp-exp) fx+)))

  (check-equal? (~> ('(+ 1 2 (- 4) 3)) parser interp-exp) 2))


(let ()
  ;;; (Pair A) = A × (List A)
  ;;; (List A) = 1 + (Pair A)
  ;;;          = 1 + A × (List A)

  (define list->List
    (let ([list->List (λ _ (apply list->List _))])
      (☯
        (~> (-< _ (=< null? pair?))
            (<<< 2)
            (==+ ⏚ (-< car (~> cdr list->List)))))))

  (define List->list
    (let ([List->list (λ _ (apply List->list _))])
      (☯ (>- '() (~> (==* _ List->list) cons)))))
  (check-equal? (~> ('(1 2 3)) list->List List->list) '(1 2 3))

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
  (check-equal? (~> ('(1 2 3)) list->List (Map sub1) List->list) '(0 1 2))

  (define Cons (☯ 2<))
  (define Car  (☯ (>- (raise-argument-error 'Car "pair?" '()) 1>)))
  (define Cdr  (☯ (>- (raise-argument-error 'Cdr "pair?" '()) 2>)))
  (check-equal? (~> ('(1 2 3)) list->List Car)                   1)
  (check-equal? (~> ('(1 2 3)) list->List Cdr List->list)        '(2 3))
  (check-equal? (~> ('(1 2 3)) list->List Cdr Car)               2)
  (check-equal? (~> ('(1 2 3)) list->List (Cons 0 _) List->list) '(0 1 2 3)))

#| Tricks

(List A) = 1 + A × (List A)
(List A) = 1 + A × (1 + A × (List A))
(List A) ≅ 1 + A + A × A × (List A)
...
(List A) ≅ 1 + A + A × A + A × A × A + ...


(List A) ≅ 1 + A × (List A)
(List A) - A × (List A) ≅ 1
(1 - A) × (List A) ≅ 1
(List A) ≅ 1 / (1 - A)
(List A) ≅ 1 + A + A × A + A × A × A + ...

|#


(let ()
  ;;; Nat = 1 + Nat
  ;;; 0 = 1
  ;;; 1 = 1 + (1)
  ;;; 2 = 1 + (1 + (1))
  ;;; 3 = 1 + (1 + (1 + (1)))

  (define num->nat
    (let ([num->nat (λ _ (apply num->nat _))])
      (☯
        (~> (-< _ (=< zero? exact-positive-integer?))
            (<<< 2)
            (==+ ⏚ (~> sub1 num->nat 1<))))))
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
                (~> (-< 1> (==* (~> eq? bool->1+1) _)) ; Var × (1 + 1) × (Box Val) × Env
                    (<<< 2)
                    (>- (~> (==* id ⏚ id) lookup-variable-value)
                        (~> 2> unbox))))))))


  (define env
    (~> () empty-environment
        (-< 'a 0 _) extend-environment
        (-< 'b 1 _) extend-environment))

  (check-eq? (~> (env) (-< 'a _) lookup-variable-value) 0)
  (check-eq? (~> (env) (-< 'b _) lookup-variable-value) 1))