set of int: model = 1..7;
array[model] of int: height;
height = [2,3,5,12,6,8,-1];
constraint assert(forall(i in model)(height[i] >= 0),"Error!Wrong!Wrong!Wrong!");
test trace("height[\(2)] < height [\(3)]");