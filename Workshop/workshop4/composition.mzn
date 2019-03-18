int: n;
set of int: NOTE = 1..n;
set of int: ORDER = 1..n;
set of int: NOTE1 = 1..n-1;
set of int: ORDER1 = 1..n-1;

array[ORDER] of var NOTE: order; % order[i] = k (i is the position,k is the number)
array[ORDER1] of var NOTE1: diffs; % diffs[i] = k (i is the position,k is the diffs)
array[NOTE] of var ORDER: posn; % posn[i] = k (i is the number,k is position) 
array[NOTE1] of var ORDER1: dposn; % dposn[i] = k (i is diffs, k is the position)

include "inverse.mzn";
constraint inverse(order,posn);
constraint inverse(diffs,dposn);
constraint abs(posn[1]-posn[n]) = 1;
constraint dposn[n-1] = min(posn[1],posn[n]);
constraint forall(i in ORDER1)(diffs[i] = abs(order[i] - order[i+1]));

solve satisfy;
output["order=\(order);\ndiffs=\(diffs);\nposn=\(posn);\ndposn=\(dposn);"];