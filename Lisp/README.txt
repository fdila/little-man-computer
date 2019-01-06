Federica Di Lauro 829470

Implementazione lisp:
Per l'esecuzione delle singole istruzioni viene definita la funzione
"one-instruction".
Per l'esecuzione dell'intera memoria viene definita "execution-loop", che
esegue le istruzioni finchè non trova un halted-state.

Il parsing dei file .lmc avviene tramite la funzione "lmc-open-file",
che crea una lista con un elemento di tipo string per ogni riga del file.
Le singole stringhe di questa lista vengono formattate attraverso
"lmc-format-line" che trasforma la stringa in lowercase, elimina gli spazi
iniziali e finali, e richiama la funzione "remove-comment" per rimuovere i
commenti.
Con la funzione "format-list" viene applicata la funzione "format-line" a tutti
gli elementi della lista, e vengono rimosse le righe vuote chiamando la
funzione "remove-empty-lines".
Viene poi applicata la funzione "parse-labels" per salvare in una lista dove in
posizione n è presente o la label corrispondente o 0 nel caso non fosse
presente una label all'inizio della riga. Vengono poi rimosse le etichette da
inizio riga con la funzione "remove-labels".
Come ultima operazione avviene il parsing delle istruzioni attraverso la
funzione "get-op-code", che associa ad ogni operazione il suo valore e che
richiama la funzione "find-addr" per associare al numero o label che segue
l'istruzione il suo valore numerico.

Viene definita la funzione "lmc-load" per caricare il file .lmc in memoria
richiamando le funzioni per il parsing definite precedentemente e vengono
aggiunti 0 in fondo alla lista per far raggiungere la lunghezza 100 alla
memoria con la funzione "pad-mem".

Infine viene definita la funzione "lmc-run" che prende in input un file .lmc e
una lista di input, carica il file in memoria e esegue l'execution-loop.
