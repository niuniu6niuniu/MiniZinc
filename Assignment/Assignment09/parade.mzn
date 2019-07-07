int: n;                                % number of soldiers
int: cols;                             % number of columns
int: delta;                            % height delta allowed
set of int: SOLDIER = 1..n;
set of int: SOLDIER0 = 0..n;           % dummy soldier maybe used
set of int: POS = 1..n;
array[SOLDIER] of int: height;         % height each soldier

array[POS] of var SOLDIER: soldier;    % for each pos which soldier
array[SOLDIER] of var POS: pos;        % for each soldier which pos

% Channeling viewpoints of pos and soldier
include "inverse.mzn";
constraint inverse(pos,soldier);

%%%%%%%%%%%%%%% Formation %%%%%%%%%%%%%%%%%%

% Determine how many rows we have
int: rows = if (n-1) mod cols = 0 then (n-1) div cols else (n-1) div cols + 1 endif;
% Create a matrix to decide each soldier's place in the formation 
set of int: ROW = 1..rows;
set of int: COL = 1..cols;
array[ROW,COL] of var SOLDIER0: x;       
% Soldier 2 is the first soldier in the first column  
constraint x[1,1] = 2;
% Mapping soldiers to the formation matrix
constraint forall(i in 2..rows)(x[i,1] = x[i-1,1] + cols);
constraint forall(r in 1..rows,c in 2..cols)(if x[r,c-1] < n /\ x[r,c-1] > 0 
                  then x[r,c] = x[r,c-1] + 1 else x[r,c] = 0 endif); 
                  
%%%%%%%%%%%%%%%%%% Parade %%%%%%%%%%%%%%%%%%%%

% Captain is always soldier 1 and parade in the first place                   
constraint pos[1] = 1;   
% The order in the same column             
constraint forall(c in 1..cols,r1,r2 in 1..rows where r1 < r2)
                 (x[r2,c] > 0 -> pos[x[r1,c]] < pos[x[r2,c]]); 
% The height difference array                                
array[1..n-1] of var int: dif;
constraint forall(s in 1..n-1)(dif[s] = abs(height[soldier[s]] - height[soldier[s+1]]));           
% Nuwa is happy until the first spottable height difference, otherwise obj is equal to n             
array[1..n-1] of var int: spot;
constraint forall(s in 1..n-1)(if dif[s] > delta then spot[s] = s else spot[s] = n endif);
var int: obj = min(spot); 

% Variables: pos,soldier,height,x 
% Annotations: input_order,first_fail,smallest,largest
%              indomain_min,indomain_max,indomain_median,indomain_random

solve :: int_search(soldier, first_fail, indomain_max, complete)
      maximize obj;                 

%solve maximize obj;

output ["obj=\(obj);\n"] ++
       ["pos=\(pos);\n"];