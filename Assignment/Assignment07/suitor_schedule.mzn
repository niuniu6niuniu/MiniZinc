% scheduling suitors
enum SUITOR;
SUITOR: LiuBei; % which suitor is LiuBei
int: n; % number of meetings
set of int: MEETING = 1..n;
array[MEETING] of SUITOR: suitor;

enum ROOM = { Red, Gold, Blue };
array[SUITOR,ROOM] of int: mintime;
array[SUITOR,ROOM] of int: maxtime;
constraint forall(s in SUITOR, r in ROOM)
                 (assert(mintime[s,r] >= 1 /\ maxtime[s,r] >= mintime[s,r], 
                  "error in mintime/maxtime at [\(s),\(r)]\n"));

array[ROOM,ROOM] of int: move;
constraint forall(r in ROOM)(assert(move[r,r] = 0,"move[\(r),\(r)] != 0\n")); 

int: ndays; % number of days
set of int: DAY = 1..ndays;
int: earliest; % time for earliest meeting start
int: latest;  % time for end of latest meeting

int: lessontime; % time for kung fu lesson;
int: minsep;     % minimum time between consecutive kung fu lessons

array[ROOM] of int: usedstart;  % time others use each room each day
array[ROOM] of int: useddur;    % durations of others use

enum STAGE = {A,B,C};
STAGE: stage;

set of int: TIME = 0..24*ndays;

array[MEETING] of var TIME: start;
array[MEETING] of var TIME: dur;    % duration in false schedule
array[MEETING] of var ROOM: room;
set of int: KUNGFU = 1..n;
array[KUNGFU] of var int: kungfu;  % start time for each lesson
   % unused lessons have start times after 24*ndays

% start time greater than earliest time, end time smaller than latest time
constraint forall(m in MEETING)((start[m] mod 24) >= earliest
                              /\(start[m] mod 24 + dur[m]) <= latest);

% meeting time greater than mintime, smaller than maxtime
constraint forall(m in MEETING)(dur[m] - follow[m] * lessontime >= mintime[suitor[m],room[m]]);
constraint forall(m in MEETING)(dur[m] <= maxtime[suitor[m],room[m]]);

% meeting start after the room used time end, or end before the room used start time
constraint forall(m in MEETING)(start[m] mod 24 >= usedstart[room[m]] + useddur[room[m]] 
                             \/ start[m] mod 24 + dur[m] <= usedstart[room[m]]);
                             
% Any two meetings does not overlap
constraint forall(m1,m2 in MEETING where m1 < m2)
                 (start[m1] + dur[m1] + move[room[m1],room[m2]] <= start[m2]
                \/start[m2] + dur[m2] + move[room[m2],room[m1]] <= start[m1]);   

% if the same meeting in consecutive order
constraint forall(s in SUITOR, m1, m2 in MEETING where suitor[m1] = s 
                 /\ suitor[m2] = s /\ m1 < m2)(start[m1] < start[m2]);                                  
               
% kungfu time non-decreasing
constraint forall(k in 1..n-1)(kungfu[k] + lessontime + minsep <= kungfu[k+1]); 

% kungfu start time
constraint forall(k in KUNGFU) (kungfu[k] > 0 /\ kungfu[k] <= 24*ndays + n*(minsep+lessontime));  

% if there is kungfu lesson follows
array[KUNGFU] of var 0..n: katm;
array[MEETING] of var 0..1: follow;
constraint forall(m in MEETING)(
    stage != C -> follow[m] = 0);
constraint forall(k in KUNGFU)(
    stage != C -> katm[k] = 0);

% Kungfu align with the end of a meeting
constraint forall(k in KUNGFU  where (kungfu[k] <= 24*ndays) ) (
    if stage != C then true else
    exists(m in MEETING)(kungfu[k] + lessontime = start[m] + dur[m] /\ katm[k] = m)
    endif);

constraint forall(m in MEETING)(
    if stage != C then true else
    if exists(k in KUNGFU)(katm[k] = m) then follow[m] = 1 else follow[m] = 0 endif
    endif);  

% For stage A and stage B, ignore kungfu
constraint forall(k in KUNGFU)(stage != C -> kungfu[k] > 24 * ndays);                                                                                                                 

% For stage A and stage B, just consider the time with LiuBei
var int: objAB = sum(m in MEETING where suitor[m] = LiuBei)(dur[m]);

% For stage C, consider kungfu first, time with LiuBei second
var int: obj1 = sum(m in MEETING where suitor[m] = LiuBei)(dur[m] - follow[m]*lessontime);
var int: obj2 = sum(k in KUNGFU)(if kungfu[k] <= 24 * ndays then 1 else 0 endif);
var int: objC = 100 * obj2 + obj1;

var int: obj;
constraint if stage != C then obj = objAB else obj = objC endif;
solve maximize obj;

output["start = \(start);\ndur = \(dur);\nroom = \(room);\nkungfu = \(kungfu);\nobj = \(obj);"]
