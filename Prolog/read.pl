:- use_module(library(readutil)).
% necessario per evitare che prolog mi metta i puntini su cose troppo lunghe
:- set_prolog_flag(answer_write_options,
                   [ quoted(true),
                     portray(true),
                     spacing(next_argument)
                   ]).

/*
Apre il file, trasforma tutto il lower case e
crea lista con un elemento per ogni riga
*/

lmc_open_file(File, List) :-
                read_file_to_codes(File, X, []),
                string_codes(Y, X),
                string_lower(Y, String),
                split_string(String, "\n", "", List).

lmc_remove_initial_spaces([],[]).
lmc_remove_initial_spaces([H|T], [H2|Z]) :-
                      split_string(H, "", "\s\t\n", List),
                      nth0(0, List, H2, _),
                      lmc_remove_initial_spaces(T, Z).

lmc_remove_comment_line([],[]).
lmc_remove_comment_line([H|T], Z) :-
                        sub_string(H, Before, _, _, "//"),
                        Before = 0, !,
                        lmc_remove_comment_line(T, Z).
lmc_remove_comment_line([H|T], [H|Z]) :-
                        lmc_remove_comment_line(T, Z),
                        !.

lmc_remove_empty_line([],[]).
lmc_remove_empty_line([H|T], Z) :-
                      H="",
                      lmc_remove_empty_line(T,Z).
lmc_remove_empty_line([H|T], [H|Z]) :-
                      lmc_remove_empty_line(T,Z),
                      !.

lmc_format_instruction_list(String, NewList) :-
                        lmc_split(String, List),
                        lmc_remove_initial_spaces(List, X),
                        lmc_remove_comment_line(X, Y),
                        lmc_remove_empty_line(Y, NewList).


/*
lmc_load_memory(List, Mem, N) :-
                nth0(N, List, Elem, NewList),
                lmc_remove_initial_spaces(Elem, Elem2),
                lmc_remove_comment().
                nth0(N, Mem, Elem, NewList).
*/
