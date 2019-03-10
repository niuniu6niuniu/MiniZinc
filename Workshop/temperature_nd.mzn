% input data part
array[int] of int: readings;
int: start;
% the number of the temps/readings
int: l = length(readings);
set of int: TIME0 = 0..length(readings);
set of int: TIME = 1..length(readings);
% the temp
array[TIME0] of var 25..30: temp;
array[TIME] of var Action: choice;
constraint temp[0] = start;
enum Action = {H, SH, C, SC, NO};
array[Action] of int: adjust = [+1,+4,-2,-5,0];
array[Action] of var int: c = [1,5,3,9,0];
constraint forall(i in TIME)(temp[i] = (temp[i-1] + readings[i]) div 2 + 
                  adjust[choice[i]]);
var int: cost = sum(i in TIME)(c[choice[i]]);                 
solve minimize cost;
output ["temp=\(temp);\nAction=\(choice);\ncost=\(cost);"];