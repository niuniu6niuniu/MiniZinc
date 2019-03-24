int: n;
set of int: TASK = 1..n;
array[TASK] of int:  d;  % length of task

int: m;
set of int: PREC = 1..m;
array[PREC] of TASK:  pre;  % task pre[i] must finish before post[t] starts
array[PREC] of TASK:  post; % 

int: o; 
set of int: DISJ = 1..o;
array[DISJ] of set of TASK: disj; % sets of tasks which cant overlap in time

int: maxt = sum(t in TASK)(d[t]);

array[TASK] of var 0..maxt: s; % start time
array[TASK] of var 0..maxt: e = [ s[t] + d[t] | t in TASK]; % end time


% performs tasks obey precedences
constraint forall(i in PREC)
                 (e[pre[i]] <= s[post[i]]);

% no two disjoint tasks overlap
include "disjunctive.mzn";
include "cumulative.mzn";
constraint forall(i in DISJ)
                 (disjunctive([ s[t] | t in disj[i]], [ d[t] | t in disj[i] ]));                  
                        

var 0..maxt: makespan = max(e);

   solve %    :: int_search(s, smallest, indomain_min, complete)
      :: int_search(e, input_order, indomain_max, complete)
      minimize makespan;

output ["makespan = ", show(makespan), "\n" ] ++
       [ show_int(3,s[t]) ++ " " 
       | t in TASK]; 
