first bra farAway // try this program with input 901 902 705 600 0 4 5 6 7 8 9 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
dat 0
staOp dat 300
op dat 0 // generated instruction
bra ret // return to the "caller"
tmp dat 0
sp dat 0
one dat 1
farAway sta first // overwrite the first memory location
continue inp // get one number in input
brz first // if it is zero start to execute
sta tmp // save the number in tmp
lda sp // load the pointer
add staOp // generate the store instruction
sta op // save the generated instruction
lda tmp // load the valued received in input
bra op // jump to the generated instruction
ret lda sp // update the pointer value
add one
sta sp
bra continue // start the cycle again