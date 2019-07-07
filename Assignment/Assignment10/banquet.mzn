% Preparing a banquet in the least time
enum COOK; % the set of cooks available
enum DISH; % the set of all dishes to prepare
int: no_tasks; % total number of tasks
set of int: TASK = 1..no_tasks;
array[DISH] of set of TASK: steps; % steps to making a dish
array[TASK, COOK] of int: time; % amount of time to complete task by cook

int: maxt = sum(array1d(time));
set of int: TIME = 0..maxt;
array[TASK] of var TIME:    s;  % start time for task
array[TASK] of var TIME:    e;  % end time for task
array[TASK] of var COOK:    c;  % cook for task

% some cook can't do some tasks
constraint forall(t in TASK, p in COOK)(time[t,COOK[p]] = 0 -> c[t] != COOK[p]);

% duration of tasks
constraint forall(t in TASK)(e[t] = s[t] + time[t,c[t]]);

% steps finished in certain order
constraint forall(d in DISH,t1,t2 in TASK where t1 < t2)(t1 in steps[d] /\ t2 in steps[d] -> e[t1] <= s[t2]);

% one cook can't do two task at one time
predicate nonoverlap(var int:s1, var int:d1,var int:s2, var int:d2) = s1 + d1 <= s2 \/ s2 + d2 <= s1;
constraint forall(t1, t2 in TASK where t1 < t2)(c[t1] = c[t2] -> nonoverlap(s[t1],time[t1,c[t1]],s[t2],time[t2,c[t2]]));

% minimize the end time
var TIME: obj;                                  
constraint forall(t in TASK)(obj = max(e));

%%%%%%%%%% SEARCH %%%%%%%%%%% 
%variables: s(start time), e(end time), c(cook for task)
%ann: varsel = input_order; 
%ann: varsel = first_fail; 
%ann: varsel = smallest; 
%ann: varsel = largest;
%ann: varsel = dom_w_deg;

%ann: valsel = indomain_min; 
%ann: valsel = indomain_max; 
%ann: valsel = indomain_median; 
%ann: valsel = indomain_random; 
%ann: valsel = indomain_split;
%ann: valsel = indomain_reverse_split;

% % Restart

solve :: int_search(c, first_fail, indomain_random, complete)
      minimize obj;
      
output
  ["s = \(s);\n" ] ++
  ["c = \(c);\n"] ++
  ["obj = \(obj);\n"];  