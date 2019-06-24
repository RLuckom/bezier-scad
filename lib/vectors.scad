function flip(cp) = [for (i=[1:len(cp)]) cp[len(cp) - i]];

function pascalHalfLine(lineNumber, pos=0, elements=[]) = 
  ((pos - 1) >= (lineNumber / 2) ? elements :
    (pos == 0 ? pascalHalfLine(lineNumber, pos+1, [1]) :
      pascalHalfLine(lineNumber, pos + 1, concat(elements, [elements[len(elements) -1] * ((lineNumber + 1 - pos) / pos)]))
    )
  );

function pascalLine(lineNumber) =
  let (halfLine = pascalHalfLine(lineNumber))
  concat(halfLine, reverseArray(slice(halfLine, 0, lineNumber / 2)));


function reverseArray(arr, pos=0, reversed=[]) =
  ((len(reversed) == len(arr)) ? reversed :
    reverseArray(arr, pos + 1, concat(reversed, [arr[len(arr) - 1 - pos]]))
  );

function slice(arr, start=0, end=0, sliced=[]) =
  (len(arr) == 0 ? sliced :
    (end == 0 ? slice(arr, start, len(arr), sliced) :
      (start == floor(end) ? sliced :
        slice(arr, start + 1, floor(end), concat(sliced, [arr[start]]))
      )
    )
  );

function normalize(vec) = 
  let (z = len(vec) == 3 ? vec[2] : 0, m = mag(vec)) [vec[0] / m, vec[1] / m, z / m];

function mult(vec, s) = [vec[0] * s, vec[1] * s, (len(vec) == 3 ? vec[2] * s : 0)];

function addPoints(v1, v2) = [v1[0] + v2[0], v1[1] + v2[1], (len(v1) == 3 ? v1[2] : 0) + (len(v2) == 3 ? v2[2] : 0)];

function pull(v1, v2) = addPoints(v1, v2);

function scaleVec(v1, v2) = [v1[0] * v2[0], v1[1] * v2[1], (len(v1) == 3 ? v1[2] : 0) * (len(v2) == 3 ? v2[2] : 0)];

function scaleLine(l, v) = [for (i=[0: len(l) - 1]) scaleVec(l[i], v)];

function pullLine(l, v) = [for (i=[0: len(l) - 1]) pull(l[i], v)];

function mirrorMat(cp, axis) = [for (i=[0:len(cp) - 1]) [for (j=[0:len(cp[i]) - 1]) [for (k=[0:len(cp[i][j]) - 1]) cp[i][j][k] * axis[k]]]];

function addVecArray(vA, n=0, res=[0, 0, 0]) =
  (n == len(vA) ? res : addVecArray(vA, n + 1, addPoints(res, vA[n])));

function divVec(vec, scalar) =
  [vec[0] / scalar, vec[1] / scalar, len(vec) == 3 ? vec[2] / scalar : 0];

function averagePoints(pointArray) = divVec(addVecArray(pointArray), len(pointArray));

function subPoints(v1, v2) = [
  v1[0] - v2[0],
  v1[1] - v2[1],
  (len(v1) == 3 ? v1[2] : 0) -  (len(v2) == 3 ? v2[2] : 0)
];

function vecToAngle(v) = [
  atan2(sqrt((v[1] * v[1]) + (v[2] * v[2])),v[0]),
  atan2(sqrt((v[2] * v[2]) + (v[0] * v[0])),v[1]),
  atan2(sqrt((v[0] * v[0]) + (v[1] * v[1])),v[2])
];

function combination(n, k, i, result=[]) = 
  (len(result) == k ? result :
    combination(n, k, i - (floor(i /  pow(n, k - len(result) - 1)) * pow(n, k - len(result) - 1)), concat(result, [floor(i / pow(n, k - len(result) - 1))])));

function sumArray(array, sum=0) =
  (len(array) == 0 ? sum : sumArray(slice(array, 1), sum + array[0]));

function powerValues(degree, vars) =
  [ for (i = [ 0 : pow(vars + 1, degree + 1) - 1 ]) let (comb = combination(degree + 1, vars, i)) if (sumArray(comb) == degree) comb ];

