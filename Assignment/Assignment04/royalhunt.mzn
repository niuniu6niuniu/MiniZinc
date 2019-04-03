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

array[COURT] of var 0..m: court;
array[HORSE] of var 0..n: horse;
constraint forall(i in COURT, j in HORSE) (court[i] = j <-> horse[j] = i);
include "alldifferent_except_0.mzn";
constraint alldifferent_except_0(court);

constraint forall(i in 2..n where court[i] != 0) (enjoy[i, court[i]] < enjoy[1, court[1]]);

constraint n > m -> sum(i in COURT)(court[i] != 0) = m;
constraint n <= m -> sum(i in COURT)(court[i] != 0) = n;

constraint forall(i, j in COURT where rank[i] < rank[j]) (court[j] = 0 -> court[i] = 0);

constraint forall(i in COURT where court[i] != 0)(enjoy[i, court[i]] >= 0);

constraint forall(i, j in COURT where rank[i] < rank[j] /\ court[i] != 0 /\ court[j] != 0) (
    court[i] = 0 \/
    (court[i] = 0 /\ court[j] = 0) \/
    beauty[court[i]] <= beauty[court[j]]);

var int: penalty = sum([1 | i, j in HORSE where speed[i] < speed[j] /\ horse[j] != 0 /\
        ((horse[i] != 0 /\ ability[horse[i]] > ability[horse[j]]) \/ horse[i] = 0)]);
        
var int: overall_enjoyment = sum(i in 1..n where court[i] != 0) (enjoy[i, court[i]]);
var int: obj = overall_enjoyment - 100*penalty;
solve maximize obj;
output ["rider = \(horse);\nhorse = \(court);\n",  "obj = \(obj);\n"];
