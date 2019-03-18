% workshop 2
% select a set of trade negotiation party
enum NEGOTIATOR;
NEGOTIATOR: dummy; 

int: l; % minimum party size
int: u; % maximum party size
int: m; % minimum joint ability

array[NEGOTIATOR] of int: honor;
array[NEGOTIATOR,NEGOTIATOR] of int: joint;

%%%%%%%%-----
array[1..u] of var NEGOTIATOR: party_arr;


constraint forall(i in 1..l)(party_arr[i] > dummy);

constraint forall(i in 1..u-1)(party_arr[i] >= party_arr[i+1] + (party_arr[i+1] != dummy));

constraint sum(i,j in 1..u where i < j)(joint[party_arr[i],party_arr[j]]) >= m;

solve maximize obj;

var int: obj;
constraint obj =  (min(j in 1..u)((party_arr[j] = dummy)*max(honor) + honor[party_arr[j]]));

set of NEGOTIATOR: party :: output_only = { fix(party_arr[i]) | i in 1..u } diff {dummy};

output ["party = \(party);\n"];
