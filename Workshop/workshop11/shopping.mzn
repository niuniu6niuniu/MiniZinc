int: n; % number of arrow types
set of int: ARROW = 1..n;
array[ARROW] of int: price;   % price of each arrow type

int: m; % number of merchants
set of int: MERCHANT = 1..m;
array[MERCHANT] of int: buy;   % buy this many to use deal
array[MERCHANT] of int: free;  % get this many free

set of int: ASSIGN = -m .. m; % -i arrow is assigned to buy for deal of merchant i
                              %  i arrow is assigned as free from deal of merchant i
                              %  0 no deal used on arrow

% array[ARROW] of var ASSIGN: how;
array[ARROW,ASSIGN] of var 0..1: how;
% array[MERCHANT] of var bool: used;
array[MERCHANT] of var 0..1: used;

% for each the arrow only one way to get it
constraint forall(a in ARROW)(sum(v in ASSIGN)(how[a,v]) = 1);

% assign right number of arrows to enable deal
% constraint forall(v in MERCHANT)(used[v] <-> sum(a in ARROW)(how[a] = -v) >= buy[v]);
% constraint forall(v in MERCHANT)(sum(a in ARROW)(how[a] = -v) <= used[v]*buy[v]);
constraint forall(v in MERCHANT)(sum(a in ARROW)(how[a,-v]) = used[v]*buy[v]);

% assign not too many arrows for free for deal
% constraint forall(v in MERCHANT)(sum(a in ARROW)(how[a] = v) <= used[v]*free[v]);
constraint forall(v in MERCHANT)(sum(a in ARROW)(how[a,v]) <= used[v]*free[v]);

% Ensure arrows free in deal are not more expensive than arrows bought
% constraint forall(a1, a2 in ARROW)((how[a1] < how[a2] /\ how[a1] = -how[a2]) 
%                                   -> price[a2] <= price[a1]);
constraint forall(a1, a2 in ARROW where price[a2] > price[a1])
           (forall(v in MERCHANT)(how[a1,-v] + how[a2,v] <= 1));
                                        

int: total = sum(price);
var 0..total: objective = sum(a in ARROW)(sum(v in -m..0)(how[a,v])*price[a]);

solve minimize objective;

output  
   ["how = "++show(how)++";\nobjective = "++show(objective)++";\n"];




