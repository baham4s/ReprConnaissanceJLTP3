;DUBIN Baptiste
(deftemplate etat
	(slot quatre (type INTEGER) (default 0))
	(slot trois (type INTEGER) (default 0))
	(slot action (type STRING) (default ""))
	(slot pere (type FACT-ADDRESS SYMBOL) (default nil))
	(slot profondeur (type INTEGER) (default 0))
)

(deffacts initiaux
	(etat)
)

(deffunction afficher_solution (?noeud)
	(if (neq ?noeud nil) then
		(bind ?pere (fact-slot-value ?noeud pere))
		(bind ?action (fact-slot-value ?noeud action))
		(bind ?trois (fact-slot-value ?noeud trois))
		(bind ?quatre (fact-slot-value ?noeud quatre))
		(afficher_solution ?pere)
		(printout t ?action (implode$ (create$ ?trois ?quatre )) crlf)
	)
)

(defrule arret
	(declare (salience -10))
	(or
		?ref <- (etat (quatre 2))
		?ref <- (etat (trois 2))
	)
	=>
	(printout t  "Situation initiale -> ")
	(afficher_solution ?ref)
	(halt)
)

(defrule meme_profondeur
	(declare (salience 20))
	?p1 <- (etat (quatre ?quatre) (trois ?trois) (profondeur ?e1))
	?p2 <- (etat (quatre ?quatre) (trois ?trois) (profondeur ?e2))
	(test (> ?e1 ?e2))
	=>
	(assert (replace ?p1 ?p2))
	(retract ?p1)
)

(defrule replace
	(declare (salience 50))
	(replace ?old ?new)
	?node <- (etat (pere ?old))
	=>
	(modify ?node (pere ?new))
)

(defrule remplir_cruche_trois
	?pere <- (etat (trois ~3) (profondeur ?profondeur))
	=>
	(duplicate ?pere (action "Remplir la cruche de 3 litres -> ") (trois 3) (pere ?pere) (profondeur (+ ?profondeur 1)))
)

(defrule remplir_cruche_quatre
	?pere <- (etat (quatre ~4)(profondeur ?profondeur))
	=>
	(duplicate ?pere (quatre 4) (pere ?pere) (action "Remplir la cruche de 4 litres -> ")(profondeur (+ ?profondeur 1)))
)

(defrule vider_cruche_trois
	?pere <- (etat (trois ~0)(profondeur ?profondeur))
	=>
	(duplicate ?pere (trois 0) (pere ?pere) (action "Vider la cruche de 3 litres -> ")(profondeur (+ ?profondeur 1)))
)

(defrule vider_cruche_quatre
	?pere <- (etat (quatre ~0)(profondeur ?profondeur))
	=>
	(duplicate ?pere (quatre 0) (pere ?pere) (action "Vider la cruche de 4 litres -> ")(profondeur (+ ?profondeur 1)))
)

(defrule transvaser_cruche_trois
	?pere <- (etat (quatre ?quatre&~4) (trois ?trois&~0)(profondeur ?profondeur))
	=>
	(assert (etat (quatre (+ ?quatre ?trois)) (pere ?pere) (action "Transvaser la cruche de 3 litres dans la cruche de 4 litres -> ")(profondeur (+ ?profondeur 1))))
)

(defrule transvaser_cruche_quatre
	?pere <- (etat (quatre ?quatre&~0) (trois ?trois&~3)(profondeur ?profondeur))
	=>
	(assert (etat (trois (+ ?quatre ?trois)) (pere ?pere) (action "Transvaser la cruche de 4 litres dans la cruche de 3 litres -> ")(profondeur (+ ?profondeur 1))))
)

(defrule egale_trois
	(declare (salience 100))
	?ref <- (etat (quatre ?quatre) (trois ?trois&:(> ?trois 3)))
	=>
	(modify ?ref (trois 3) (quatre (+ ?quatre (- ?trois 3))))
)

(defrule egale_quatre
	(declare (salience 100))
	?ref <- (etat (quatre ?quatre&:(> ?quatre 4)) (trois ?trois))
	=>
	(modify ?ref (quatre 4) (trois (+ ?trois (- ?quatre 4))))
)
