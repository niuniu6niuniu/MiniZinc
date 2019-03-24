% input data part
array[int] of int: readings;
int: start;
% the number of the temps/readings
int: l = length(readings);
set of int: TIME = 1..length(readings);
% the temp
array[TIME] of var 25..30: temp;
constraint temp[0] = start;
enum Action = {H, SH, C, SC, NO};
array[Action] of int: adjust = [+1,+4,-2,-5,0];
constraint forall(i in 1..l)(temp[i] = (temp[i-1] + readings[i]) div 2 + 
                  adjust[Action[i]]);
solve satisfy;
output ["\(temp)\n\(Action)\n"];