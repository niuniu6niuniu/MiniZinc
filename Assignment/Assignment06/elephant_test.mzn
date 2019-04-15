int: T; % maximum time allowed;
set of int: TIME = 1..T;

int: E; % weight of elephant in STONES;
set of int: STONE = 0..E;

int: G; % number of guards
set of int: GUARD = 1..G;
array[GUARD] of STONE: easy;   
array[GUARD] of STONE: hard;
array[GUARD] of TIME: tired;

GUARD: p; % maximum people on pier;
GUARD: b; % maximum people on boat;

set of int: ACT = -1..E; % -1 = goto bank, 0 = wait, > 0 carry stones  
int: wait = 0;
int: to_bank = -1;
array[GUARD,TIME] of var ACT: act;        % action at time t
var TIME: end;                            % end time;

% 1 what the guards could do: carrting east, hard, rest and return
constraint forall(i in GUARD,t in TIME)(act[i,t] = -1 \/ act[i,t] = 0 \/ act[i,t] = easy[i] \/ act[i,t] = hard[i]);
% 1 no guard move to bank in step 1
constraint forall(i in GUARD)(act[i,1] != -1);

% stones on boat
array[0..T] of var 0..E: stboat; 
constraint stboat[0] = 0;
constraint forall(t in TIME)(stboat[t] = sum([act[i,k]|i in GUARD,k in 1..t where act[i,k] > 0]));
constraint stboat[end] = E;

% 1 define end
%constraint end=sum(t in TIME)(if sum(i in GUARD)(act[i,t] != 0) > 0 then 1 else 0 endif);

% 1 after end all soldier wait
%constraint forall(i in GUARD,t in end+1..T)(act[i,t] = 0);
constraint forall(i in GUARD,t in TIME where t > end)(act[i,t] = 0);

% 1 stones on boat is E
% array[GUARD,TIME] of var 0..E: carried;
% constraint forall(i in GUARD,t in TIME)(
%     if act[i,t] < 0 then carried[i,t] = 0 else carried[i,t] = act[i,t] endif);
% constraint sum(i in GUARD,t in 1..end)(carried[i,t]) >= E;
%constraint sum([act[i,t]|i in GUARD,t in 1..end where act[i,t] > 0]) >= E;

% guards on boat
% array[TIME] of var GUARD: gdboat; 
constraint forall(t in TIME)(sum([1|i in GUARD where act[i,1] > 0]) < b);
% constraint sum([1|i in GUARD, j in 1..(end div 2)+1 where act[i,2*j] > 0]) < b;          
% predicate on_boat(GUARD:i,TIME:t) =
%     sum([if act[i,tmpT] > 0 then 1 else act[i,tmpT] endif | tmpT in 1..t]) = 1;
% constraint forall(t in TIME)(sum([on_boat(i, t) | i in GUARD]) <= b);

% 1 guards on pier
%constraint forall(t in TIME)(sum([if act[i,t] != 0 then 1 else 0 endif|i in GUARD]) <= p);
constraint forall(t in TIME)(sum([1|i in GUARD where act[i,t] != 0]) <= p);

% 1 moves in same direction
constraint forall(i,j in GUARD where i < j,t in TIME)(act[i,t] * act[j,t] >= 0);                                       

% 1 rest after hard work
constraint forall(i in GUARD,t in 1..end-1)(act[i,t] > easy[i] -> forall(k in t+1..min(t+tired[i],T))(act[i,k] <= 0));

% 1 after carrying stones the soldier must return immediately or return after rest
constraint forall(i in GUARD,t in 1..end-1)(act[i,t] > 0 -> 
        (act[i,t+1] = -1 \/ exists(aft in t+2..T)(act[i,aft]=-1 /\ forall(midt in t+1..aft-1)(act[i,midt]=0))));
% 1 before return the soldier must carrying stones or
constraint forall(i in GUARD, t in 2..T,)(act[i,t] = -1 -> 
        (act[i,t-1] > 0 \/ exists(bft in 1..t-2)(act[i,bft] > 0 /\ forall(midt in bft+1..t-1)(act[i,midt]=0))));

solve minimize end;
output ["act = act[GUARD,TIME]([\n"] ++
       [ show_int(2,act[i,t]) ++ "," ++ "\t"
       ++ if t = T /\ i = G then "]);\n" elseif t = T then "\n" else "" endif
       | i in GUARD, t in TIME ] ++
       ["end =" ++ show_int(2, end) ++ ";"]

