int: PROBLEM_STAGE; %Identifier to be used for each instance. If you write a MiniZinc model to solve the problem, this can be ignored.

int: n;
set of int: PERSON = 1..n;
int: k;
set of int: CAMPSITE = 1..k;
int: maxsize;
array[int,1..2] of int: ML;                 % represents two people from the same family
array[int,1..2] of int: CL;                 % represents two people dislike each other
set of int: FAMILY = index_set_1of2(ML);    % set of number of family combinations from 1 to ..
set of int: DISLIKE = index_set_1of2(CL);   % set of number of dislike combinations from 1 to ..
array[int,1..2] of PERSON: E;               % represents two people knows each other
set of int: EDGE = index_set_1of2(E);       % set of number of knowing combinations from 1 to ..

% For each person which camp he should in
array[PERSON] of var CAMPSITE: x;
array[PERSON,CAMPSITE] of var 0..1: x1;
constraint forall(p in 1..n)(forall(c in 1..k where x1[p,c] = 1)(x[p] = c));
% For each person only appear in one camp
constraint forall(p in 1..n)(sum(c in 1..k)(x1[p,c]) = 1);

% Number of members in each camp must smallert than the capcity
constraint forall(c in 1..k)(sum(p in 1..n)(x1[p,c]) <= maxsize);

% Family members in same camp
constraint forall(f in FAMILY,c in 1..k)(x1[ML[f,1],c] - x1[ML[f,2],c] = 0);

% Dislike members in different camps
constraint forall(d in DISLIKE,c in 1..k)(x1[CL[d,1],c] + x1[CL[d,2],c] < 2);

% Complex Objective
int: m = card(EDGE);                                                     
array[1..n] of var int: d;
constraint forall(p in 1..n)(d[p] = sum(e in EDGE,j in 1..2)(E[e,j] = p)); 
var int: p1 = sum(e in EDGE,c in 1..k)(x1[E[e,1],c] * x1[E[e,2],c]);
var int: p2 = sum(c in 1..k)(sum(p in 1..n)(x1[p,c] * d[p]) * sum(p in 1..n)(x1[p,c] * d[p]));
var int: obj = 4 * m * p1 - p2;

%%%%%%%%%% SEARCH %%%%%%%%%%% 
% VARIABLES: x
% input_order; 
% first_fail; 
% smallest; 
% largest;
% dom_w_deg;
% VALUES
% indomain_min; 
% indomain_max; 
% indomain_median; 
% indomain_random; 
% indomain_split;
% indomain_reverse_split;
annotation relax_and_reconstruct(array[int] of var int,int);
solve :: int_search(x1,dom_w_deg,indomain_random,complete)
      :: relax_and_reconstruct(x,80)
      maximize obj;
output ["x=\(x);\nobj=\(obj);"]
