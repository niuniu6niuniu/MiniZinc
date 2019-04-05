% Liu Bei forsees that Yuan Shiu will be defeated by Cao Cao
% He needs to find a route to safety in Jin province before the defeat
% But Cao Cao's soldiers are everywhere

int: nrow;
set of int: ROW = 1..nrow;
int: ncol;
set of int: COL = 1..ncol;

enum TERRAIN = { P, M, F, C, R };
array[TERRAIN] of int: delay;
int: timelimit;

array[ROW,COL] of TERRAIN: terrain;
array[ROW,COL] of int: soldier;
array[ROW,COL] of bool: Jin;

int: start_row;
int: start_col;

int: maxstep;
set of int: STEP = 1..maxstep;
set of int: STEP0 = 0..maxstep;

var STEP: steps;
array[ROW,COL] of var STEP0: visit; % which step do we visit position or 0 if not visited

% Every step's position
array[1..maxstep] of var 0..nrow: which_row;
array[1..maxstep] of var 0..ncol: which_col;

%% start at start position
constraint visit[start_row,start_col] = 1;
constraint which_row[1] = start_row;
constraint which_col[1] = start_col;
constraint forall(s in 1..steps)(visit[which_row[s], which_col[s]] = s);

% only use steps moves
constraint sum(r in ROW,c in COL)(visit[r,c] > 0) <= steps;
%% reach Jin province
constraint Jin[which_row[steps],which_col[steps]] = true ;

%% visit at most one city
constraint sum(s in 1..steps)(terrain[which_row[s],which_col[s]] = C) <= 1; 

%% cant enter Mountain
constraint forall(s in 1..steps)(terrain[which_row[s],which_col[s]] != M);

% visit only one place in every step
include"alldifferent_except_0.mzn";
constraint alldifferent_except_0([visit[r,c]|r in ROW, c in COL]);

% steps form a path 
constraint forall(s in 1..steps-1)(abs(which_row[s]-which_row[s+1])+abs(which_col[s] - which_col[s+1]) = 1);
                
% no shortcuts
constraint forall(s1,s2 in 1..steps where s2 > s1 + 1)(abs(which_row[s1]-which_row[s2])+abs(which_col[s1] - which_col[s2]) > 1);

% not too much delay
constraint time <= timelimit;
var int: time = sum(r in ROW, c in COL)(delay[terrain[r,c]]*(visit[r,c] >= 1));

% minimize the number of soldiers traversed
solve minimize obj;
var int: obj = sum(r in ROW, c in COL)((visit[r,c] > 0)*soldier[r,c]);
                         

array[TERRAIN] of string: ter = [".", "#", "^", "C", "~"];

output 
       ["%"] ++
       [ " " ++ ter[fix(terrain[r,c])] ++ if c = ncol then "\n%" else "" endif
       | r in ROW, c in COL ]
       ++ ["\n%"] ++
       [ if soldier[r,c] > 0 then show_int(2,soldier[r,c]) else " ." endif
         ++ if c = ncol then "\n%" else "" endif
       | r in ROW, c in COL ]
       ++ ["\n"] ++
       ["%"] ++
       [ if fix(visit[r,c]) > 0 then show_int(2,visit[r,c]) else " ." endif
         ++ if c = ncol then "\n%" else "" endif
       | r in ROW, c in COL ]
       ++ ["\nvisit = array2d(ROW,COL,\(visit));\nsteps = \(steps);\ntime = \(time);\nobj = \(obj);"]
       ;


