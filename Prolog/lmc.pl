%% -*- Mode: Prolog -*-

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

lmc_sum(Acc, Num, Acc2, noflag) :- Acc2 is Acc + Num, Acc2 <1000, !.
lmc_sum(Acc, Num, Acc2, flag) :- Acc2 is Acc + Num - 1000.

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

lmc_sub(Acc, Num, Acc2, 0) :- Acc2 is Acc - Num, Acc2 > 0, !.
lmc_sub(Acc, Num, Acc2, 1) :- Acc2 is Acc - Num + 1000.

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
one_instruction(state(Acc, PC, Mem, In, Out, Flag),
								state(Acc2, PC2, Mem, In, Out, Flag)) :-
									nth0(PC, Mem, Inst, _),
									Inst > 499,
									Inst < 600,
									Pos is Inst - 500,
									nth0(Pos, Mem, Acc2, _),
									PC2 is PC + 1,
									!.
