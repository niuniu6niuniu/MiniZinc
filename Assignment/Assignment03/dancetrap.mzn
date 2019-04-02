% Beauty Trap
% Perform the most seductive dance

enum LEGS = {spin, leap, waltz, curtsey, prep, stand};
enum ARMS = {beckon, out, up, wrapped, neutral};
enum FACE = {smile, wink, batt, think, glow, blank};

int: maxlen;
set of int: STEP = 1..maxlen;
array[LEGS] of int: maxlegs;
array[ARMS] of int: maxarms;
array[FACE] of int: maxface;
constraint assert(maxlegs[stand] >= maxlen, "maxlegs[stand] smaller than maxlen");
constraint assert(maxarms[neutral] >= maxlen, "maxarms[neutral] smaller than maxlen");
constraint assert(maxface[blank] >= maxlen, "maxface[blank] smaller than maxlen");
array[LEGS,ARMS] of int: dance_value;
array[ARMS,FACE] of int: entice_value;
constraint assert(dance_value[stand,neutral] = 0, "incorrect dance_value array");
constraint assert(entice_value[neutral,blank] = 0, "incorrect entice_value array");
int: boredom; % how bored each step make the viewer

var STEP: len;
array[STEP] of var LEGS: legs;
array[STEP] of var ARMS: arms;
array[STEP] of var FACE: face;

include "globals.mzn";
constraint global_cardinality_low_up(legs, LEGS, [0| i in LEGS], maxlegs);
constraint global_cardinality_low_up(arms, ARMS, [0| i in LEGS], maxarms);
constraint global_cardinality_low_up(face, FACE, [0| i in LEGS], maxface);

include "regular.mzn";
% constraint on legs
constraint regular([legs[i]|i in STEP], 7, 6, d1, 1, {7});
array[1..7,LEGS] of 0..7: d1 =
     [| 2, 0, 4, 5, 6, 7
      | 0, 0, 0, 5, 6, 7
      | 2, 0, 4, 0, 0, 7
      | 2, 0, 4, 0, 6, 7
      | 2, 0, 4, 5, 0, 7
      | 2, 3, 4, 5, 6, 7
      | 2, 0, 4, 5, 6, 7 |];
constraint forall(i in 1..len-3) (legs[i]=waltz /\ legs[i+1]=waltz /\ legs[i+2] = waltz
                                  -> legs[i+3]!=waltz);
constraint forall(i in 1..len-1)((legs[i] = waltz -> forall(j in i+1..len)(legs[j] = curtsey 
                               -> exists(k in i+1..j-1)(legs[k] = stand))));                                    
% constraint on arms     
constraint regular([arms[i]|i in STEP], 6, 5, d2, 1, {6});
array[1..6,ARMS] of 0..6: d2 =
     [| 0, 3, 4, 0, 6
      | 0, 3, 4, 5, 6
      | 2, 0, 4, 0, 6
      | 2, 3, 0, 0, 6
      | 0, 3, 4, 0, 6
      | 0, 3, 4, 5, 6 |];
% constraint on face
constraint regular([face[i]|i in STEP], 7, 6, d3, 1, {7});
array[1..7,FACE] of 0..7: d3 = 
     [| 2, 3, 4, 5, 6, 7
      | 2, 3, 4, 0, 6, 7
      | 2, 3, 4, 5, 6, 7
      | 2, 3, 4, 0, 6, 7
      | 2, 3, 4, 5, 6, 7
      | 2, 3, 4, 5, 6, 7
      | 2, 3, 4, 5, 6, 7 |]; 
constraint forall(i in 1..len-2) (face[i] = face[i+1] /\ face[i+1] = face[i+2] 
                                  -> face[i] = blank);
% Final state
constraint forall(i in STEP)(i > len -> legs[i] = stand /\ arms[i] = neutral /\ face[i] = blank );                                  
% obj
var int: value = sum(i in 1..len) (dance_value[legs[i], arms[i]]);
var int: enticement = sum(i in 1..len) (entice_value[arms[i], face[i]]);
constraint forall(i in STEP)(dance_value[legs[i],arms[i]] >= 0);
constraint forall(i in STEP)(entice_value[arms[i],face[i]] >= 0);
var int: obj = value + enticement - boredom*len;
solve maximize obj;                                  
output["len=\(len);\n"]
    ++[ "legs = \(legs);\n", "arms = \(arms);\n", "face = \(face);\n"]
    ++["obj=\(obj);\n"]   
                                                      