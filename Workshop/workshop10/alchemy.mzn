include "globals.mzn";

int: n_potions;
set of int: POTION = 1..n_potions;
array [POTION] of int: alchemy;
int: n_days;
int: min_potions;
int: max_potions;
int: min_alchemists;
int: max_alchemists;
int: total_alchemy = sum(alchemy);
array[int,1..2] of POTION: prereqs;

set of int: DAY = 1..n_days;

%% decision variables   
array[POTION] of var DAY: day;
array[POTION,DAY] of var 0..1: potion_day;
array[DAY] of var set of POTION: potions;

%% auxilliary variables
% number of potions made on each day   
array[DAY] of var min_potions..max_potions: number;
% total alchemists required on each day
array[DAY] of var min_alchemists..max_alchemists: working;
% optimisation target
var min_alchemists..max_alchemists: objective;

% load is less than objective   
constraint forall(d in DAY)
                 (working[d] <= objective);
   
% day view: potion prerequisites
constraint forall(i in index_set_1of2(prereqs))
                 (day[prereqs[i,1]] < day[prereqs[i,2]]);
% potion_day view: potion prerequisites
%constraint forall(i in index_set_1of2(prereqs))
%                 ( sum(d in DAY)(d*potion_day[prereqs[i,1],d]) <   
%                   sum(d in DAY)(d*potion_day[prereqs[i,2],d]));
% potions view: potion prerequisites
%constraint forall(i in index_set_1of2(prereqs))
%                 (forall(d1 in 1..n_days, d2 in 1..d1)
%                       (prereqs[i,1] in potions[d1] -> 
%                        not (prereqs[i,2] in potions[d2])));
     

% day view: definition of number of potions made in day
constraint forall(d in DAY)
                 ( number[d] = sum(p in POTION) (day[p] = d) );
% potion_day view: definition of number of potions made in day
%constraint forall(d in DAY)
%                ( number[d] = sum(p in POTION) (potion_day[p,d]) );
% potions view: definition of number of potions made in day
%constraint forall(d in DAY)
%                 ( number[d] = card(potions[d]) );

% day view: calculation of alchemists working on day
constraint forall(d in DAY)
                 (working[d] = sum(p in POTION) 
                                  ((day[p] = d) * alchemy[p]));
% potion_day view: calculation of alchemists working on day 
%constraint forall(d in DAY)
%                 (working[d] = sum(p in POTION)
%                                  (potion_day[p,d] * alchemy[p]));
% potions view: calculation of alchemists working on day  
%constraint forall(d in DAY)
%                 (gecode_set_weights(POTION, alchemy,   
%                                     potions[d],working[d]));
% Note the potions view make use of this global constraint from Gecode
predicate gecode_set_weights(array[int] of int: csi,array[int] of int: cs,
                             var set of int: x, var int: y);


% day view: potions are not assigned to two days
constraint true; % automatic
% potion_day view: potions are not assigned to two days
%constraint forall(p in POTION)(sum(d in DAY)(potion_day[p,d]) = 1);
% potions view: potions are not assigned to two days
%constraint all_disjoint(potions);

% channeling between day and potion_day views
%constraint forall(d in DAY) 
%                 (forall(p in POTION) 
%                        (potion_day[p,d] = (day[p] = d)));
                                                                        
% channeling between potion_day and potions views
%constraint forall(d in DAY)
%                 (forall(p in POTION) 
%                        (potion_day[p,d] = (p in potions[d])));

% channeling between day and potions views
%constraint int_set_channel(day, potions);
   
% redundant all alchemy required must be used
constraint sum(d in DAY)(working[d]) = total_alchemy;

% redundant all potions must be made
constraint sum(d in DAY)(number[d]) = n_potions;

% day view: redundant linear constraints
constraint forall(d in 0..n_days-1) 
   ( let {  var 0..total_alchemy: l = sum(p in POTION)
                                       ((day[p] > d) * alchemy[p])
         } in 
         l >= (n_days-d) * min_alchemists /\
         l <= (n_days-d) * objective
    );
% potion_day view: redundant linear constraints
%constraint forall(d in 0..n_days-1) 
%   ( let {  var 0..total_alchemy: l = sum(p in POTION)
%                    (sum(j in d+1..n_days)(potion_day[p,j]) * alchemy[p])
%         } in 
%         l >= (n_days-d) * min_alchemists /\
%         l <= (n_days-d) * objective
%    );
% potions view: redundant linear constraints
%constraint forall(d in 0..n_days-1) 
%   ( let {  var 0..total_alchemy: l = sum(p in POTION)
%                    (sum(j in d+1..n_days)(p in potions[j]) * alchemy[p])
%         } in 
%         l >= (n_days-d) * min_alchemists /\
%         l <= (n_days-d) * objective
%    );

ann: search;
solve :: search 
      minimize objective;

search = search1;

ann: search1 = int_search(day, input_order, indomain_min, complete);


% day view: output
array[DAY] of set of POTION: answer :: output_only = 
     [ { p | p  in POTION where fix(day[p]) = d } | d in DAY ];
% potion_day: output
%array[DAY] of set of POTION: answer :: output_only = 
%     [ { p | p in POTION where fix(potion_day[p,d]) = 1 } | d in DAY ];
% potion: output
%array[DAY] of set of POTION: answer :: output_only = fix(potions);     


output
  ["potions = \(answer);\n" ] ++
  ["objective = \(objective);\n"];  
