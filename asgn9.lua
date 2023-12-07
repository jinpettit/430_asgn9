print("Hello World")

--[[ExprC : different expression types
;ExprC : different expression types
(define-type ExprC (U NumC IdC StrC CondC BlamC AppC))
(struct NumC ([n : Real]) #:transparent)
(struct IdC ([s : Symbol]) #:transparent)
(struct StrC([s : String]) #:transparent)
(struct CondC ([if : ExprC] [then : ExprC] [else : ExprC]) #:transparent)
(struct BlamC([args : (Listof Symbol)] [body : ExprC]) #:transparent)
(struct AppC ([fun : ExprC] [args : (Listof ExprC)]) #:transparent)

;Binding and Env
(struct Binding ([name : Symbol] [val : Value]) #:transparent)
(define-type Env (Listof Binding))
(define mt-env '())
(define extend-env cons)

;lookup var looking for in environment
(define (lookup [for : Symbol] [env : Env]) : Value
  (match env
    ['() (error 'lookup "PAIG: name not found: ~e" for)]
    [(cons (Binding name val) r) (cond
                                   [(symbol=? for name) val]
                                   [else (lookup for r)])]))

(check-exn (regexp (regexp-quote "lookup"))
           (lambda () (lookup 'x '())))

;Value type
(define-type Value (U NumV BoolV StrV CloV PrimV))
(struct NumV ([n : Real]) #:transparent)
(struct BoolV ([b : Boolean]) #:transparent)
(struct StrV ([val : String]) #:transparent)
(struct CloV ([args : (Listof Symbol)] [body : ExprC] [env : Env]) #:transparent)
(struct PrimV ([val : (-> (Listof Value) Value)]) #:transparent)

;adding two num values together
(define (num+ [args : (Listof Value)]) : Value
  (match args
    [(list (? NumV? a) (? NumV? b)) (NumV (+ (NumV-n a) (NumV-n b)))]
    [else (error 'num+ "PAIG: one argument was not a number")]))

;subtracting two num values together
(define (num- [args : (Listof Value)]) : Value
  (match args
    [(list (? NumV? a) (? NumV? b)) (NumV (- (NumV-n a) (NumV-n b)))]
    [else (error 'num- "PAIG: one argument was not a number")]))

;multiplying two num values together
(define (num* [args : (Listof Value)]) : Value
  (match args
    [(list (? NumV? a) (? NumV? b)) (NumV (* (NumV-n a) (NumV-n b)))]
    [else (error 'num* "PAIG: one argument was not a number")]))

;dividing two num values together
(define (num/ [args : (Listof Value)]) : Value
  (match args
    [(list (? NumV? a) (? NumV? b))
     (cond
       [(equal? (NumV-n b) 0) (error 'num/ "PAIG: divide by zero")]
       [else (NumV (/ (NumV-n a) (NumV-n b)))])]
    [else (error 'num/ "PAIG: one argument was not a number")]))

;checking if one value less than or equal to second
(define (num<= [args : (Listof Value)]) : Value
  (match args
    [(list (NumV left) (NumV right)) (BoolV (<= left right))]
    [else (error 'num<= "PAIG: one argument was not a number")]))

;comparator - checking if two values the same
(define (equal [args : (Listof Value)]) : Value
  (cond
    [(equal? (length args) 2)
     (match args
       [(list (NumV left) (NumV right)) (BoolV (equal? left right))]
       [(list (StrV left) (StrV right)) (BoolV (equal? left right))]
       [(list (BoolV left) (BoolV right)) (BoolV (equal? left right))]
       [else (BoolV #f)])]
    [else (error 'equal "PAIG: more than 2 args")]))
    
;returns user-error and serialization of error
(define (user-error [args : (Listof Value)]) : Value
  (match args
    [(list arg) (error 'user-error "PAIG: user-error: ~e" (serialize arg))]
    [else (error 'user-error "PAIG: one argument was not a number")]))

; top-env to bind identifiers
(define top-env
  (list
   (Binding '+ (PrimV num+))
   (Binding '- (PrimV num-))
   (Binding '* (PrimV num*))
   (Binding '/ (PrimV num/))
   (Binding '<= (PrimV num<=))
   (Binding 'equal? (PrimV equal))
   (Binding 'error (PrimV user-error))
   (Binding 'true (BoolV #t))
   (Binding 'false (BoolV #f))))

; serialize accepts any PAIG5 value and return a string
(define (serialize [v : Value]) : String
  (match v
    [(NumV n) (~v n)]
    [(BoolV b)
     (if b "true" "false")]
    [(StrV str) (~v str)]
    [(CloV args body env) "#<procedure>"]
    [(PrimV s) "#<primop>"]))

;interp function for exprs and funcitons
(define (interp [exp : ExprC] [env : Env]) : Value
  (match exp
    [(NumC n) (NumV n)]
    [(IdC n) (lookup n env)]
    [(StrC s) (StrV s)]
    [(CondC cond then else)
     (match (interp cond env)
       [(BoolV #t) (interp then env)]
       [(BoolV #f) (interp else env)]
       [else (error 'interp "PAIG: not boolean")])]
    [(BlamC args body) (CloV args body env)]
    [(AppC f args)
     (define f-value (interp f env))
     (cond
       [(CloV? f-value)
        (cond
          [(equal? (length args) (length (CloV-args f-value)))
           (define arg-vals (map (λ (arg) (interp (cast arg ExprC) env)) args))
           (define new-env (env-extend (CloV-args f-value) arg-vals (CloV-env f-value)))
           (interp (CloV-body f-value) new-env)]
          [else (error 'interp "PAIG: args not equal")])]
       [(PrimV? f-value) ((PrimV-val f-value) (map (λ ([val : ExprC]) : Value (interp val env)) args))]
       [else (error 'interp "PAIG: illegal function")])]))

;extends the environment when calling app
(define (env-extend [args : (Listof Symbol)] [vals : (Listof Value)] [env : Env]) : Env
  (cond
    [(empty? args) env]
    [else (env-extend (rest args) (rest vals) (cons (Binding (first args) (first vals)) env))]))

;checks if its a valid id
(define (valid-id? [s : Any]) : Boolean
  (cond
    [(or (equal? s 'as)
         (equal? s 'with)
         (equal? s 'blam)
         (equal? s '?)
         (equal? s 'else:))]
    [else false]))

;maps Sexp to ExprC
(define (parse [s : Sexp]) : ExprC
  (match s
    [(? real? n) (NumC n)]
    [(? symbol? n) (cond
                     [(not (valid-id? n)) (IdC (cast n Symbol))]
                     [else (error 'parse "PAIG: invalid id ~e" n)])]
    [(? string? s) (StrC s)]
    [(list a '? b 'else: c) (CondC (parse a) (parse b) (parse c))]
    [(list 'blam (list (? symbol? args) ...) body)
     (cond [(equal? (length args) (length (remove-duplicates args)))
            (BlamC (cast args (Listof Symbol)) (parse body))]
           [else (error 'parse "PAIG: duplicates args")])]
    [(list 'with (list a 'as (? symbol? b)) ... ': c)
     (cond [(equal? (length b) (length (remove-duplicates b)))
            (cond [(equal? (length (filter valid-id? b)) 0)
                   (AppC (BlamC (cast b (Listof Symbol)) (parse c)) (map parse (cast a (Listof Sexp))))]
                  [else (error 'parse "PAIG: invalid id bindings")])]
           [else (error 'parse "PAIG: duplicates args")])]
    [(list fun args ...) (AppC (parse fun) (map parse args))]
    [other (error 'parse "PAIG: invalid input, ~e" other)]))

--]]