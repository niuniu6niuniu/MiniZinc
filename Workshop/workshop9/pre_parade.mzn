int: n;  % number of soldiers
set of int: SOLDIER = 1..n;
set of int: SOLDIER0 = 0..n;
set of int: POS = 1..n;
array[SOLDIER] of int: height;
int: cols;    % number of columns of soldiers 
int: delta;   % height delta allowed

array[POS] of var SOLDIER: soldier;
array[SOLDIER] of var POS: pos;
% constraint forall(i in 1..n,j in 1..n)(pos[i] = j <-> soldier[j] = i);

%%%%%%%%%%%%% POS %%%%%%%%%%%%%%%%

include "inverse.mzn";
constraint inverse(pos,soldier);   
constraint pos[1] = 1;

%%%%%%%%%%%%% GRID %%%%%%%%%%%%%%

% Mapping soldier to grid position 
int: rows = n div cols;
set of int: ROW = 1..rows;
set of int: COL = 1..cols;
array[ROW,COL] of var SOLDIER0: x;
constraint x[1,1] = 2;
constraint forall(r in 2..rows)(x[r,1] = x[r-1,1] + cols);
constraint forall(r in 1..rows,c in 2..cols)(if x[r,c-1] < n 
                  then x[r,c] = x[r,c-1] + 1 else x[r,c] = 0 endif); 
% pos order align with col order                             
constraint forall(c in COL, r1,r2 in ROW where r1 < r2)
                 ((x[r1,c] > 0 /\ x[r2,c] > 0) -> pos[x[r1,c]] < pos[x[r2,c]]);                  
                 
% include "inverse.mzn";
% constraint inverse(soldier,pos);

%%%%%%%%%%%% Parade %%%%%%%%%%%%%

% Height difference between two consecutive pos
array[1..n-1] of var int: dif;
constraint forall(s in 1..n-1)(dif[s] = abs(height[soldier[s]] - height[soldier[s+1]]));  
% identify the discernable height difference 
array[1..n-1] of var int: spot;
constraint forall(s in 1..n-1)(if dif[s] > delta then spot[s] = s else spot[s] = n endif);
var int: obj = min(spot);
constraint obj <= n;                                                          

solve maximize obj;
output["pos=\(pos);\nobj=\(obj);"]