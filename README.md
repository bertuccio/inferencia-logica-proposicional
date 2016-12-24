# inferencia-logica-proposicional
Inferencia en lógica proposicional (LISP)

1.  Predicados en LISP para definir literales, FBFs (fórmula bien formada) en 
     forma prefijo e infijo, cláusulas y FNCs (FBF en forma normal conjuntiva)
	1.1 Escriba una función LISP para determinar si una expresión es un literal positivo 

	La función positive-literal-p retorna verdadero si el argumento de entrada es un átomo, si no es un conector y si no es un valor de verdad (verdadero o falso), devolviendo nil en caso contrario.

	1.2 Escriba una función LISP para determinar si una expresión es un literal  	      negativo 

		Esta función es proporcionada en el enunciado de la práctica.	

	1.3 Escriba una función LISP para determinar si una expresión es un literal 
	
	La función literal-p hace uso de las dos funciones anteriores, positive-literal-p y negative-literal-p, devolviendo verdadero si el argumento de entrada es un literal positivo o bien uno negativo, retornando en caso contrario nil.

	1.4 Dado el código para determinar si una expresión está en formato prefijo ,
   implemente una función LISP para determinar si una expresión dada está    
                  en formato infijo 

	La función wff-infix-p comprueba si la expresión introducida como argumento está en notación infijo. A menos que esta expresión sea nil realiza una serie de comprobaciones. Si es un literal o una lista nombra al primer elemento de la lista operand_1 y al segundo connector y al resto de la lista rest_1. Si el connector es unario retorna nil (puesto que no tiene sentido una expresión con esa forma en notación infijo). En cambio, si connector es binario renombra al resto de rest_1 como operand_2. Comprueba que operand_2 no es nil y que el resto de operand_2 si lo es, que el operand_1 sea infijo y que el primer elemento de operand_2 también lo sea, devolviendo  nil en caso contrario. Si el conector es enario nombra de nuevo como operand_2 al resto de rest_1 y como next_connector al primero del resto de operand_2. Comprueba que el operand_2 no es nil y o es nil el resto de operand_2 o el conector es binario o enario, devolviendo nil. Si last_connector (parámetro opcional de la función) es null devuelve verdadero, si no, evalúa si connector es igual a last_connector. Comprueba si operand_1 es infijo y si es nil el resto de operand_2 llama recursivamente con el primer elemento de operand_2 y como parámetro opcional el connector. Si no es nil llama recursivamente a si misma con argumentos el cons creado mediante el primer elemento de operand_2 y el resto del operand_2 junto con el connector como parametro opcional.
			
	1.5 Considere el código que permite transformar FBFs en formato prefijo a 
                  FBFs en formato infijo , escriba una función LISP que permita transformar 	      FBFs en formato infijo a formato prefijo 

	La función infix-to-prefix convierte la expresión infijo pasada como argumento en notación prefijo.  Si la expresión es un literal devuelve la expresión. En caso contrario renombra como operand_1 el primer elemento de la lista y como connector al segundo elemento (la expresión es infijo). Si el primer elemento de la lista de entrada es un conector unario retorna la lista creada por ese primer elemento más el resultado por la llamada recursiva a si misma con argumento el segundo elemento. En caso contrario comprueba si connector es un conector binario, en caso afirmativo retorna la lista creada por connector, la llamada recursiva a si misma con argumento operand_1 y la llamada recursiva con el tercer elemento de la lista. En caso contrario comprueba si es n-ario devolviendo el cons formado por connector y el cons formado por la llamada recursiva con argumento operand_1 junto con el resultado de aplicar mapcan con función lambda el resultado de unless de la evaluación de connector-p y la lista creada por la función infix-to-prefix y el resto del resto de wff como argumento a la función lambda. En caso de que el conector tampoco sea enario la función retorna nil.
	1.6 Escriba una función LISP para determinar si una FBF en formato prefijo es 
                  una cláusula (disyuntiva) 
		
	La función clause-p controla que lo introducido no es un átomo, devolviendo nil en tal caso. Sobreentendiendo que el argumento de entrada es una FBF en formato prefijo, obtiene como conector el primer elemento de la lista (connector) y comprueba que es un OR, ya que las cláusulas son disyunciones. Tiene en cuenta a la cláusula vacía (v) viendo si el resto de la lista es nil (rest_1) y en caso contrario comprueba que el primer elemento del resto de la lista es un literal así hasta finalizar la lista. En ambos casos la función retorna verdadero, devolviendo nil en caso contrario.

	1.7 Escriba una función LISP para determinar si una FBF en formato prefijo  	      está en FNC 
		
	La función cnf-p comprueba como primer punto que el parámetro de entrada no es un átomo. Posteriormente verifica que el primer elemento de la lista es el conector AND,  analizando si se trata de la conjunción vacía (^) , es decir, que el resto de la lista es nil, o bien si se trata de una conjunción de cláusulas. En ambos casos la función retorna verdadero, devolviendo nil en caso contrario.










2. Algoritmo de transformación de una FBF a FNC
	2.1 Eliminación del conector bicondicional (<=> )

		Esta función es proporcionada en el enunciado de la práctica.

	2.2 Eliminación del conector condicional (=>)

	La función eliminate-condicional  retorna el elemento introducido como parámetro en caso de que sea nil o un literal. En caso de que no sea ninguna de las dos cosas,  se sobreentiende de que es una FBF en formato prefijo. Se comprueba si el primer elemento de la FBF es un condicional, y en caso de que así lo sea se crea una lista con un OR como primer elemento, como segundo elemento la llamada recursiva a la función con el segundo elemento de la lista como parámetro y finalmente la negación de la llamada recursiva a la función con el tercer elemento de la lista como parámetro. En el caso en el que el primer elemento de la lista no sea un condicional se retorna una estructura cons con el primer elemento de la lista como primer elemento del cons y como segundo elemento el retorno de mapcar con parámetro la llamada de la función con el resto de la lista de entrada.

	2.3 Reducción del ámbito del conector negación (¬ )

	La función exchange-and-or tiene como argumento un conector. Si funcionamiento es el siguiente, si el conector es un AND la función retorna un OR y viceversa, en cambio si no es ninguno de los dos retorna el conector introducido como parámetro.
		


	La función niega-todo recibe como parámetro una expresión en prefijo y la niega aplicando De Morgan. Analiza los conectores y los cambia según las leyes de De Morgan y modifica los literales negándolos, pasando de positivo a negativo y viceversa.

	La función reduce-scope-of-negation reduce la doble negación de la expresión pasada como argumento (si la tiene) usando las funciones anteriores. Analiza si el primer elemento de la expresión es un conector NOT y en caso de que el segundo elemento sea un literal negativo la función retorna el literal sin negar. En caso de que sea una lista aplica mapcar mediante recursión con argumento el segundo elemento. Si el primer conector no es NOT, realiza la recursión de 
reduce-scope-of-negation concatenando en una lista la aplicación de ésta función tanto al primer elemento de la FBF cómo al resto de ella.

	2.4 Traducir a FNC . Incluir comentarios en el código adjunto y escribir el  
                  pseudocódigo correspondiente

	La función combine-elt-list dados dos argumentos de entrada retorna la lista formada por la combinación del primer argumento  con cada uno de los elementos del segundo argumento, los elementos de la lista resultante son cons.

	La función exchange-NF recibe como argumento una expresión prefija con un conector n-ario. Retorna si es una conjunción la disyunción de la conjunción o si es una disyunción, la conjunción de la disyunción. Hace uso de la función exchange-NF-aux que va retornando cada elemento de la expresión por separado, de manera que forma la lista equivalente con la conjunción/disyunción de la disyunción/conjunción de los elementos devueltos por exchange-NF-aux.
			

	La funcion simplify dado un conector como primer argumento y una expresión del formato (conjunción/disyunción) de (disyunción/ conjunción) si el conector es igual que el primer conector de la expresión devuelve la expresión “simplificada” sin el conector más externo. Por ejemplo, (simplify  '^ '((^ (V (¬ P)))) retornaría ((V (¬ P))).

	La función cnf dada una expresión bien formada la convierte a formato prefijo valiéndose de las funciones auxiliares anteriores.
	
	2.5 Dada una expresión que se compone de una conjunción de cláusulas   
                  disyuntivas, eliminar los conectores conjunción (^) y disyunción (v) para  
                  pasar a un formato de lista de listas en el que la conjunción de cláusulas y  
                  la disyunción de literales dentro de cada cláusula están sobreentendidas. 

	La función eliminate-connectors controla que el parámetro de entrada no sea nil, realizando las siguientes acciones en ese caso. Sobreentendiendo que el argumento de entrada es una FBF en FNC en caso de que su primer elemento sea un conector enario (OR o AND) se llama recursivamente a sí misma con argumento el resto de lista de entrada. En caso de que el primer elemento sea un literal realiza un append a la lista creada por el primer elemento de la lista de entrada, añadiendo el resultado de la llamada recursiva a sí misma con argumento el resto de la lista de entrada. Como último caso a tratar se analiza si el primer elemento de la lista de entrada es otra lista, realizando un append de la lista creada por el resultado de la llamada recursiva a sí misma con argumento el primer elemento de la lista (la lista interna), añadiendo el resultado de la llamada recursiva a sí misma con el resto de la lista de entrada.




	2.6 Transformar una FBF en notación infijo a FNC con conjunciones y  
                  disyunciones implícitas 

	La función wff-infix-to-cnf  comprueba si es nil o si no está en notación infijo, retornando nil en ambos casos. En caso contrario convierte de la expresión de infijo a prefijo, elimina los bicondicionales y los condicionales, reduce el ámbito de las negaciones, la connvierte a notación CNF y  finalmente retorna la expresión con conectores eliminados. 

3.  Simplificación de FBFs en FNC
	3.1.1 Eliminar literales repetidos en una cláusula 
	
	La función repeated-literal-p comprueba si el literal pasado cómo primer argumento de la función está presente de forma duplicada en la lista pasada cómo segundo argumento mediante llamadas recursivas a ésta.

	La función eliminate-repeated-literals evalúa si el primer elemento de la cláusula pasada como argumento está repetido, en caso de que lo esté llama recursivamente a sí misma con argumento el resto de la cláusula. La condición de parada de esta recursión es que la lista sea nil. En caso de que el literal no esté repetido realiza un append de la lista formada por el literal añadiendo la llamada recursiva a sí misma con el resto de la cláusula. 


	3.1.2 Eliminar cláusulas repetidas en una FNC 
		
		Para eliminar cláusulas repetidas, primero se llama a la función eliminate-repeate-clauses-aux que elimina recursivamente los literales repetidos de cada una de las cláusulas que forman la CNF. Con éste resultado se llama a eliminate-repeated-clauses-aux-2 que hace uso de la función search-for-element, cuya finalidad es determinar si una determinada cláusula está repetida dentro del resto de la CNF. Si ésta función determina que la primera cláusula está repetida, la desecha, si no, la añade mediante append a la cnf restante, realizando la recursión  de eliminate-repeated-clauses-aux-2.

	3.2.1 Determinar si una cláusula es subsumida por otra
		
	La función search-element  retorna verdadero en el caso en que el argumento elem esté contenido en la lista list. El caso base de la recursión consiste en que la lista sea nil.

	La función subsumed-aux comprueba mediante search-element que el primer elemento (literal) de la cláusula K1 se encuentra en la cláusula K2, en caso afirmativo llama recursivamente a sí misma con el resto de la cláusula K1 y con la cláusula K2 intacta. Si la cláusula K1 llega a nil  la función retorna verdadero ya que K2 es subsumida por K1. En caso de que algún literal de K1 no se encuentre en K2 automáticamente la función retorna nil.
		
	La función subsumed devuelve K2 si K1 es subsumida por K2, y análogamente con K1, y en caso contrario retorna nil. Hace uso de  subsumed-aux para determinar si está subsumida. 


	3.2.2 Eliminar cláusulas subsumidas 

	La función subsumed-in-list recibe una cláusula K y una lista de cláusulas  cnf. El funcionamiento es el siguiente si la cláusula K subsume a la primera cláusua de la lista retorna K, si no, entonces comprueba que la cláusula cnf subusme a K y retorna la primer cáusula de cnf, en el caso de que no ocurrieran ninguna de las anteriores situaciones aplicaría recursión con el resto de la lista cnf.
		
	La función eliminate-subsumed-clauses recibe como parámetro una lista de cláusulas. La función recorre la lista en busca de cláusulas subsumidas mediante subsumed-in-list , de forma que solo inserta en la lista resultante las cláusulas que no son subsumidas por ninguna.

	3.3.1 Predicado para determinar si una cláusula es tautología 
	
	La tautology-p-aux recibe como argumentos un literal y la lista de literales. Su funcionamiento es el siguiente, si el literal es positivo comprueba que el primer literal de la lista es negativo y si es el mismo literal pero negado, en ese caso la función retorna verdadero, si no, compara con el resto de la lista. El procedimiento llevado a cabo en caso de que el literal pasado como parámetro sea negativo es análogo al anterior.

	La función tautology-p recibe una lista de literales pasado como argumento y se sirve de  tautology-p-aux utilizando como argumentos el primer elemento de la lista con el resto de la misma, si retorna verdadero  tautology-p devuelve verdadero, si no aplica recursión con el resto de la lista de literales.



	3.3.2 Eliminar tautologías 

	La función eliminate-tautologies hace uso de la función auxiliar tautology-p para determinar si el primer elemento (cláusula) de una FBF en FNC es tautología, en caso afirmativo llama recursivamente a sí misma. Esta recursión se lleva a cabo hasta que la FBF sea nil. Si la cláusula analizada no es tautología se realiza un append de la lista creada por la cláusula actual (es decir, el primer elemento de la lista actual) añadiendo el resultado de la llamada recursiva a sí misma con argumento el resto de la lista (el resto de la FBF).

	3.4 Simplificación de FNC 
	
	La función simplify-cnf es una encapsulación de funciones auxiliares cuya funcionalidad en conjunto consiste en eliminar las cláusulas repetidas de la FBF en FNC pasada como argumento, eliminar tautologías y finalmente retornar la FBF sin clausulas subsumidas.

4. Construcción de RES
	A partir de ahora, todas las funciones de manipulación de conjuntos serán invocadas con el parámetro extra :test indicando que la función de comparación que utilizarán para determinar la equivalencia entre dos elementos será equal y no eq, cómo es por defecto.
	4.1.1 Construye (0)
	La función extract-neutral-clauses dado un literal (lambda) y una expresión prefija en FNC retorna la lista con las cláusulas en las cuales no aparece el literal pasado como argumento. Evalúa cada cláusula analizando si el literal pertenece a la cláusula, en caso de que no lo sea realiza un append de la cláusula “neutra” junto con la llamada recursiva con el resto de la expresión en FNC. Si el literal pertenece a la cláusula la ignora y simplemente aplica recursividad con el resto de la expresión.
		
	4.1.2 Construye (+) 

	La función extract-postive-clauses es exactamente equivalente en procedimiento a la función anterior salvo que sólo retorna las cláusulas en las que el literal lambda pasado como argumento aparece sin negar.
		
	4.1.3 Construye (-) 

	La función extract-negative-clauses es exactamente equivalente en procedimiento a la función anterior salvo que sólo retorna las cláusulas en las que el literal lambda pasado como argumento aparece negado.

	4.2.1 Resolvente entre dos cláusulas res(K1,K2) 

	La función  resolve-on tiene como argumento un literal positivo y una cláusula K1 y otra cláusula K2 y tiene como objetivo hacer la resolución de las dos cláusulas sobre el literal pasado como argumento. Su funcionamiento es el siguiente, comprueba que la cláusula K1 no tiene el literal positivo pasado como argumento (es decir, que lo tiene negado)  y a continuación comprueba que K2 tiene el literal positivo, realizando la unión de la eliminación en K1 del literal negado y la eliminación de K2 del literal positivo. Por ejemplo, K1= ((¬ P) Q) y K2=(P J), el resultado sería (Q J).
	El procedimiento es análogo para el caso en que K1 tenga  el literal positivo pasado como argumento de la función.
			
	4.2.2 Construye RES(fnc) 

	La función build-RES se apoya sobre la llamada a la función 
build-RES-aux. A su vez ésta utiliza la función build-RES-aux-2, que contruye la lista resultante de aplicar resolución entre una cláusula y una cnf de cláusulas sobre el literal lambda suministrado.
	Cabe destacar que si al aplicar resolución mediante ésta técnica se llega a la cláusula vacía, ésta es insertada cómo valor NIL dentro de la FNC resultante. Es por ello que en el ejemplo suministrado, la tautología ((¬ P) P) aparece cómo una cláusula NIL.


5.  Determina si una FNC es SAT

	La función positivize-literals dada una lista con literales pasada como parámetro, positiviza todos ellos en una nueva lista.

	La función extract-positive-literals dada una lista con cláusulas implícitas de literales retorna, usando la función positivize-literals, la lista de literales únicos sin negar.

	Gracias a éstas dos funciones auxiliares, la función RES-SAT-p-aux realiza sucesivas resoluciones sobre la cnf, una por cada literal único que la compone.
	
	Para determina si la FNC es SAT, comprueba que la función 
build-RES no ha podido seguir haciendo resolución y que, además, no sobran literales por los que resolver. Para determinar que no es SAT, se comprueba que la resolución sobre la FNC da una contradicción (devuelve (NIL)).



6. Determinar w es consecuencia lógica de una base de conocimiento
    utilizando RES-SAT-p

	Esta función tiene como argumentos una base de conocimiento wff en infijo y la expresión w también en notación infijo.  Su funcionamiento es el siguiente, como primer paso altera la expresión w, negándola (¬ w), posteriormente realiza todas las subrutinas para convertir tanto la expresión ¬w como la base de conocimiento a notación prefijo en FNC, uniéndolas en una única lista. Simplifica la lista, la resuelve mediante res-sat-p y finalmente niega el resultado de la resolución. Ya que si se obtiene la cláusula vacía al introducir en la base de conocimiento ¬w la expresión w es consecuencia lógica y viceversa.

7.  Ejercicios 

	Blas, Pedro y Manuel fueron arrestados después del robo de una impresora en la sala de ordenadores de la escuela. Las confesiones de los sospechosos fueron: 

Blas: "Pedro es el culpable y Manuel es inocente" .
Pedro: "Blas no es culpable a menos que Manuel también lo sea" .
Manuel: "Soy inocente, pero por lo menos uno de los otros dos es culpable" .

	Base de conocimiento inicial: 
	((BB <=> (P ^ (¬ M))) ^ (PP <=> ((B ^ M) v (¬ B))) ^ (MM <=> ((B v P) ^ (¬ M))))

	
	¿Es posible que los tres sospechosos hayan dicho la verdad? Entonces, ¿quién será el 	culpable? Se introduce en la base de conocimiento: (BB ^ PP ^ MM) 

	Base de conocimiento:
	((BB <=> (P ^ (¬ M))) ^ (PP <=> ((B ^ M) v (¬ B))) ^ (MM <=> ((B v P) ^ (¬ M))) ^ BB ^ PP 	^ MM)

	Pedro es culpable: 
	(logical-consequence-res-sat-p '((BB <=> (P ^ (¬ M))) ^ (PP <=> ((B ^ M) v (¬ B))) ^ (MM 	<=> ((B v P) ^ (¬ M))) ^ BB ^ PP 	^ MM) 'p)  evalúa a T

	Manuel no es culpable:
	(logical-consequence-res-sat-p '((BB <=> (P ^ (¬ M))) ^ (PP <=> ((B ^ M) v (¬ B))) ^ (MM 	<=> ((B v P) ^ (¬ M))) ^ BB ^ PP 	^ MM) '(¬ M))  evalúa a T

	Blas no es culpable:
	(logical-consequence-res-sat-p '((BB <=> (P ^ (¬ M))) ^ (PP <=> ((B ^ M) v (¬ B))) ^ (MM 	<=> ((B v P) ^ (¬ M))) ^ BB ^ PP 	^ MM) '(¬ B))  evalúa a T

	Por lo tanto, si los tres sospechosos han dicho la verdad, Pedro es culpable.	

	¿Es posible que todos fueran culpables? Se introduce en la base de conocimiento: 
	(B ^ P ^ M) 

	Base de conocimiento:
	((BB <=> (P ^ (¬ M))) ^ (PP <=> ((B ^ M) v (¬ B))) ^ (MM <=> ((B v P) ^ (¬ M))) ^ B ^ P ^ 	M)
	
	Manuel mintió:
	(logical-consequence-res-sat-p '((BB <=> (P ^ (¬ M))) ^ (PP <=> ((B ^ M) v (¬ B))) ^ (MM 	<=> ((B v P) ^ (¬ M))) ^ B ^ P ^ M) '(¬ MM))  evalúa a T	
	
	Blas mintió:
	(logical-consequence-res-sat-p '((BB <=> (P ^ (¬ M))) ^ (PP <=> ((B ^ M) v (¬ B))) ^ (MM 	<=> ((B v P) ^ (¬ M))) ^ B ^ P ^ M) '(¬ BB))  evalúa a T		

	Pedro dijo la verdad:
	(logical-consequence-res-sat-p '((BB <=> (P ^ (¬ M))) ^ (PP <=> ((B ^ M) v (¬ B))) ^ (MM 	<=> ((B v P) ^ (¬ M))) ^ B ^ P ^ M) 'PP) evalúa a T

	Por lo tanto, si los tres sospechosos fueran culpables, tanto Blas cómo Manuel mintieron.

	¿Es posible que sólo uno haya mentido? 

	No es posible:
	(logical-consequence-res-sat-p '((BB <=> (P ^ (¬ M))) ^ (PP <=> ((B ^ M) V (¬ B))) ^ (MM 	<=> ((B V P) ^ (¬ M))))   '(((¬ BB) ^ PP ^ MM) v (BB ^ (¬ PP) ^ MM) v (BB ^ PP ^ (¬ MM))))
	evalúa a NIL
