(defconstant +bicond+ '<=>)
(defconstant +cond+ '=>)
(defconstant +and+ '^)
(defconstant +or+ 'v)
(defconstant +not+ '¬)

(defun truth-value-p (x)
  (or (eql x T) (eql x NIL)))

(defun unary-connector-p (x)
  (eql x +not+))

(defun binary-connector-p (x)
  (or (eql x +bicond+)
      (eql x +cond+)))

(defun n-ary-connector-p (x)
  (or (eql x +and+)
      (eql x +or+)))

(defun connector-p (x)
  (or (unary-connector-p x)
      (binary-connector-p x)
      (n-ary-connector-p x)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 1.1 
;; Predicado para determinar si una expresión en LISP 
;; es un literal positivo  
;; 
;; RECIBE   : expresión  
;; EVALÚA A : T si la expresión es un literal positivo,  
;;            NIL en caso contrario.  
;;
(defun positive-literal-p (x) 
  (if (and (atom x) (not (connector-p x)) (not (truth-value-p x)))
      T
    nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 1.2 
;; Predicado para determinar si una expresión 
;; es un literal negativo  
;; 
;; RECIBE   : expresión x  
;; EVALÚA A : T si la expresión es un literal negativo,  
;;  
(defun negative-literal-p (x)
  (and (listp x)
       ;; needs to be a list
       (eql +not+ (first x)) ;; whose first element is the connector not
       (null (rest (rest x))) ;; with only two elements
       (positive-literal-p (second x)))) ;; second element is a positive literal

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 1.3 
;; Predicado para determinar si una expresión es un literal   
;; 
;; RECIBE   : expresión x   
;; EVALÚA A : T si la expresión es un literal,  
;;            NIL en caso contrario.  
;;
(defun literal-p (x)
  (or (negative-literal-p x) ( positive-literal-p x)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Predicado para determinar si una expresión está en formato prefijo
;;
;; RECIBE : expresión x
;; EVALÚA A : T si x está en formato prefijo, NIL en caso contrario.
;;
(defun wff-prefix-p (x)
  (unless (null x) ;; NIL no es FBF en formato prefijo (por convención)
    (or (literal-p x) ;; Un literal es FBF en formato prefijo
        (and (listp x) ;; En caso de que no sea un literal debe ser una lista
             (let ((connector (first x))
                   (rest_1 (rest x)))
               (cond
                ((unary-connector-p connector) ;; Si el primer elemento es un connector unario
                 (and (null (rest rest_1)) ;; debería tener la estructura (<conector> FBF)
                      (wff-prefix-p (first rest_1))))
                ((binary-connector-p connector) ;; Si el primer elemento es un conector binario
                 (let ((rest_2 (rest rest_1))) ;; debería tener la estructura
                   (and (null (rest rest_2)) ;; (<conector> FBF1 FBF2)
                        (wff-prefix-p (first rest_1))
                        (wff-prefix-p (first rest_2)))))
                ((n-ary-connector-p connector) ;; Si el primer elemento es un conector enario
                 (or (null rest_1) ;; conjunción o disyunción vacías
                     (and (wff-prefix-p (first rest_1)) ;; tienen que ser FBF los operandos
                          (let ((rest_2 (rest rest_1)))
                            (or (null rest_2) ;; conjunción o disyunción con un elemento
                                (wff-prefix-p (cons connector rest_2)))))))
                (t NIL))))))) ;; No es FBF en formato prefijo


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 1.4 
;; Predicado para determinar si una expresión está en formato prefijo  
;; 
;; RECIBE   : expresión x  
;; EVALÚA A : T si x está en formato prefijo,  
;;            NIL en caso contrario.  
;;
(defun wff-infix-p (wff &optional last_connector)
  (unless (null wff)
    (or (literal-p wff)
        (and (listp wff)
             (let ((operand_1 (first wff))
                   (connector (first (rest wff)))
                   (rest_1 (rest wff)))
               (cond
                ((unary-connector-p connector) nil)
                ((binary-connector-p connector)
                 (let ((operand_2 (rest rest_1)))
                   (and (not (null operand_2))
                        (null (rest operand_2))
                        (wff-infix-p operand_1)
                        (wff-infix-p (first operand_2)))))
                ((n-ary-connector-p connector)
                 (let* ((operand_2 (rest rest_1))
                        (next_connector (first (rest operand_2))))
                   (and (not (null operand_2))
                        (or (null (rest operand_2)) 
                            (binary-connector-p next_connector)
                            (n-ary-connector-p next_connector))
                        (if (null last_connector)
                            t
                          (eql connector last_connector))
                        (wff-infix-p operand_1)
                        (if (null (rest operand_2))
                            (wff-infix-p (first operand_2) connector)
                          (wff-infix-p (cons (first operand_2) (rest operand_2)) connector)))))
                (t NIL)))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;  
;; Convierte FBF en formato prefijo a FBF en formato infijo 
;; 
;; RECIBE   : FBF en formato prefijo  
;; EVALÚA A : FBF en formato infijo 
;; 
(defun prefix-to-infix (wff) 
  (when (wff-prefix-p wff) 
    (if (literal-p wff) 
        wff 
      (let ((connector      (first wff)) 
            (elements-wff (rest wff))) 
        (cond 
         ((unary-connector-p connector)  
          (list connector (prefix-to-infix (second wff)))) 
         ((binary-connector-p connector)  
          (list (prefix-to-infix (second wff)) 
                connector 
                (prefix-to-infix (third wff)))) 
         ((n-ary-connector-p connector)  
          (cond  
           ((null elements-wff)  wff)  ;;; conjunción o disyunción vacías.  
           ;;; no tienen traducción a formato infijo 
           ((null (cdr elements-wff))  ;;; conjunción o disyunción con un único elemento 
            (prefix-to-infix (car elements-wff)))  
           (t (cons (prefix-to-infix (first elements-wff))  
                    (mapcan #'(lambda(x) (list connector (prefix-to-infix x)))  
                      (rest elements-wff)))))) 
         (t NIL)))))) ;; no debería llegar a este paso nunca


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; Ejercicio 1.5
;; Convierte FBF en formato infijo a FBF en formato prefijo 
;; 
;; RECIBE   : FBF en formato infijo  
;; EVALÚA A : FBF en formato prefijo 
;; 
(defun infix-to-prefix (wff)
  (when (wff-infix-p wff)
    (if (literal-p wff)
        wff
      (let ((operand_1 (first wff))
            (connector (second wff)))
        (cond
         ((unary-connector-p (first wff))
          (list (first wff) (infix-to-prefix (second wff))))
         ((binary-connector-p connector)
          (list connector
                (infix-to-prefix operand_1)
                (infix-to-prefix (third wff))))
         ((n-ary-connector-p connector)
          (cons connector 
                (cons (infix-to-prefix operand_1)
                      (mapcan #'(lambda(x)
                                  (unless (connector-p x)
                                    (list (infix-to-prefix x))))
                        (rest (rest wff))))))
         (t NIL))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 1.6 
;; Predicado para determinar si una FBF es una cláusula   
;; 
;; RECIBE   : FBF en formato prefijo  
;; EVALÚA A : T si FBF es una cláusula, NIL en caso contrario.
;;
(defun clause-p (wff)
  (unless (or (atom wff) (not (wff-prefix-p wff)))
    (let ((connector (first wff))
          (rest_1 (rest wff)))
      (cond
       ((eql connector +or+)
        (cond 
         ((null rest_1)
          T)
         ((literal-p (first rest_1))
          (let ((rest_2 (rest rest_1)))
            (clause-p (cons connector rest_2))))
         (T NIL)))
       (T NIL)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 1.7 
;; Predicado para determinar si una FBF está en FNC   
;; 
;; RECIBE   : FFB en formato prefijo  
;; EVALÚA A : T si FBF está en FNC con conectores,  
;;            NIL en caso contrario.  
;;
(defun cnf-p (wff) 
  (unless (or (atom wff) (not (wff-prefix-p wff)))
    (let ((connector (first wff))
          (rest_1 (rest wff)))
      (cond
       ((eql connector +and+)
        (cond 
         ((null rest_1)
          T)
         (T (and (clause-p (first rest_1)) (cnf-p (cons connector (rest rest_1)))))))
       (T nil)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 2.1: Incluya comentarios en el código adjunto  ;; 
;; Dada una FBF, evalúa a una FBF equivalente  
;; que no contiene el connector <=> 
;; 
;; RECIBE   : FBF en formato prefijo  
;; EVALÚA A : FBF equivalente en formato prefijo  
;;            sin connector <=> 
(defun eliminate-bicondicional (wff) 
  (if (or (null wff) (literal-p wff)) ;; Si la wff es un literal, devuelve el literal
      wff 
    (let ((connector (first wff))) 
      (if (eq connector +bicond+) ;; Si el conector es efectivamente un bicondicional
          (let ((wff1 (eliminate-bicondicional (second wff))) ;; Elimina bicondicionales del primer operando
                (wff2 (eliminate-bicondicional (third  wff)))) ;; Elimina bicondicionales del segundo operando
            (list +and+  
                  (list +cond+ wff1 wff2) ;; Sustituye por la definicion de bicondicional
                  (list +cond+ wff2 wff1))) 
        (cons connector  ;; Si no es un bicondicional, deja wff en formato prefijo, eliminando bicondicionales del resto
              (mapcar #'eliminate-bicondicional (rest wff)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 2.2 
;; Dada una FBF, que contiene conectores => evalúa a 
;; una FBF equivalente que no contiene el connector => 
;; 
;; RECIBE   : wff en formato prefijo sin el connector <=>  
;; EVALÚA A : wff equivalente en formato prefijo  
;;            sin el connector => 
(defun eliminate-condicional (wff)
  (if (or (null wff) (literal-p wff))
      wff
    (let ((connector (first wff)))
      (if (eq connector +cond+)
          (let ((wff1 (eliminate-condicional (second wff)))
                (wff2 (eliminate-condicional (third wff))))
            (list +or+
                  (list +not+ wff1) 
                  wff2))
        (cons connector
              (mapcar #'eliminate-condicional (rest wff)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 2.3 
;; Dada una FBF, que no contiene los conectores <=>, =>  
;; evalúa a una FNF equivalente en la que la negación   
;; aparece únicamente en literales negativos 
;; 
;; RECIBE   : FBF en formato prefijo sin conector <=>, =>  
;; EVALÚA A : FBF equivalente en formato prefijo en la que  
;;            la negación  aparece únicamente en literales  
;;            negativos. 
;; 
(defun exchange-and-or (connector) 
  (cond 
   ((eq connector +and+) +or+)     
   ((eq connector +or+) +and+) 
   (t connector)))

(defun reduce-scope-of-negation (wff)
  (if (or (null wff) (literal-p wff) (atom wff))
      wff
    (let ((connector (first wff)))
      (if (eq connector +not+)
          (if (negative-literal-p (second wff))
              (second (second wff))
            (if (listp (second wff))
                (mapcar #'niega-todo (second wff))))
        (append (list (reduce-scope-of-negation (first wff))) (reduce-scope-of-negation (rest wff)))))))

(defun niega-todo (lst)
  (if (null lst)
      lst
    (cond
     ((eql lst +or+) (append +and+))
     ((eql lst +and+) (append +or+))
     ((negative-literal-p lst) (second lst))
     ((positive-literal-p lst) (list +not+ lst))
     ((listp lst) (mapcar #'niega-todo lst)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 2.4: Comente el código adjunto + escriba pseudocódigo
;;
;; Dada una FBF, que no contiene los conectores <=>, => en la
;; que la negación aparece únicamente en literales negativos
;; evalúa a una FNC equivalente en FNC con conectores ^, v
;;
;; RECIBE : FBF en formato prefijo sin conector <=>, =>,
;; en la que la negación aparece únicamente
;; en literales negativos
;; EVALÚA A : FBF equivalente en formato prefijo FNC
;; con conectores ^, v
;;
(defun combine-elt-lst (elt lst) 
  (if (null lst) 
      (list (list elt)) ;; Si no es una lista, construye lista de un solo elemento
    (mapcar #'(lambda (x) (cons elt x)) lst))) ;; Combina el elemento con los de la lista


(defun exchange-NF (nf)
  (if (or (null nf) (literal-p nf))  ;; Un literal esta en forma normal
      nf 
    (let ((connector (first nf))) 
      (cons (exchange-and-or connector) ;; Cambia el tipo de conector
            (mapcar #'(lambda (x)       ;; y lo concatena al resto de la nf
                        (cons connector x)) 
              (exchange-NF-aux (rest nf))))))) 

(defun exchange-NF-aux (nf) 
  (if (null nf)  
      NIL 
    (let ((lst (first nf))) 
      (mapcan #'(lambda (x)  
                  (combine-elt-lst  ;; Combina el primer elemento de nf
                   x                ;; con el resto de la lista, aplicando NF
                   (exchange-NF-aux (rest nf))))  
        (if (literal-p lst) (list lst) (rest lst)))))) 

(defun simplify (connector lst-wffs ) 
  (if (literal-p lst-wffs) 
      lst-wffs                     
    (mapcan #'(lambda (x)  
                (cond  
                 ((literal-p x) (list x)) 
                 ((equal connector (first x)) 
                  (mapcan  
                      #'(lambda (y) (simplify connector (list y)))  
                    (rest x)))  
                 (t (list x))))                
      lst-wffs))) 

(defun cnf (wff) 
  (cond 
   ((cnf-p wff) wff) ;; Ya es una cnf
   ((literal-p wff)               ;; Un literal es una cnf
    (list +and+ (list +or+ wff))) ;; Si es disyuncion de conjunciones
   ((let ((connector (first wff)))  
      (cond 
       ((equal +and+ connector)  ;; Si es un and, agrupa clausulas comunes
        (cons +and+ (simplify +and+ (mapcar #'cnf (rest wff))))) 
       ((equal +or+ connector)   ;; Si es un or, añade un and para conseguir la disyuncion
        (cnf (exchange-NF (cons +or+ (simplify +or+ (rest wff)))))))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 2.5
;; Dada una FBF en FNC
;; evalúa a lista de listas sin conectores
;; que representa una conjunción de disyunciones de literales
;;
;; RECIBE : FBF en FNC con conectores ^, v
;; EVALÚA A : FBF en FNC (con conectores ^, v eliminaos)
;;

(defun eliminate-connectors (cnf) 
  (unless (null cnf)
    (if (n-ary-connector-p (first cnf))
        (eliminate-connectors (rest cnf))
      (if (literal-p (first cnf))
          (append (list (first cnf)) (eliminate-connectors (rest cnf)))
        (if (listp (first cnf))
            (append (list (eliminate-connectors (first cnf)))(eliminate-connectors (rest cnf))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 2.6
;; Dada una FBF en formato infijo
;; evalúa a lista de listas sin conectores
;; que representa la FNC equivalente
;;
;; RECIBE : FBF
;; EVALÚA A : FBF en FNC (con conectores ^, v eliminados)
;;
(defun wff-infix-to-cnf (wff)
  (unless (null wff)
    (unless (null (wff-infix-p wff))
      (eliminate-connectors 
       (cnf 
        (reduce-scope-of-negation 
         (eliminate-condicional 
          (eliminate-bicondicional 
           (infix-to-prefix wff)))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 3.1.1
;; eliminación de literales repetidos una cláusula
;;
;; RECIBE : K - cláusula (lista de literales, disyunción implícita)
;; EVALÚA A : cláusula equivalente sin literales repetidos
;;
(defun repeated-literal-p (lit lst)
  (unless (null lst)
    (if (equal lit (first lst))
        T
      (repeated-literal-p lit (rest lst)))))

(defun eliminate-repeated-literals (k) 
  (unless (null k)
    (if (repeated-literal-p (first k) (rest k))
        (eliminate-repeated-literals (rest k))
      (append (list (first k)) (eliminate-repeated-literals (rest k))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 3.1.2 
;; eliminación de cláusulas repetidas en una FNC  
;;  
;; RECIBE   : cnf - FBF en FNC (lista de cláusulas, conjunción implícita) 
;; EVALÚA A : FNC equivalente sin cláusulas repetidas  
;; 
(defun eliminate-repeated-clauses (cnf) 
  (eliminate-repeated-clauses-aux-2 (eliminate-repeated-clauses-aux cnf)))

(defun eliminate-repeated-clauses-aux (cnf)
  (unless (null cnf)
    (append (list (eliminate-repeated-literals (first cnf)))
            (eliminate-repeated-clauses-aux(rest cnf)))))

(defun eliminate-repeated-clauses-aux-2 (cnf)
  (unless (null cnf)
    (if (search-for-element (first cnf) (rest cnf))
        (eliminate-repeated-clauses-aux-2 (rest cnf))
      (append (list (first cnf))(eliminate-repeated-clauses-aux-2 (rest cnf))))))

(defun search-for-element (elem lst)
  (unless (null lst)
    (if (search-for-element-aux elem (first lst))
        (if (search-for-element-aux (first lst) elem)
            T
          (search-for-element elem (rest lst)))
      (search-for-element elem (rest lst)))))

(defun search-for-element-aux (elem1 elem2)
  (if (null elem1)
      T
    (if (repeated-literal-p (first elem1) elem2)
        (search-for-element-aux (rest elem1) elem2)
      nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 3.2.1
;; Predicado que determina si una cl??usula es subsumida por otra
;;
;; RECIBE
;; K1, K2 cl??usulas
;; EVALUA a : K2 si K1 es subsumida por K2
;;
;;NIL en caso contrario
;;
(defun search-element (elem list)
  (unless (null list)
    (if (equal elem (first list))
        T
      (search-element elem (rest list)))))

(defun subsumed (K1 K2) 
  (cond ((subsumed-aux K2 K1)
         k2)
        (t nil)))

(defun subsumed-aux (K1 K2)
  (if (null K1)
      T
    (if (search-element (first K1) K2)
        (subsumed-aux (rest K1) K2))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 3.2.2 
;; eliminación de cláusulas subsumidas en una FNC  
;;  
;; RECIBE   : K (cláusula), cnf (FBF en FNC) 
;; EVALÚA A : FBF en FNC equivalente a cnf sin cláusulas subsumidas  
;; 
(defun subsumed-in-list (k cnf)
  (unless (null cnf)
    (let ((subsumed-k (subsumed k (first cnf)))
          (subsumed-k-2 (subsumed (first cnf) k)))
      (cond
       ((not (null subsumed-k))
        subsumed-k)
       ((not (null subsumed-k-2))
        subsumed-k-2)
       (t (subsumed-in-list k (rest cnf)))))))

(defun eliminate-subsumed-clauses (cnf) 
  (unless (null cnf)
    (let ((subsumed-k (subsumed-in-list (first cnf) (rest cnf))))
      (if (null subsumed-k)
          (append (list (first cnf)) (eliminate-subsumed-clauses (rest cnf)))
        (eliminate-subsumed-clauses (eliminate-repeated-clauses
                                     (append (rest cnf) (list subsumed-k))))))))

 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 3.3.1 
;; Predicado que determina si una clausula es tautología 
;; 
;; RECIBE   : K (cláusula) 
;; EVALUA a : T si K es tautología 
;;            NIL en caso contrario 
;; 
(defun tautology-p (K)
  (unless (null k)
    (if (tautology-p-aux (first K) (rest K))
        T
      (tautology-p (rest K)))))

(defun tautology-p-aux (K lst)
  (unless (null lst)
    (cond
     ((positive-literal-p K)
      (if (negative-literal-p (first lst))
          (if (equal K (second (first lst)))
              T
            (tautology-p-aux K (rest lst)))
        (tautology-p-aux K (rest lst))))
     ((negative-literal-p K)
      (if (positive-literal-p (first lst))
          (if (equal K (first lst))
              T
            (tautology-p-aux K (rest lst)))
        (tautology-p-aux K (rest lst))))
     (T nil))))
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 3.3.2 
;; eliminación de cláusulas en una FBF en FNC que son tautología 
;; 
;; RECIBE   : cnf - FBF en FNC 
;; EVALÚA A : FBF en FNC equivalente a cnf sin tautologías  
;; 
(defun eliminate-tautologies (cnf)
  (unless (null cnf)
    (if (tautology-p (first cnf))
        (eliminate-tautologies (rest cnf))
      (append (list (first cnf)) (eliminate-tautologies (rest cnf))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 3.4 
;; simplifica FBF en FNC  
;;        * elimina literales repetidos en cada una de las cláusulas  
;;        * elimina cláusulas repetidas 
;;        * elimina tautologías 
;;        * elimina cláusulass subsumidas 
;;   
;; RECIBE   : cnf  FBF en FNC 
;; EVALÚA A : FNC equivalente sin cláusulas repetidas,  
;;            sin literales repetidos en las cláusulas 
;;            y sin cláusulas subsumidas 
;; 
 
(defun simplify-cnf (cnf)
  (unless (null cnf)
    (eliminate-subsumed-clauses 
     (eliminate-tautologies 
      (eliminate-repeated-clauses cnf)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 4.1.1 
;; Construye el conjunto de cláusulas lambda-neutras para una FNC  
;; 
;; RECIBE   : cnf    - FBF en FBF simplificada 
;;            lambda - literal positivo 
;; EVALÚA A : cnf_lambda^(0) subconjunto de clausulas de cnf   
;;            que no contienen el literal lambda ni ¬lambda    
;;  
(defun extract-neutral-clauses (lambda cnf)
  (unless (null cnf)
    (if (or (member lambda (first cnf) :test #'equal)
            (member (list +not+ lambda) (first cnf) :test #'equal))
        (extract-neutral-clauses lambda (rest cnf))
      (append (list (first cnf)) (extract-neutral-clauses lambda (rest cnf))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 4.1.2 
;; Construye el conjunto de cláusulas lambda-positivas para una FNC 
;; 
;; RECIBE   : cnf    - FBF en FNC simplificada 
;;            lambda - literal positivo 
;; EVALÚA A : cnf_lambda^(+) subconjunto de cláusulas de cnf  
;;            que contienen el literal lambda   
;;  
(defun extract-positive-clauses (lambda cnf)
  (unless (null cnf)
    (unless (null (positive-literal-p lambda))
      (if (member lambda (first cnf) :test #'equal)
          (append (list (first cnf)) (extract-positive-clauses lambda (rest cnf)))
        (extract-positive-clauses lambda (rest cnf))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 4.1.3 
;; Construye el conjunto de cláusulas lambda-negativas para una FNC  
;; 
;; RECIBE   : cnf    - FBF en FNC simplificada 
;;            lambda - literal positivo  
;; EVALÚA A : cnf_lambda^(-) subconjunto de cláusulas de cnf   
;;            que contienen el literal ¬lambda   
;;  
(defun extract-negative-clauses (lambda cnf)
  (unless (null cnf)
    (unless (null (positive-literal-p lambda))
      (if (member (list +not+ lambda) (first cnf) :test #'equal)
          (append (list (first cnf)) (extract-negative-clauses lambda (rest cnf)))
        (extract-negative-clauses lambda (rest cnf))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 4.2.1 
;; resolvente de dos cláusulas 
;; 
;; RECIBE   : lambda      - literal positivo 
;;            K1, K2      - cláusulas simplificadas 
;; EVALÚA A : res_lambda(K1,K2)  
;;                        - cláusula que resulta de aplicar resolución  
;;                          sobre K1 y K2, con los literales repetidos  
;;                          eliminados 
;;  
(defun resolve-on (lambda K1 K2)
  (unless (or (null k1) (null k2))
    (cond
     ((null (extract-positive-clauses lambda (list k1)))
      (if (extract-negative-clauses lambda (list k1))
          (if (extract-positive-clauses lambda (list k2))
              (union (set-difference k1 (list (list +not+ lambda)) :test #'equal)
                      (set-difference k2 (list lambda) :test #'equal)
                      :test #'equal)
            nil)
        nil))
     ((null (extract-negative-clauses lambda (list k1)))
      (if (extract-positive-clauses lambda (list k1))
          (if (extract-negative-clauses lambda (list k2))
              (union (set-difference k1 (list lambda) :test #'equal)
                     (set-difference k2 (list (list +not+ lambda)) :test #'equal)
                     :test #'equal)
            nil)
        nil))
     (t nil))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 4.2.2 
;; Construye el conjunto de cláusulas RES para una FNC  
;; 
;; RECIBE   : lambda - literal positivo 
;;            cnf    - FBF en FNC simplificada 
;;             
;; EVALÚA A : RES_lambda(cnf) con las clauses repetidas eliminadas 
;; 

(defun build-RES (lambda cnf)
  (eliminate-repeated-clauses (build-RES-aux lambda cnf)))

(defun build-RES-aux (lambda cnf)
  (unless (null cnf)
    (let ((res (build-RES-aux-2 lambda (first cnf) (rest cnf))))
      (if (null res)
          (build-RES-aux lambda (rest cnf))
        (append res (build-RES-aux lambda (rest cnf)))))))

(defun build-RES-aux-2 (lambda k1 cnf)
  (unless (or (null k1) (null cnf))
    (let ((res (resolve-on lambda k1 (first cnf))))
      (if (equal k1 
                 (reduce-scope-of-negation (append (list +not+ (first cnf)))))
          (append (list nil) (build-res-aux-2 lambda k1 (rest cnf)))
        
        (if (null res)
            (build-RES-aux-2 lambda k1 (rest cnf))
          (append (list RES) (build-RES-aux-2 lambda k1 (rest cnf))))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 5 
;; Comprueba si una FNC es SAT calculando RES para todos los 
;; átomos en la FNC  
;; 
;; RECIBE   : cnf - FBF en FNC simplificada 
;; EVALÚA A :  T  si cnf es SAT 
;;                NIL  si cnf es UNSAT 
;; 

(defun RES-SAT-p (cnf)
  (RES-SAT-p-aux cnf (extract-positive-literals cnf)))

(defun  RES-SAT-p-aux (cnf list-o-lit)
  (let ((res (build-res (first list-o-lit) cnf)))
    (if (and (not (null res)) 
             (null (first res)))
        nil
      (if (and (null res) 
               (null (rest list-o-lit)))
          t
        (RES-SAT-p-aux (simplify-cnf (append cnf res)) 
                       (rest list-o-lit))))))

(defun extract-positive-literals (cnf)
  (unless (null cnf)
    (union (positivize-literals (first cnf))
           (extract-positive-literals (rest cnf)))))

(defun positivize-literals (k)
  (unless (null k)
    (if (negative-literal-p (first k))
        (append (list (second (first k))) (positivize-literals (rest k)))
      (append (list (first k)) (positivize-literals (rest k))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; EJERCICIO 6: 
;; Resolución basada en RES-SAT-p 
;; 
;; RECIBE   : wff - FBF en formato infijo  
;;            w   - FBF en formato infijo  
;;                                
;; EVALÚA A : T   si w es consecuencia lógica de wff 
;;            NIL en caso de que no sea consecuencia lógica.   
;;    
(defun logical-consequence-RES-SAT-p (wff w)
  (not (res-sat-p (simplify-cnf 
                   (append (simplify-cnf (wff-infix-to-cnf wff))
                           (simplify-cnf (wff-infix-to-cnf 
                                          (reduce-scope-of-negation (list +not+ w))))))))) 