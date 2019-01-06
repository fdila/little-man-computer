Federica Di Lauro 829470

Implementazione prolog:

Per l'esecuzione delle singole istruzioni viene definito il predicato
"one_instruction", che, in alcuni casi, richiama a sua volta dei predicati
di supporto (in particolare per somma, sottrazione, branch if zero e
branch positive).

Viene definito "execution_loop" per l'esecuzione di tutte le istruzioni
presenti in memoria, si interrompe quando lo state è "halted".

Il parsing dei file .lmc avviene tramite la conversione del file in una lista
con un elemento per ogni riga, attraverso il predicato "lmc_open_file"
Vengono eseguite operazioni di formattazione per
eliminare spazi, commenti e righe vuote con i predicati
"lmc_remove_initial_spaces", "lmc_remove_empty_line",
"lmc_remove_comment_line".
Viene generata una lista dove in posizione n è presente o la label
corrispondente o 0 nel caso non fosse presente una label all'inizio della riga
con il predicato "lmc_parse_labels".
Come ultima operazione si ha il parsing delle istruzioni
("lmc_parse_instructions") dove ad ogni operazione viene associato il numero
corrispondente e viene aggiunto il valore di memoria (o il valore associato
alla label).

Il predicato "lmc_load" richiama i predicati appena descritti, ed esegue un
padding della memoria nel caso la lunghezza fosse minore di 100.

Il predicato "lmc_run" carica il file .lmc in memoria chiamando "lmc_load",
ed esegue l'execution loop con la memoria ottenuta.
