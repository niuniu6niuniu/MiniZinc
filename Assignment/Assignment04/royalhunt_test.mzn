int: n;
set of int: COURT = 1..n;
int: emperor = 1;
array[COURT] of int: rank;
array[COURT] of int: ability;
int: m;
set of int: HORSE = 1..m;
array[HORSE] of int: beauty;
array[HORSE] of int: speed;

array[COURT,HORSE] of int: enjoy;

array[COURT] of var HORSE union {0}: court;
include "alldifferent_except_0.mzn";
constraint alldifferent_except_0(court);
%Constraint 1: the enjoyment of emperor greater than anyone else  
constraint forall(i in 2..n where court[i] != 0) (enjoy[i, court[i]] < enjoy[1, court[1]]);
%Constraint 2: everyone has to ride if there are enough horses.
constraint n > m -> sum(i in COURT)(court[i] != 0) = m;
constraint n <= m -> sum(i in COURT)(court[i] != 0) = n;
%Constraint 3
constraint forall(i, j in COURT where rank[i] < rank[j] /\ court[i] != 0 /\ court[j] != 0) (
                 court[i] = 0 \/
                 (court[i] = 0 /\ court[j] = 0) \/
                 (beauty[court[i]] <= beauty[court[j]]));
%Constraint 4: violation
var int: penalty = sum([1 | i, j in COURT where speed[court[i]] < speed[court[j]] /\
                      i != 0 /\
                      ((j != 0 /\ (ability[i] > ability[j])) \/ j = 0)]);                               
%Constraint 5: each enjoyment should not lower than zero
constraint forall(i in COURT where court[i] != 0)(enjoy[i, court[i]] >= 0);
constraint forall(i, j in COURT where rank[i] < rank[j]) (court[j] = 0 -> court[i] = 0);
% OBJ
var int: enjoyment = sum(i in 1..n where court[i] != 0) (enjoy[i, court[i]]);
var int: obj = enjoyment - 100*penalty;
solve maximize obj;
output ["\ncourt = \(court);\n","obj = \(obj);\n"];
