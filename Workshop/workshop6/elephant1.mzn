int: T; % maximum time allowed;
set of int: TIME = 1..T;
int: G; % number of guards
int: F; 
int: W;

array[TIME] of var -F..F: move_food;    % move food +ve bank to boat, -ve boat to bank
array[TIME] of var -W..W: move_water;   % move water +ve bank to boat, -ve boat to bank
var TIME: end;                          % end time;

set of int: TIME0 = 0..T; % set the time as an index 

array[TIME0] of var 0..F: fboat; % the food on boat at a certain time
% the food on bank: fbank = F - fboat
array[TIME0] of var 0..W: wboat; % the water on boat at a certain time
% the water on bank: wbank = W - wboat

constraint pos[0] = Bank;
constraint fboat[0] = 0;
constraint wboat[0] = 0;
constraint forall(t in TIME)(fboat[t] = move_food[t] + fboat[t-1]);
constraint forall(t in TIME)(wboat[t] = move_water[t] + wboat[t-1]);
constraint forall(t in TIME)(abs(move_food[t]) + abs(move_water[t]) <= G);
constraint forall(t in TIME)(move_food[t] * move_water[t] >= 0);

enum POS = {Bank,Boat}; % keep track the position of elephant
array[TIME0] of var POS: pos; % the elephant's position at a certain time

predicate move(var 0..F: fdhere, var 0..W: wthere) = 
               let { var 0..F: fdthere = F - fdhere,
                     var 0..W: wtthere = F - wthere; } in
               (fdthere = wtthere /\ fdthere > fdhere /\ wtthere > wthere);

array[POS] of POS: opp = [Boat, Bank];
predicate elephant(var POS: now, var 0..F: fdhere, var 0..W: wthere, var POS: next) =
                   next = [ now, opp[now]][move(fdhere,wthere) + 1] /\ 
                   (fdhere = 0 <-> wthere = 0);
            
constraint forall(t in TIME)(
                        let{ var 0..F: fdhere = [F - fboat[t-1], fboat[t-1]][pos[t-1]];
                             var 0..W: wthere = [W - wboat[t-1], wboat[t-1]][pos[t-1]];} in
                             elephant(pos[t-1], fdhere, wthere, pos[t]));

constraint pos[end] = Boat /\ fboat[end] = 0 /\ wboat[end] = 0; 
constraint forall(t in TIME)(t > end -> move_food[t] = 0 /\ move_water[t] = 0);

solve minimize end;

