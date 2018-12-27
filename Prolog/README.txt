Federica Di Lauro 829470

Implementazione prolog:

Per l'esecuzione delle singole istruzioni viene definito il predicato
"one_instruction", che, in alcuni casi, richiama a sua volta dei predicati
di supporto (in particolare per somma, sottrazione, branch if zero e
branch positive).

Viene definito "execution_loop" per l'esecuzione di tutte le istruzioni
presenti in memoria, si interrompe quando lo state è "halted".

Il parsing dei file .lmc avviene tramite la conversione del file in una lista
con un elemento per ogni riga.
Vengono eseguite operazioni di formattazione per
eliminare spazi, commenti e righe vuote.
Viene generata una lista dove in posizione n è presente o la label
corrispondente o 0 nel caso non fosse presente una label all'inizio della riga.
Come ultima operazione si ha il parsing delle istruzioni dove ad ogni
operazione viene associato il numero corrispondente e viene aggiunto il valore
di memoria (o il valore associato alla label).
