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
array[TASK,TASK] of var 0..1: b;
constraint forall(t1, t2 in TASK 
                  where t1 >= t2 \/ not exists(i in DISJ)({t1,t2} subset disj[i]))
                 (b[t1,t2] = 0);
constraint forall(i in DISJ, t1, t2 in disj[i] where t1 < t2)
                 ( (b[t1,t2]  = 1 -> e[t1] <= s[t2]) /\
                   (b[t1,t2]  = 0 -> e[t2] <= s[t1]) );
                  
var 0..maxt: makespan = max(e);


%ann: varsel = input_order; 
ann: varsel = first_fail; 
%ann: varsel = smallest; 
%ann: varsel = largest;
ann: valsel = indomain_min; 
%ann: valsel = indomain_max; 
%ann: valsel = indomain_median; 
%ann: valsel = indomain_random; 


solve %:: int_search(s, smallest, indomain_min, complete)
      :: int_search(s, varsel, valsel, complete)
      minimize makespan;

output ["makespan = ", show(makespan), "\n" ] ++
       [ show_int(3,s[t]) ++ " " 
       | t in TASK]; 
