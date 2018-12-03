%% -*- Mode: Prolog -*-
:- use_module(library(readutil)).
% Addizione
one_instruction(state(Acc, PC, Mem, In, Out, _),
		state(Acc2, PC2, Mem, In, Out, Flag)) :-
    nth0(PC, Mem, Inst, _),
    Inst > 99,
    Inst < 200,
    Pos is Inst - 100,
    nth0(Pos, Mem, Num, _),
    lmc_sum(Acc, Num, Acc2, Flag),
    PC2 is mod(PC + 1, 100),!.
%Sottrazione
one_instruction(state(Acc, PC, Mem, In, Out, _),
		state(Acc2, PC2, Mem, In, Out, Flag)) :-
    nth0(PC, Mem, Inst, _),
    Inst > 199,
    Inst < 300,
    Pos is Inst - 200,
    nth0(Pos, Mem, Num, _),
    lmc_sub(Acc, Num, Acc2, Flag),
    PC2 is mod(PC + 1, 100),!.
%Store
one_instruction(state(Acc, PC, Mem, In, Out, Flag),
		state(Acc, PC2, Mem2, In, Out, Flag)) :-
    nth0(PC, Mem, Inst, _),
    Inst > 299,
    Inst < 400,
    Pos is Inst - 300,
    nth0(Pos, Mem, _, Rest),
    nth0(Pos, Mem2, Acc, Rest),
    PC2 is mod(PC + 1, 100),!.

%Load
one_instruction(state(_, PC, Mem, In, Out, Flag),
		state(Acc2, PC2, Mem, In, Out, Flag)) :-
    nth0(PC, Mem, Inst, _),
    Inst > 499,
    Inst < 600,
    Pos is Inst - 500,
    nth0(Pos, Mem, Acc2, _),
    PC2 is mod(PC + 1, 100),!.

%Branch
one_instruction(state(Acc, PC, Mem, In, Out, Flag),
		state(Acc, PC2, Mem, In, Out, Flag)) :-
    nth0(PC, Mem, Inst, _),
    Inst > 599,
    Inst < 700,
    PC2 is Inst - 600,!.

%Branch if zero
one_instruction(state(Acc, PC, Mem, In, Out, Flag),
		state(Acc, PC2, Mem, In, Out, Flag)) :-
    nth0(PC, Mem, Inst, _),
    Inst > 699,
    Inst < 800,
    PCBranch is Inst - 700,
    lmc_branch_zero(Acc, PC, PCBranch, Flag, PC2), !.

%Branch if positive
one_instruction(state(Acc, PC, Mem, In, Out, Flag),
		state(Acc, PC2, Mem, In, Out, Flag)) :-
    nth0(PC, Mem, Inst, _),
    Inst > 799,
    Inst < 900,
    PCBranch is Inst - 800,
    lmc_branch_positive(PC, PCBranch, Flag, PC2),!.
%Input
one_instruction(state(_, PC, Mem, In, Out, Flag),
		state(Acc2, PC2, Mem, In2, Out, Flag)) :-
    nth0(PC, Mem, Inst, _),
    Inst = 901,
    nth0(0, In, Acc2, In2),
    PC2 is mod(PC + 1, 100),!.
%Output
one_instruction(state(Acc, PC, Mem, In, Out, Flag),
		state(Acc, PC2, Mem, In, Out2, Flag)) :-
    nth0(PC, Mem, Inst, _),
    Inst = 902,
    append(Out, [Acc], Out2),
    PC2 is mod(PC + 1, 100),!.

%Halt
one_instruction(state(Acc, PC, Mem, In, Out, Flag),
		halted_state(Acc, PC2, Mem, In, Out, Flag)) :-
    nth0(PC, Mem, Inst, _),
    Inst < 100,
    PC2 is mod(PC + 1, 100),!.


%Predicati richiamati dalle one_instruction
lmc_sum(Acc, Num, Acc2, noflag) :-
    Acc2 is Acc + Num, Acc2 <1000, !.
lmc_sum(Acc, Num, Acc2, flag) :-
    Acc2 is Acc + Num - 1000.

lmc_sub(Acc, Num, Acc2, noflag) :-
    Acc2 is Acc - Num, Acc2 >= 0, !.
lmc_sub(Acc, Num, Acc2, flag) :-
    Acc2 is Acc - Num + 1000.

lmc_branch_zero(0, _, PCBranch, noflag, PCBranch) :- !.
lmc_branch_zero(_, PC, _, _, PC2) :-
    PC2 is mod(PC + 1, 100),!.

lmc_branch_positive(_, PCBranch, noflag, PCBranch) :- !.
lmc_branch_positive(PC, _, flag, PC2) :-
    PC2 is mod(PC + 1, 100),!
.
%Execution_loop
execution_loop(halted_state(_, _, _, _, Out, _), Out).
execution_loop(state(Acc, PC, Mem, In, Out, Flag), Out2) :-
    one_instruction(state(Acc, PC, Mem, In, Out, Flag),	NewState),
    execution_loop(NewState, Out2).

%Operazioni di manipolazione del file
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
    lmc_remove_comment_line(T, Z),!.

lmc_remove_empty_line([],[]).
lmc_remove_empty_line([H|T], Z) :-
    H="",
    lmc_remove_empty_line(T,Z).
lmc_remove_empty_line([H|T], [H|Z]) :-
    lmc_remove_empty_line(T,Z),!.

lmc_format_instruction_list(List, NewList) :-
    lmc_remove_initial_spaces(List, X),
    lmc_remove_comment_line(X, Y),
    lmc_remove_empty_line(Y, NewList).

lmc_parse_labels([],[],[]).
lmc_parse_labels([H|T], [Y|Z], [0|Xs]) :-
    split_string(H, "//", " ", [X|_]),
    split_string(X, " ", " ", Y),
    nth0(0, Y, First, _),
    member(First, ["add", "sub", "sta", "lda", "bra", "brz",
                   "brp", "inp", "out", "hlt", "halt"]), !,
    lmc_parse_labels(T, Z, Xs).
lmc_parse_labels([H|T], [Rest|Z], [Label|Xs]) :-
    split_string(H, "//", " ", [X|_]),
    split_string(X, " ", " ", Y),
    nth0(0, Y, Label, Rest),!,
    lmc_parse_labels(T, Z, Xs).

lmc_parse_instructions([],[],_).
lmc_parse_instructions([[Op, Ind]|T], [MemCode| Z], Labels) :-
    Op = "add",
    OpN = 100,
    number_string(IndN,Ind),!,
    IndN < 100,
    MemCode is OpN + IndN,
    lmc_parse_instructions(T, Z, Labels).
lmc_parse_instructions([[Op, Ind]|T], [MemCode | Z], Labels) :-
    Op = "add",
    OpN = 100,
    nth0(IndN, Labels, Ind, _),!,
    MemCode is OpN + IndN,
    lmc_parse_instructions(T, Z, Labels).

lmc_parse_instructions([[Op, Ind]|T], [MemCode| Z], Labels) :-
    Op = "sub",
    OpN = 200,
    number_string(IndN,Ind),!,
    IndN < 100,
    MemCode is OpN + IndN,
    lmc_parse_instructions(T, Z, Labels).
lmc_parse_instructions([[Op, Ind]|T], [MemCode | Z], Labels) :-
    Op = "sub",
    OpN = 200,
    nth0(IndN, Labels, Ind, _),!,
    MemCode is OpN + IndN,
    lmc_parse_instructions(T, Z, Labels).

lmc_parse_instructions([[Op, Ind]|T], [MemCode| Z], Labels) :-
    Op = "sta",
    OpN = 300,
    number_string(IndN,Ind),!,
    IndN < 100,
    MemCode is OpN + IndN,
    lmc_parse_instructions(T, Z, Labels).
lmc_parse_instructions([[Op, Ind]|T], [MemCode | Z], Labels) :-
    Op = "sta",
    OpN = 300,
    nth0(IndN, Labels, Ind, _),!,
    MemCode is OpN + IndN,
    lmc_parse_instructions(T, Z, Labels).

lmc_parse_instructions([[Op, Ind]|T], [MemCode| Z], Labels) :-
    Op = "lda",
    OpN = 500,
    number_string(IndN,Ind),!,
    IndN < 100,
    MemCode is OpN + IndN,
    lmc_parse_instructions(T, Z, Labels).
lmc_parse_instructions([[Op, Ind]|T], [MemCode | Z], Labels) :-
    Op = "lda",
    OpN = 500,
    nth0(IndN, Labels, Ind, _),!,
    MemCode is OpN + IndN, !,
    lmc_parse_instructions(T, Z, Labels).

lmc_parse_instructions([[Op, Ind]|T], [MemCode| Z], Labels) :-
    Op = "bra",
    OpN = 600,
    number_string(IndN,Ind), !,
    IndN < 100,
    MemCode is OpN + IndN,
    lmc_parse_instructions(T, Z, Labels).
lmc_parse_instructions([[Op, Ind]|T], [MemCode | Z], Labels) :-
    Op = "bra",
    OpN = 600,
    nth0(IndN, Labels, Ind, _),!,
    MemCode is OpN + IndN,
    lmc_parse_instructions(T, Z, Labels).

lmc_parse_instructions([[Op, Ind]|T], [MemCode| Z], Labels) :-
    Op = "brz",
    OpN = 700,
    number_string(IndN,Ind), !,
    IndN < 100,
    MemCode is OpN + IndN,
    lmc_parse_instructions(T, Z, Labels).
lmc_parse_instructions([[Op, Ind]|T], [MemCode | Z], Labels) :-
    Op = "brz",
    OpN = 700,
    nth0(IndN, Labels, Ind, _),!,
    MemCode is OpN + IndN,
    lmc_parse_instructions(T, Z, Labels).

lmc_parse_instructions([[Op, Ind]|T], [MemCode| Z], Labels) :-
    Op = "brp",
    OpN = 800,
    number_string(IndN,Ind),!,
    IndN < 100,
    MemCode is OpN + IndN,
    lmc_parse_instructions(T, Z, Labels).
lmc_parse_instructions([[Op, Ind]|T], [MemCode | Z], Labels) :-
    Op = "brp",
    OpN = 800,
    nth0(IndN, Labels, Ind, _),
    MemCode is OpN + IndN,
    lmc_parse_instructions(T, Z, Labels).

lmc_parse_instructions([[Op]|T], [MemCode| Z], Labels) :-
    Op = "inp",!,
    MemCode = 901,
    lmc_parse_instructions(T, Z, Labels).

lmc_parse_instructions([[Op]|T], [MemCode| Z], Labels) :-
    Op = "out",!,
    MemCode = 902,
    lmc_parse_instructions(T, Z, Labels).

lmc_parse_instructions([[Op]|T], [MemCode| Z], Labels) :-
    Op = "hlt",!,
    MemCode = 000,
    lmc_parse_instructions(T, Z, Labels).

lmc_parse_instructions([[Op, Ind]|T], [IndN| Z], Labels) :-
    Op = "dat",
    number_string(IndN,Ind),!,
    IndN < 1000,
    lmc_parse_instructions(T, Z, Labels).
lmc_parse_instructions([[Op, Ind]|T], [IndN | Z], Labels) :-
    Op = "dat",
    nth0(IndN, Labels, Ind, _),!,
    lmc_parse_instructions(T, Z, Labels).
lmc_parse_instructions([[Op]|T], [0| Z], Labels) :-
    Op = "dat",!,
    lmc_parse_instructions(T, Z, Labels).

lmc_pad_mem(Mem, PadMem) :-
    length(Mem,Length),
    Length<100,!,
    append(Mem, [0], NewMem),
    lmc_pad_mem(NewMem, PadMem).
lmc_pad_mem(Mem,Mem) :- !.

%Caricamento in memoria del file
lmc_load(File, PadMem) :-
    lmc_open_file(File, List),
    lmc_format_instruction_list(List, FormattedList),
    lmc_parse_labels(FormattedList, InstList, Labels),
    lmc_parse_instructions(InstList, Mem, Labels),
    lmc_pad_mem(Mem,PadMem).

%Esecuzione del file
lmc_run(File, In, Out) :-
    lmc_load(File, Mem),!,
    execution_loop(state(0, 0, Mem, In, [], noflag), Out).
