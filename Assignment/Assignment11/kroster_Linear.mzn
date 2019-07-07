%------------------------------------------------------------------------------%
% Input Parameters
%------------------------------------------------------------------------------%
int: week_length;                        % Length of the schedule
set of int: DAY = 1..week_length;    % Set of lengths of the schedule

int: nb_workers;    % Number of the workers

int: min_daysoff;   % Minimal length of days-off blocks
int: max_daysoff;   % Maximal length of days-off blocks

int: min_work;      % Minimal length of work blocks
int: max_work;      % Maximal length of work blocks

int: nb_shifts;                            % Number of shifts
set of int: SHIFT = 1..nb_shifts;          % Set of shifts
int: OFF = nb_shifts+1;                    % off shift
set of int: SHIFT0 = 1..nb_shifts+1;       % Set of shifts + off shift
array[SHIFT] of string: shift_name;        % Name of shifts
array[SHIFT] of int:    shift_block_min;   % Minimal length of blocks
array[SHIFT] of int:    shift_block_max;   % Maximal length of blocks

array[SHIFT, DAY] of int: temp_req;    % Temporal requirements

int: nb_forbidden;                              % Number of forbidden shift sequences
set of int: FORBIDDEN = 1..nb_forbidden;                          % Set of forbidden shift sequences
array[FORBIDDEN] of int:  forbidden_before;     % The shift before in the forbidden sequence
array[FORBIDDEN] of int:  forbidden_after;      % The shift after in the forbidden sequence

int: extended_days = (nb_workers+1) * week_length; % The total number of days(normal weeks + one copy week)
%------------------------------------------------------------------------------%
% Decision Variables
%------------------------------------------------------------------------------%  
set of int: WEEK = 1..nb_workers+1;        
array[WEEK,DAY] of var SHIFT0: plan;
set of int: DAYS = 1..extended_days;
array[DAYS] of var SHIFT0: plan1 = array1d(plan);
array[DAYS,SHIFT0] of var 0..1: plan2; 
constraint forall(d in DAYS)(plan1[d] = sum(sh in SHIFT0)(sh * plan2[d,sh]));
int: norm_days =  nb_workers * week_length;

%------------------------------------------------------------------------------%
% Constraints
%------------------------------------------------------------------------------%

% the n+1th week is identical to the 1st week
constraint forall(d in 1..week_length)(forall(sh in SHIFT0)(
                  plan2[d+nb_workers*week_length,sh] = plan2[d,sh]));

% only one shift 
constraint forall(d in 1..norm_days)(sum(sh in SHIFT0)(plan2[d,sh]) = 1);

% ------------------------- Change 1 ------------------------- 
% The minimum number of shifts occur on each day of the week
constraint forall(d in DAY)(forall(sh in SHIFT)(sum(n in 1..nb_workers)
                 (plan2[d+(n-1)*week_length,sh]) >= temp_req[sh,d]));  
                         
constraint forall(d in DAY)(forall(sh in SHIFT)(sum(n in 1..nb_workers)
                 (plan2[d+(n-1)*week_length,sh]) <= nb_workers));

% ------------------------- Change 2 ------------------------- 
% No sequence of too many of the same shift                             
constraint forall(sh in SHIFT)(forall(d in 1..extended_days-shift_block_max[sh])
                 (sum(d1 in d..d+shift_block_max[sh])
                 (plan2[d1,sh]) <= shift_block_max[sh]));

constraint forall(sh in SHIFT)(forall(d in 1..extended_days-shift_block_max[sh])
                 (sum(d1 in d..d+shift_block_max[sh])
                 (plan2[d1,sh]) >= 0));
                          
% ------------------------- Change 3 -------------------------                                   
% no sequence of too many work shifts                              
constraint forall(d in 1..extended_days-max_work)
           (sum(d1 in d..d+max_work)(1-plan2[d1,OFF]) >= 0);
           
constraint forall(d in 1..extended_days-max_work)
           (sum(d1 in d..d+max_work)(1-plan2[d1,OFF]) <= max_work);

% ------------------------- Change 4 ------------------------- 
% no sequence of too many off shifts
constraint forall(d in 1..extended_days-max_daysoff)
           (sum(d1 in d..d+max_daysoff)(plan2[d1,OFF]) <= max_daysoff);                                                     
           
constraint forall(d in 1..extended_days-max_daysoff)
           (sum(d1 in d..d+max_daysoff)(plan2[d1,OFF]) >= 0);                                                     
  
% ------------------------- Change 5 -------------------------                         
% No sequence of too few of the same shift
constraint forall(sh in SHIFT,d in 1..extended_days-shift_block_min[sh])
                 (sum(d1 in d+2..d+shift_block_min[sh])(plan2[d1,sh]) 
                 >= (shift_block_min[sh]-1)*(plan2[d+1,sh]-plan2[d,sh]));

% ------------------------- Change 6 -------------------------                                      
% No sequence of too few work days
constraint forall(d in 1..extended_days-min_work)(
           sum(d1 in d+2..d+min_work)(1-plan2[d1,OFF]) 
           >= (min_work-1)*(plan2[d,OFF]-plan2[d+1,OFF])); 

% ------------------------- Change 7 -------------------------                    
% No sequence of too few off days                                     
constraint forall(d in 1..extended_days-min_daysoff)
                 (sum(d1 in d+2..d+min_daysoff)
                 (plan2[d1,OFF]) >= (min_daysoff-1)*(plan2[d+1,OFF]-plan2[d,OFF])); 

% ------------------------- Change 8 ------------------------- 
% No forbidden sequences                 
constraint forall(d in 1..extended_days-1)(forall(f in FORBIDDEN)
                 (plan2[d,forbidden_before[f]] + plan2[d+1,forbidden_after[f]] < 2));                   

% ------------------------- Change 9 -------------------------       
% var int: obj = sum(w in 1..nb_workers, d in DAY)(plan[w,d] = OFF);
var int: obj = sum(d in 1..norm_days)(plan2[d,OFF]);
solve maximize obj;

%------------------------------------------------------------------------------%
% Output
%------------------------------------------------------------------------------%
output
       ["% "] ++
       [ if fix(plan[w,d]) in SHIFT then shift_name[fix(plan[w,d])] else "." endif ++
         if d = week_length then "\n% " else " " endif | w in WEEK, d in DAY]
       ++
       ["\nplan = array2d(WEEK,DAY,\(plan));\n"] ++
       ["obj = \(obj);\n"];


