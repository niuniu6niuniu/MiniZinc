% Warning the village
int: n; % number of houses
set of int: HOUSE = 1..n; 
array[HOUSE] of int: x;
array[HOUSE] of int: y;
int: limit; % max time allowed

int: m; % number of messengers
set of int: MESSENGER = 1..m;
array[MESSENGER] of var HOUSE: messenger; % who are the messengers

% nodes
% 1..N are villagers
% n+1..n+m are end trip node
set of int: NODE = 1..n+m;
array[NODE] of var NODE: next;   % next node visited after this one
var 0..limit: endtime;

