int: length; % length of lake
set of int: LENGTH = 0..length-1;
int: width; % width of lake
set of int: WIDTH = 0..width-1;

int: ntypes;  % number of types of ship
set of int: TYPE = 1..ntypes;
array[TYPE] of int: number;         % number of each type of ship
array[TYPE] of set of SHAPE: config; % configs for each type of ship

int: nshapes; % number of shapes
set of int: SHAPE = 1..nshapes;
set of int: SHAPE0 = 0..nshapes;
array[SHAPE] of set of ROFF: shape;

int: nroff; % number of rectangle offsets
set of int: ROFF = 1..nroff;
array[ROFF,1..4] of int: rectoff; % x offset, y offset, width, height

int: total_ships = sum(number);
set of int: SHIP = 1..total_ships;
array[SHIP] of var LENGTH:  x;
array[SHIP] of var WIDTH:   y;
array[SHIP] of var SHAPE0:  k;

array[LENGTH] of WIDTH: mist; % mist starts at this width, goes downward
array[WIDTH] of int: arrow;  % number of arrows that arrive at this height
array[TYPE] of int: price;
int: budget;
enum STAGE = {A,B,C,D,E,F};
STAGE: stage;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% include "globals.mzn";
include "geost.mzn";

% record the size and offset of each rectangle
array[ROFF, 1..2] of int: rsize = array2d(ROFF, 1..2, [rectoff[i,j]|i in ROFF, j in 3..4]);
array[ROFF, 1..2] of int: roff = array2d(ROFF, 1..2, [rectoff[i,j]|i in ROFF, j in 1..2]);

% record the x offset, y offset
array[SHIP, 1..2] of var int: coord;
constraint forall(i in SHIP)(coord[i,1] = x[i] /\ coord[i,2] = y[i]);

% Mapping ships to type
array[SHIP] of var TYPE: which_type;
constraint which_type[1] = 1;
constraint forall(the_ship in 2..total_ships)(
    if sum(tp in 1..which_type[the_ship-1])(number[tp]) >= the_ship then
    which_type[the_ship] = which_type[the_ship-1] 
    else which_type[the_ship] = which_type[the_ship-1] + 1 endif);

var int: tarrows;

%%%%%%%%%%%%%%%%%%%%%Stage A%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ignore arrows
constraint stage = A -> tarrows = 0;
% ignore ship shape
constraint stage = A -> forall(sp in SHIP)(k[sp] = 1);

% Within the river boundaries
constraint stage = A -> forall(sp in SHIP)(x[sp] + rectoff[which_type[sp], 3] < length);
constraint stage = A -> forall(sp in SHIP)(y[sp] + rectoff[which_type[sp], 4] < width);

% No overlap
constraint stage = A ->
forall(sp1, sp2 in SHIP where sp1 < sp2)(x[sp1] >= x[sp2] + rectoff[which_type[sp2], 3] \/ 
                                         x[sp2] >= x[sp1] + rectoff[which_type[sp1], 3] \/
                                         y[sp1] >= y[sp2] + rectoff[which_type[sp2], 4] \/ 
                                         y[sp2] >= y[sp1] + rectoff[which_type[sp1], 4]);

% Symetric breaking - ship in same type should be ordered, not interchangeable
constraint stage = A -> forall(sp1, sp2 in SHIP where sp1 < sp2 /\ which_type[sp1] = which_type[sp2])(
                              (x[sp1] = x[sp2] /\ y[sp1] > y[sp2]) \/ (x[sp1] > x[sp2]));

%%%%%%%%%%%%%%%%%%%%%%Stage B%%%%%%%%%%%%%%%%%%%%%%%%%%

constraint stage = B -> tarrows = 0;
constraint stage = B -> forall(sp in SHIP)(k[sp] = 1);

% Within the river boundaries, types = shapes
constraint stage = B -> forall(sp in SHIP)(
                        forall(s in shape[which_type[sp]])(
                        x[sp] + rectoff[s, 1] + rectoff[s, 3] <= length /\
                        y[sp] + rectoff[s, 2] + rectoff[s, 4] <= width));

% No overlap
constraint stage = B -> forall(sp1, sp2 in SHIP where sp1 < sp2)(
    forall(s1 in shape[which_type[sp1]], s2 in shape[which_type[sp2]])(
    x[sp1] + rectoff[s1,1] >= x[sp2] + rectoff[s2,1] + rectoff[s2,3] \/ 
    x[sp2] + rectoff[s2,1] >= x[sp1] + rectoff[s1,1] + rectoff[s1,3] \/
    y[sp1] + rectoff[s1,2] >= y[sp2] + rectoff[s2,2] + rectoff[s2,4] \/ 
    y[sp2] + rectoff[s2,2] >= y[sp1] + rectoff[s1,2] + rectoff[s1,4]));

% Symetric breaking - ship in same type should be ordered, not interchangeable
constraint stage = B -> forall(sp1, sp2 in SHIP where sp1 < sp2 /\ which_type[sp1] = which_type[sp2])(
                              (x[sp1] = x[sp2] /\ y[sp1] > y[sp2]) \/ (x[sp1] > x[sp2]));

%%%%%%%%%%%%%%%%%%%%%%Stage C%%%%%%%%%%%%%%%%%%%%%%%%%%%

constraint stage = C -> tarrows = 0;
constraint stage = C -> forall(sp in SHIP)(k[sp] = 1);

% Within the river boundaries
constraint stage = C -> forall(sp in SHIP)(
                        forall(s in shape[which_type[sp]])(
                        x[sp] + rectoff[s, 1] + rectoff[s, 3] <= length /\
                        y[sp] + rectoff[s, 2] + rectoff[s, 4] <= width));

% No overlap
constraint stage = C -> forall(sp1, sp2 in SHIP where sp1 < sp2)(
    forall(s1 in shape[which_type[sp1]], s2 in shape[which_type[sp2]])(
    x[sp1] + rectoff[s1,1] >= x[sp2] + rectoff[s2,1] + rectoff[s2,3] \/ 
    x[sp2] + rectoff[s2,1] >= x[sp1] + rectoff[s1,1] + rectoff[s1,3] \/
    y[sp1] + rectoff[s1,2] >= y[sp2] + rectoff[s2,2] + rectoff[s2,4] \/ 
    y[sp2] + rectoff[s2,2] >= y[sp1] + rectoff[s1,2] + rectoff[s1,4]));

% Symetric breaking - ship of the same type should be ordered, not interchangeable
constraint stage = C -> forall(sp1, sp2 in SHIP where sp1 < sp2 /\ which_type[sp1] = which_type[sp2])(
                        (x[sp1] = x[sp2] /\ y[sp1] > y[sp2]) \/ (x[sp1] > x[sp2]));

% Hiden under mist
constraint stage = C -> forall(tmpX in LENGTH)(
                        forall(sp in SHIP)(
                        forall(s in shape[which_type[sp]])(
                               x[sp] + rectoff[s,1] > tmpX \/
                               x[sp] + rectoff[s,1] + rectoff[s,3] < tmpX \/
                               y[sp] + rectoff[s,2] >= mist[tmpX])));


%%%%%%%%%%%%%%%%%%%%%%Stage D%%%%%%%%%%%%%%%%%%%%%%%%%%%

constraint stage = D -> forall(sp in SHIP)(k[sp] = which_type[sp]);

% Within the river boundaries
constraint stage = D -> forall(sp in SHIP)(
                        forall(s in shape[which_type[sp]])(
                        x[sp] + rectoff[s, 1] + rectoff[s, 3] <= length /\
                        y[sp] + rectoff[s, 2] + rectoff[s, 4] <= width));

% No overlap
constraint stage = D -> forall(sp1, sp2 in SHIP where sp1 < sp2)(
    forall(s1 in shape[which_type[sp1]], s2 in shape[which_type[sp2]])(
    x[sp1] + rectoff[s1,1] >= x[sp2] + rectoff[s2,1] + rectoff[s2,3] \/ 
    x[sp2] + rectoff[s2,1] >= x[sp1] + rectoff[s1,1] + rectoff[s1,3] \/
    y[sp1] + rectoff[s1,2] >= y[sp2] + rectoff[s2,2] + rectoff[s2,4] \/ 
    y[sp2] + rectoff[s2,2] >= y[sp1] + rectoff[s1,2] + rectoff[s1,4]));

% Symetric breaking - ship of the same type should be ordered, not interchangeable
constraint stage = D -> forall(sp1, sp2 in SHIP where sp1 < sp2 /\ which_type[sp1] = which_type[sp2])(
                        (x[sp1] = x[sp2] /\ y[sp1] > y[sp2]) \/ (x[sp1] > x[sp2]));

% Hiden under mist
constraint stage = D -> forall(tmpX in LENGTH)(
                        forall(sp in SHIP)(
                        forall(s in shape[which_type[sp]])(
                               x[sp] + rectoff[s,1] > tmpX \/
                               x[sp] + rectoff[s,1] + rectoff[s,3] < tmpX \/
                               y[sp] + rectoff[s,2] >= mist[tmpX])));

% count arrows
constraint stage = D -> tarrows = sum(sp in SHIP)(
                                  sum(s in shape[which_type[sp]])(
                                  sum(tmpY in 0..rectoff[s,4]-1)(
                                      arrow[y[sp]+rectoff[s,2]+tmpY]*rectoff[s,3])));

%%%%%%%%%%%%%%%%%%%%%%Stage E%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Use kind instead of k in stage E
array[SHIP] of var SHAPE:  kind;

constraint stage = E ->
geost_bb(2,
    rsize,
    roff,
    shape,
    coord,
    kind,
    [0,0],
    [length, width]);

% Symetric breaking - ship of the same type should be ordered
constraint stage = E -> forall(sp1, sp2 in SHIP where sp1 < sp2 /\ which_type[sp1] = which_type[sp2])(
                        (x[sp1] = x[sp2] /\ y[sp1] > y[sp2]) \/ (x[sp1] > x[sp2]));

% Hiden under mist
constraint stage = E -> forall(tmpX in LENGTH)(
                        forall(sp in SHIP)(
                        forall(s in shape[kind[sp]])(
                               x[sp] + rectoff[s,1] > tmpX \/
                               x[sp] + rectoff[s,1] + rectoff[s,3] <= tmpX \/
                               y[sp] + rectoff[s,2] >= mist[tmpX])));

% count arrows
constraint stage = E -> tarrows = sum(sp in SHIP)(
                                  sum(s in shape[kind[sp]])(
                                  sum(tmpY in 0..rectoff[s,4]-1)(
                                      arrow[y[sp]+rectoff[s,2]+tmpY]*rectoff[s,3])));

% k should be one of the config
constraint stage = E -> forall(sp in SHIP)(kind[sp] in config[which_type[sp]]);

%%%%%%%%%%%%%%%%%%%%%%%Stage F%%%%%%%%%%%%%%%%%%%%%%%%%%


array[1..nroff+1, 1..2] of int: rsize0 = array2d(1..nroff+1, 1..2, [if i <= nroff then rectoff[i,j] else 0 endif|i in 1..nroff+1, j in 3..4]);

array[1..nroff+1, 1..2] of int: roff0 = array2d(1..nroff+1, 1..2, [if i <= nroff then rectoff[i,j] else 0 endif|i in 1..nroff+1, j in 1..2]);

array[1..nshapes+1] of set of 1..nroff+1: shape0 = [if i <= nshapes then shape[i] else {nroff+1} endif|i in 1..nshapes+1];

array[SHIP] of var 1..nshapes+1:  kind0;
constraint stage = F -> forall(sp in SHIP)(if k[sp] = 0 then kind0[sp] = nshapes+1
                                            else kind0[sp] = k[sp] endif);

constraint stage = F ->
geost_bb(2,
    rsize0,
    roff0,
    shape0,
    coord,
    kind0,
    [0,0],
    [length, width]
);


% Symetric breaking - ship of the same type should be ordered, not interchangeable
constraint stage = F -> forall(sp1, sp2 in SHIP where sp1 < sp2 /\ which_type[sp1] = which_type[sp2])(
                        if k[sp1] = 0 \/ k[sp2] = 0 then true else
                        (x[sp1] = x[sp2] /\ y[sp1] > y[sp2]) \/ (x[sp1] > x[sp2]) endif);

% Hiden under mist
constraint stage = F -> forall(tmpX in LENGTH)(
                           forall(sp in SHIP)(if k[sp] = 0 then true else
                              forall(s in shape[k[sp]])(
                                     x[sp] + rectoff[s,1] > tmpX \/
                                     x[sp] + rectoff[s,1] + rectoff[s,3] <= tmpX \/
                                     y[sp] + rectoff[s,2] >= mist[tmpX]) endif));

% Within budget
constraint stage = F -> sum(sp in SHIP where k[sp]!=0)(price[which_type[sp]]) <= budget;

% k should be one of the config
constraint stage = F -> forall(sp in SHIP)(k[sp] in config[which_type[sp]] \/ k[sp] = 0);

% count arrows
constraint stage = F -> tarrows = sum(sp in SHIP where k[sp] != 0)(
                                     sum(s in shape[k[sp]])(
                                       sum(tmpY in 0..rectoff[s,4]-1)(
                                          arrow[y[sp]+rectoff[s,2]+tmpY]*rectoff[s,3])));

% set the x,y base of unused ship to zero
constraint stage = F -> forall(sp in SHIP where k[sp] = 0)(x[sp] = 0 /\ y[sp] = 0);

solve maximize tarrows;

output
       ["x = ["] ++ [show_int(2, x[i]) ++ if i != total_ships then ", " else "" endif | i in SHIP] ++ ["];\n"]
       ++ ["y = ["] ++ [show_int(2, y[i]) ++ if i != total_ships then ", " else "" endif | i in SHIP] ++ ["];\n"]
       ++ ["k = ["] ++ 
           if stage = E then 
               [show_int(2, kind[i]) ++ if i != total_ships then ", " else "" endif | i in SHIP] ++ ["];\n"] 
           else 
               [show_int(2, k[i]) ++ if i != total_ships then ", " else "" endif | i in SHIP] ++ ["];\n"]
           endif    
       ++ ["tarrows = " ++ show(tarrows) ++ ";"]
%        ++ [show(shape0[i]) ++ ", " | i in 1..nshapes+1]
       ;