%% -*- Mode: Prolog -*-

%% necessario per evitare che prolog mi metta i puntini
%% su cose troppo lunghe
:- set_prolog_flag(answer_write_options,
                   [ quoted(true),
                     portray(true),
                     spacing(next_argument)
                   ]).


% Addizione
one_instruction(state(Acc, PC, Mem, In, Out, _),
								state(Acc2, PC2, Mem, In, Out, Flag)) :-
									nth0(PC, Mem, Inst, _),
									Inst > 99,
									Inst < 200,
									Pos is Inst - 100,
									nth0(Pos, Mem, Num, _),
									lmc_sum(Acc, Num, Acc2, Flag),
									PC2 is mod(PC + 1, 100),
									!.
%Sottrazione
one_instruction(state(Acc, PC, Mem, In, Out, _),
								state(Acc2, PC2, Mem, In, Out, Flag)) :-
									nth0(PC, Mem, Inst, _),
									Inst > 199,
									Inst < 300,
									Pos is Inst - 200,
									nth0(Pos, Mem, Num, _),
									lmc_sub(Acc, Num, Acc2, Flag),
									PC2 is mod(PC + 1, 100),
									!.
%Store
one_instruction(state(Acc, PC, Mem, In, Out, Flag),
								state(Acc, PC2, Mem2, In, Out, Flag)) :-
									nth0(PC, Mem, Inst, _),
									Inst > 299,
									Inst < 400,
									Pos is Inst - 300,
									nth0(Pos, Mem, _, Rest),
    							nth0(Pos, Mem2, Acc, Rest),
									PC2 is mod(PC + 1, 100),
									!.

%Load
one_instruction(state(_, PC, Mem, In, Out, Flag),
								state(Acc2, PC2, Mem, In, Out, Flag)) :-
									nth0(PC, Mem, Inst, _),
									Inst > 499,
									Inst < 600,
									Pos is Inst - 500,
									nth0(Pos, Mem, Acc2, _),
									PC2 is mod(PC + 1, 100),
									!.

%Branch
one_instruction(state(Acc, PC, Mem, In, Out, Flag),
								state(Acc, PC2, Mem, In, Out, Flag)) :-
									nth0(PC, Mem, Inst, _),
									Inst > 599,
									Inst < 700,
									PC2 is Inst - 600.

%Branch if zero
one_instruction(state(Acc, PC, Mem, In, Out, Flag),
								state(Acc, PC2, Mem, In, Out, Flag)) :-
									nth0(PC, Mem, Inst, _),
									Inst > 699,
									Inst < 800,
									PCBranch is Inst - 700,
									lmc_branch_zero(Acc, PC, PCBranch, Flag, PC2),
									!.

%Branch if positive
one_instruction(state(Acc, PC, Mem, In, Out, Flag),
								state(Acc, PC2, Mem, In, Out, Flag)) :-
									nth0(PC, Mem, Inst, _),
									Inst > 799,
									Inst < 900,
									PCBranch is Inst - 800,
									lmc_branch_positive(PC, PCBranch, Flag, PC2),
									!.

%Input
one_instruction(state(_, PC, Mem, In, Out, Flag),
								state(Acc2, PC2, Mem, In2, Out, Flag)) :-
									nth0(PC, Mem, Inst, _),
									Inst = 901,
									nth0(0, In, Acc2, In2),
									PC2 is mod(PC + 1, 100),
									!.
%Output
one_instruction(state(Acc, PC, Mem, In, Out, Flag),
								state(Acc, PC2, Mem, In, Out2, Flag)) :-
									nth0(PC, Mem, Inst, _),
									Inst = 902,
									append(Out, [Acc], Out2),
									PC2 is mod(PC + 1, 100),
									!.

%Halt
%TODO come fermare esecuzione programma?
one_instruction(state(Acc, PC, Mem, In, Out, Flag),
								halted_state(Acc, PC2, Mem, In, Out, Flag)) :-
									nth0(PC, Mem, Inst, _),
									Inst < 100,
									PC2 is mod(PC + 1, 100),
									!.


%Predicati richiamati dalle one_instruction
lmc_sum(Acc, Num, Acc2, noflag) :- Acc2 is Acc + Num, Acc2 <1000, !.
lmc_sum(Acc, Num, Acc2, flag) :- Acc2 is mod(Acc + Num, 100).

lmc_sub(Acc, Num, Acc2, noflag) :- Acc2 is Acc - Num, Acc2 >= 0, !.
lmc_sub(Acc, Num, Acc2, flag) :- Acc2 is mod(Acc - Num, 100).

lmc_branch_zero(0, _, PCBranch, noflag, PCBranch) :- !.
lmc_branch_zero(_, PC, _, _, PC2) :-
									PC2 is mod(PC + 1, 100),
									!.

lmc_branch_positive(_, PCBranch, noflag, PCBranch) :- !.
lmc_branch_positive(PC, _, flag, PC2) :-
											PC2 is mod(PC + 1, 100),
											!.
%Execution loop
execution_loop(halted_state(_, _, _, _, Out, _), Out) :- !.
execution_loop(state(Acc, PC, Mem, In, Out, Flag), Out2) :-
								one_instruction(state(Acc, PC, Mem, In, Out, Flag),
																NewState),
								execution_loop(NewState, Out2), !.
