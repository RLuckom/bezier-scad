include <./vectors.scad>;

function bezierSquare(bottomLeft=[0, 0, 0], topLeft=[0, 3, 0], bottomRight=[3, 0, 0], topRight=[3, 3, 0]) = 
  let (
    leftBottomMid = averagePoints([bottomLeft, bottomLeft, topLeft]),
    leftTopMid = averagePoints([bottomLeft, topLeft, topLeft]),
    rightBottomMid = averagePoints([bottomRight, bottomRight, topRight]),
    rightTopMid = averagePoints([bottomRight, topRight, topRight])
    )
  [
    lineBetween(bottomLeft, bottomRight),
    lineBetween(leftBottomMid, rightBottomMid),
    lineBetween(leftTopMid, rightTopMid),
    lineBetween(topLeft, topRight),
  ];

function join(line1, line2) =
   [ for (i=[0:len(line1) - 1]) [for (j=[0:len(line1) - 1]) [for (k=[0:len(line1[j]) - 1]) ((line1[j][k] * i) + (line2[j][k] * ((len(line1) - 1) - i))) / (len(line1) - 1)]]];

function lineBetween(point1, point2) = 
    [
      point1,
      averagePoints([point1, point1, point2]),
      averagePoints([point2, point2, point1]),
      point2
    ];

function replacePoint(bezierSquare, rowToReplace, colToReplace, newPoint) =
  [for (row = [0:len(bezierSquare) - 1])
    [for (col = [0:len(bezierSquare[row]) - 1])
      ((row == rowToReplace && col == colToReplace) ? newPoint :
        bezierSquare[row][col]
      )
    ]
  ];

function replacePoints(bezierSquare, replacements) = 
  (len(replacements) == 0 ? bezierSquare :
    replacePoints(
      replacePoint(
        bezierSquare,
        replacements[0][0], 
        replacements[0][1], 
        replacements[0][2] 
      ),
      slice(replacements, 1)
    )
  );

function tieLeft(source, target) =
  replacePoints(target, [
    [0, 3, source[0][0]],
    [1, 3, source[1][0]],
    [2, 3, source[2][0]],
    [3, 3, source[3][0]],
  ]);

function tieHardLeft(source, target) =
  replacePoints(tieLeft(source, target), [
    [0, 2, tie(source[0][0], source[0][1])],
    [1, 2, tie(source[1][0], source[1][1])],
    [2, 2, tie(source[2][0], source[2][1])],
    [3, 2, tie(source[3][0], source[3][1])]
  ]);

function tieRight(source, target) =
  replacePoints(target, [
    [0, 0, source[0][3]],
    [1, 0, source[1][3]],
    [2, 0, source[2][3]],
    [3, 0, source[3][3]],
  ]);

function tieHardRight(source, target) =
  replacePoints(tieRight(source, target), [
    [0, 1, tie(source[0][3], source[0][2])],
    [1, 1, tie(source[1][3], source[1][2])],
    [2, 1, tie(source[2][3], source[2][2])],
    [3, 1, tie(source[3][3], source[3][2])]
  ]);

function tieTop(source, target) =
  replacePoints(target, [
    [0, 0, source[3][0]],
    [0, 1, source[3][1]],
    [0, 2, source[3][2]],
    [0, 3, source[3][3]],
  ]);

function tieHardTop(source, target) =
  replacePoints(tieTop(source, target), [
    [1, 0, tie(source[3][0], source[2][0])],
    [1, 1, tie(source[3][1], source[2][1])],
    [1, 2, tie(source[3][2], source[2][2])],
    [1, 3, tie(source[3][3], source[2][3])]
  ]);

function tieBottom(source, target) =
  replacePoints(target, [
    [3, 0, source[0][0]],
    [3, 1, source[0][1]],
    [3, 2, source[0][2]],
    [3, 3, source[0][3]],
  ]);

function tieHardBottom(source, target) =
  replacePoints(tieBottom(source, target), [
    [2, 0, tie(source[0][0], source[1][0])],
    [2, 1, tie(source[0][1], source[1][1])],
    [2, 2, tie(source[0][2], source[1][2])],
    [2, 3, tie(source[0][3], source[1][3])]
  ]);

function solveDerivativeValue(t, tpow, oneMinusTPow, coefficient, weight) =
  weight * tpow * coefficient * pow(1 - t, oneMinusTPow) * pow(t, tpow == 0 ? 0 : tpow - 1) - weight * coefficient * oneMinusTPow * pow(1 - t, oneMinusTPow == 0 ? 0 : oneMinusTPow - 1) * pow(t, tpow);


function solveBezierSurfaceDerivative(u, t, coefficientArray, weightArray, direction, position=0, result=0) = 
  (position >= len(coefficientArray) ? result :
    solveBezierSurfaceDerivative(u, t, coefficientArray, weightArray, direction, position + 1,
      solveDerivativeValue(t, position, len(coefficientArray) - 1 - position, coefficientArray[position], 1)
      * solveBezierPolynomial(u, coefficientArray, [for (n=[0:len(coefficientArray)]) weightArray[direction == 1 ? n : position][direction == 1 ? position : n]])
      + result 
    )
  );

function bezierSurfaceTangentVec(u, t, controlPoints, direction) = 
  let(coefficients = pascalLine(len(controlPoints) - 1))
  [
    solveBezierSurfaceDerivative(u, t, coefficients, [for (i=[0: len(controlPoints) - 1]) [for (j=[0:len(controlPoints) - 1]) controlPoints[i][j][0]]], direction),
    solveBezierSurfaceDerivative(u, t, coefficients, [for (i=[0: len(controlPoints) - 1]) [for (j=[0:len(controlPoints) - 1]) controlPoints[i][j][1]]], direction),
    solveBezierSurfaceDerivative(u, t, coefficients, [for (i=[0: len(controlPoints) - 1]) [for (j=[0:len(controlPoints) - 1]) len(controlPoints[i][j]) == 3 ? controlPoints[i][j][2] : 0]], direction)
  ];

function bezierSurfaceNormal(u, t, controlPoints) = 
  normalize(cross(bezierSurfaceTangentVec(u, t, controlPoints, 1), bezierSurfaceTangentVec(t, u, controlPoints, 0)));

function mag(vec) = let (z = len(vec) == 3 ? vec[2] : 0) sqrt(vec[0] * vec[0] + vec[1] * vec[1] + z * z);

function offsetBezierSurfacePoint(controlPoints, offsetDistance, i, j) =
  let (norm = bezierSurfaceNormal(i,j,controlPoints), surfacePoint = bezierSurfacePoint(i,j,controlPoints)) addPoints(surfacePoint, mult(norm, offsetDistance));

function offsetBezierSurfacePoints(controlPoints, offsetDistance=5, samples=10) = 
  interpolateMissingOffsetValues(
    [for (i=[0:samples]) [for (j=[0:samples]) offsetBezierSurfacePoint(controlPoints, offsetDistance, i * (1 / samples), j * (1 / samples))]],
    controlPoints, offsetDistance
  );

function interpolateMissingOffsetValues(offsetPoints, controlPoints, offsetDistance) =
  let (
    side = len(offsetPoints)
  ) [for (row=[0:side - 1]) [for (col=[0:side - 1]) (
    (isUnsafe(offsetPoints[row][col]) ? 
    interpolatePoint(
      offsetPoints, 
      row,
      col, 
      row * (1 / side),
      col * (1 / side),
      1 / side,
      controlPoints,
      offsetDistance) :
    offsetPoints[row][col]
  )
  )]];

function filterSafe(points) = [for (p=points) if (!isUnsafe(p)) p];

function interpolatePoint(points, row, col, u, t, utEpsilon, controlPoints, offsetDistance) =
  let (adjacentNorms = filterSafe([
    bezierSurfaceNormal(u + utEpsilon, t, controlPoints),
    bezierSurfaceNormal(u - utEpsilon, t, controlPoints),
    bezierSurfaceNormal(u, t + utEpsilon, controlPoints),
    bezierSurfaceNormal(u, t - utEpsilon, controlPoints)
  ])) (addPoints(
      bezierSurfacePoint(u, t, controlPoints), 
      mult(
        divVec(
          addVecArray(adjacentNorms),
          len(adjacentNorms)
        ),
        offsetDistance
      )
     ));


function solveBezierSurfacePolynomialStep(u, v, coefficientArray, weightArray, nposition, mposition=0, result=0) = 
  (mposition >= len(coefficientArray) ? result :
    solveBezierSurfacePolynomialStep(u, v, coefficientArray, weightArray, nposition, mposition + 1,
      result + (coefficientArray[nposition] * pow((1 - u), len(coefficientArray) - 1 - nposition) * pow(u, nposition) * coefficientArray[mposition] * pow((1 - v), len(coefficientArray) - 1 - mposition) * pow(v, mposition) * weightArray[nposition][mposition])
    )
  );

function solveBezierSurfacePolynomial(u, v, coefficientArray, weightArray, nposition=0, result=0) =
  (nposition >= len(coefficientArray) ? result :
    solveBezierSurfacePolynomial(u, v, coefficientArray, weightArray, nposition + 1,
      result + solveBezierSurfacePolynomialStep(u, v, coefficientArray, weightArray, nposition)
    )
  );

function bezierSurfacePoint(u, v, controlPoints) =
  let(coefficients = pascalLine(len(controlPoints) - 1))
  [
    solveBezierSurfacePolynomial(u, v, coefficients, [for (i=[0: len(controlPoints) - 1]) [for (j=[0:len(controlPoints) - 1]) controlPoints[i][j][0]]]),
    solveBezierSurfacePolynomial(u, v, coefficients, [for (i=[0: len(controlPoints) - 1]) [for (j=[0:len(controlPoints) - 1]) controlPoints[i][j][1]]]),
    solveBezierSurfacePolynomial(u, v, coefficients, [for (i=[0: len(controlPoints) - 1]) [for (j=[0:len(controlPoints) - 1]) len(controlPoints[i][j]) == 3 ? controlPoints[i][j][2] : 0]]),
  ];

function bezierSurfacePoints(controlPoints, samples=10) = 
  [for (i=[0:samples]) [for (j=[0:samples]) bezierSurfacePoint(i * (1 / samples), j * (1 / samples), controlPoints)]];

function bezierSurfacePointsAndNormals(controlPoints, samples=10) = 
  [for (i=[0:samples]) [for (j=[0:samples]) [bezierSurfacePoint(i * (1 / samples), j * (1 / samples), controlPoints), bezierSurfaceNormal(i * (1 / samples),j * (1 / samples),controlPoints)]]];

function bezierSurfacePointsAndFlatRotations(controlPoints, samples=10) = 
  [for (i=[0:samples]) [for (j=[0:samples]) [bezierSurfacePoint(i * (1 / samples), j * (1 / samples), controlPoints), [0, 0, vecToAngle(bezierSurfacePoint(i * (1 / samples),j * (1 / samples),controlPoints))[1]]]]];

function solveBezierPolynomial(t, coefficientArray, weightArray, position=0, result=0) =
  (position >= len(coefficientArray) ? result :
    solveBezierPolynomial(t, coefficientArray, weightArray, position +1,
      result + coefficientArray[position] * pow((1 - t), len(coefficientArray) - 1 - position) * pow(t, position) * weightArray[position]
    )
  );

/*
function allSame(points, n=0) = 
  (n == len(points) - 1 ? true : 
    ((points[n][0] == points[n+1][0] && points[n][1] == points[n+1][1] && (len(points[n]) == 3 ? points[n][2] : 0) == len(points[n+1]) == 3 ? points[n+1][2] : 0) ? allSame(points, n + 1) : false
    )
  );
*/

function bezierPoint(t, controlPoints) =
  let(coefficients = pascalLine(len(controlPoints) - 1))
  [
    solveBezierPolynomial(t, coefficients, [for (i=[0: len(controlPoints) - 1]) controlPoints[i][0]]),
    solveBezierPolynomial(t, coefficients, [for (i=[0: len(controlPoints) - 1]) controlPoints[i][1]]),
    solveBezierPolynomial(t, coefficients, [for (i=[0: len(controlPoints) - 1]) len(controlPoints[i]) == 3 ? controlPoints[i][2] : 0]),
  ];

function bezierPoints(controlPoints, samples=10) =
  [for (i=[0:samples]) bezierPoint(i * (1 / samples), controlPoints)];

function flattenPoints(points, n=0, result=[]) = 
  (n >= len(points) ? result :
    flattenPoints(points, n + 1, concat(result, points[n])));

function squareGridSurfaceFaces(sideSize, faceNumber=0, forward=true) =
  let (start = (sideSize + 1) * (sideSize + 1) * faceNumber)
  flattenPoints(flattenPoints([for (col=[0:sideSize - 1]) [for (row=[0:sideSize - 1])
    (forward ?  [
    [
      col * (sideSize + 1) + row + start,
      (col * (sideSize + 1)) + row + 1 + start,
      (col + 1) * (sideSize + 1) + row + start
    ],
    [
      (col + 1) * (sideSize + 1) + row + start,
      col * (sideSize + 1) + row + 1 + start,
      (col + 1) * (sideSize + 1) + row + 1 + start
    ]] :
    [[
      (col * (sideSize + 1)) + row + 1 + start,
      col * (sideSize + 1) + row + start,
      (col + 1) * (sideSize + 1) + row + start
    ],
    [
      col * (sideSize + 1) + row + 1 + start,
      (col + 1) * (sideSize + 1) + row + start,
      (col + 1) * (sideSize + 1) + row + 1 + start
    ]
    ])
  ]]));

function dualSquareGridSurfaceFaces(sideSize) =
  concat(
    squareGridSurfaceFaces(sideSize)
    , squareGridSurfaceFaces(sideSize, 1, false)
);

function squareGridEdgeFaces(sideSize) = 
  let (secondStart = (sideSize + 1) * (sideSize + 1))
  flattenPoints(flattenPoints([
    [for (step=[0:sideSize + 1:secondStart - (sideSize * 2)]) [
      [step, step + sideSize + 1, step + secondStart],
      [step + sideSize + 1, step + sideSize + 1 + secondStart, step + secondStart],
      [step + sideSize + sideSize + 1, step + sideSize, step + sideSize + secondStart],
      [step + sideSize + sideSize + 1, step + sideSize + secondStart, step + sideSize + sideSize + 1 + secondStart]
    ]],
    [for (step=[1:sideSize]) [
      [step, step - 1, step + secondStart],
      [step + secondStart, step -1, step - 1 + secondStart],
      [(secondStart - sideSize - 1) + step - 1,(secondStart - sideSize - 1) + step, secondStart * 2 - sideSize - 1 + step],
      [(secondStart - sideSize - 1) + step - 1, secondStart * 2 - sideSize - 1 + step, secondStart * 2 - sideSize - 1 + step - 1]
    ]]
  ]));

function dualSquareGridFaces(sideSize) = concat(squareGridEdgeFaces(sideSize), dualSquareGridSurfaceFaces(sideSize));

module bezier(controlPoints, samples=10, controlPointSize=1) {
  points = bezierPoints(controlPoints, samples);
  for (point=[1:len(points) - 1]) {
    hull() {
      translate(points[point - 1]) children(0);
      translate(points[point]) children(0);
    }
  }
  showBezierControlPoints(controlPoints, controlPointSize);
}

module showBezierControlPoints(controlPoints, controlPointSize=1) {
  if (controlPointSize != 0) {
    for (cp = controlPoints) {
      %color("red", 1.0) translate([cp[0], cp[1], len(cp) == 3 ? cp[2] : 0]) sphere(controlPointSize, center=true);
    }
  }
}

function tie(edgePoint, innerPoint) = addPoints(edgePoint, subPoints(edgePoint, innerPoint));

function hasArea(points) = 
  mag(cross(subPoints(points[0], points[1]), subPoints(points[1], points[2]))) > 0;

function deleteZeroAreaFaces(points, faces, n=0, newFaces=[]) =
  (n == len(faces) ? newFaces : 
    (hasArea([points[faces[n][0]], points[faces[n][1]], points[faces[n][2]]]) ? 
      deleteZeroAreaFaces(points, faces, n + 1, concat(newFaces, [faces[n]])) :
      deleteZeroAreaFaces(points, faces, n + 1, newFaces))
  );

module showBezierSurfaceControlPoints(controlPointArrays, controlPointSize=1) {
  if (controlPointSize != 0 && len(controlPointArrays[0]) != 4) {
    for (controlPoints = controlPointArrays) {
      showBezierControlPoints(controlPoints, controlPointSize);
    }
  } else {
    %color("red", 1.0) translate([controlPointArrays[3][0][0], controlPointArrays[3][0][1], len(controlPointArrays[3][0]) == 3 ? controlPointArrays[3][0][2] : 0]) sphere(controlPointSize, center=true);
    %color("blue", 1.0) translate([controlPointArrays[3][1][0], controlPointArrays[3][1][1], len(controlPointArrays[3][1]) == 3 ? controlPointArrays[3][1][2] : 0]) sphere(controlPointSize, center=true);
    %color("blue", 1.0) translate([controlPointArrays[3][2][0], controlPointArrays[3][2][1], len(controlPointArrays[3][2]) == 3 ? controlPointArrays[3][2][2] : 0]) sphere(controlPointSize, center=true);
    %color("red", 1.0) translate([controlPointArrays[3][3][0], controlPointArrays[3][3][1], len(controlPointArrays[3][3]) == 3 ? controlPointArrays[3][3][2] : 0]) sphere(controlPointSize, center=true);
    %color("SpringGreen", 1.0) translate([controlPointArrays[2][3][0], controlPointArrays[2][3][1], len(controlPointArrays[2][3]) == 3 ? controlPointArrays[2][3][2] : 0]) sphere(controlPointSize, center=true);
    %color("red", 1.0) translate([controlPointArrays[2][1][0], controlPointArrays[2][1][1], len(controlPointArrays[2][1]) == 3 ? controlPointArrays[2][1][2] : 0]) sphere(controlPointSize, center=true);
    %color("red", 1.0) translate([controlPointArrays[2][2][0], controlPointArrays[2][2][1], len(controlPointArrays[2][2]) == 3 ? controlPointArrays[2][2][2] : 0]) sphere(controlPointSize, center=true);
    %color("silver", 1.0) translate([controlPointArrays[2][0][0], controlPointArrays[2][0][1], len(controlPointArrays[2][0]) == 3 ? controlPointArrays[2][0][2] : 0]) sphere(controlPointSize, center=true);
    %color("red", 1.0) translate([controlPointArrays[1][2][0], controlPointArrays[1][2][1], len(controlPointArrays[1][2]) == 3 ? controlPointArrays[1][2][2] : 0]) sphere(controlPointSize, center=true);
    %color("red", 1.0) translate([controlPointArrays[1][1][0], controlPointArrays[1][1][1], len(controlPointArrays[1][1]) == 3 ? controlPointArrays[1][1][2] : 0]) sphere(controlPointSize, center=true);
    %color("silver", 1.0) translate([controlPointArrays[1][0][0], controlPointArrays[1][0][1], len(controlPointArrays[1][0]) == 3 ? controlPointArrays[1][0][2] : 0]) sphere(controlPointSize, center=true);
    %color("springgreen", 1.0) translate([controlPointArrays[1][3][0], controlPointArrays[1][3][1], len(controlPointArrays[1][3]) == 3 ? controlPointArrays[1][3][2] : 0]) sphere(controlPointSize, center=true);
    %color("red", 1.0) translate([controlPointArrays[0][0][0], controlPointArrays[0][0][1], len(controlPointArrays[0][0]) == 3 ? controlPointArrays[0][0][2] : 0]) sphere(controlPointSize, center=true);
    %color("Magenta", 1.0) translate([controlPointArrays[0][1][0], controlPointArrays[0][1][1], len(controlPointArrays[0][1]) == 3 ? controlPointArrays[0][1][2] : 0]) sphere(controlPointSize, center=true);
    %color("Magenta", 1.0) translate([controlPointArrays[0][2][0], controlPointArrays[0][2][1], len(controlPointArrays[0][2]) == 3 ? controlPointArrays[0][2][2] : 0]) sphere(controlPointSize, center=true);
    %color("red", 1.0) translate([controlPointArrays[0][3][0], controlPointArrays[0][3][1], len(controlPointArrays[0][3]) == 3 ? controlPointArrays[0][3][2] : 0]) sphere(controlPointSize, center=true);
  }   
}

module bezierEnvelope(cp1, cp2, samples=10, controlPointSize=1) {
  points = concat(
    flattenPoints(bezierSurfacePoints(cp1, samples)),
    flattenPoints(bezierSurfacePoints(cp2, samples))
  );
  faces = dualSquareGridSurfaceFaces(samples);
  polyhedron(points=points, faces=faces);
  showBezierSurfaceControlPoints(cp1, controlPointSize);
  showBezierSurfaceControlPoints(cp2, controlPointSize);
}

function findUnsafePoints(points, n=0, unsafePoints=[]) =
  (n == len(points) ? unsafePoints : 
      isUnsafe(points[n]) ? findUnsafePoints(points, n + 1, concat(unsafePoints, [n])) :
      findUnsafePoints(points, n + 1, unsafePoints)
  );

function isUnsafe(point) =
  (!point) || (
    point[0] * 1 != point[0] ||
    point[1] * 1 != point[1] || 
    point[2] * 1 != point[2]
  );

function zeroOutUnsafePoints(points, unsafePoints) =
  [for (n=[0:len(points) - 1]) (len(search(n, unsafePoints)) == 0 ? points[n] : [0,0,0])];

function containsUnsafePoints(face, unsafePoints) = (
  search(face[0], unsafePoints) ||
  search(face[1], unsafePoints) ||
  search(face[2], unsafePoints)
);

function filterOutUnsafeFaces(faces, unsafePoints) = 
  [for (face=faces) if (!containsUnsafePoints(face, unsafePoints)) face];

module bezierSurface(controlPointArrays, thickness=1, samples=10, controlPointSize=1, checkFaces=false) {
  p = concat(
    flattenPoints(bezierSurfacePoints(controlPointArrays, samples)),
    flattenPoints(offsetBezierSurfacePoints(controlPointArrays, thickness, samples))
  );
  naiveFaces = dualSquareGridFaces(samples);
  if (checkFaces) {
    unsafePoints = findUnsafePoints(p);
    facesWithoutUnsafePoints = filterOutUnsafeFaces(naiveFaces, unsafePoints);
    polyhedron(points=zeroOutUnsafePoints(p, unsafePoints), faces=deleteZeroAreaFaces(p, filterOutUnsafeFaces(facesWithoutUnsafePoints, unsafePoints)));
  } else {
    polyhedron(points=p, faces=naiveFaces);
  }
  showBezierSurfaceControlPoints(controlPointArrays, controlPointSize);
}

module bezierSurfaceFromTwoFaces(controlPointArrays1, controlPointArrays2, samples=10, controlPointSize=1, checkFaces=false) {
  p = concat(
    flattenPoints(bezierSurfacePoints(controlPointArrays1, samples)),
    flattenPoints(bezierSurfacePoints(controlPointArrays2, samples))
  );
  naiveFaces = dualSquareGridFaces(samples);
  if (checkFaces) {
    unsafePoints = findUnsafePoints(p);
    facesWithoutUnsafePoints = filterOutUnsafeFaces(naiveFaces, unsafePoints);
    polyhedron(points=zeroOutUnsafePoints(p, unsafePoints), faces=deleteZeroAreaFaces(p, filterOutUnsafeFaces(facesWithoutUnsafePoints, unsafePoints)));
  } else {
    polyhedron(points=p, faces=naiveFaces);
  }
  showBezierSurfaceControlPoints(controlPointArrays1, controlPointSize);
  showBezierSurfaceControlPoints(controlPointArrays2, controlPointSize);
}

module bezierSolid(faceControlPointsArray, samples=10, controlPointSize=1) {
  faces = flattenPoints([for (i=[0:len(faceControlPointsArray) - 1]) squareGridSurfaceFaces(samples, i)]);
  points = flattenPoints([for (i=faceControlPointsArray) flattenPoints(bezierSurfacePoints(i, samples))]);
  polyhedron(points=points, faces=[for (f=faces) reverseArray(f, 0)]);
  for (i=faceControlPointsArray) {
    showBezierSurfaceControlPoints(i, controlPointSize);
  }
}

function replacePointsCoords(bezierSquare, replacements) = 
  (len(replacements) == 0 ? bezierSquare :
    replacePointsCoords(
      replacePoint(
        bezierSquare,
        replacements[0][0][0],
        replacements[0][0][1], 
        replacements[0][1]
      ),
      slice(replacements, 1)
    )
  );

A = [0, 0];
B = [0, 1];
C = [0, 2];
D = [0, 3];
E = [1, 0];
F = [1, 1];
G = [1, 2];
H = [1, 3];
I = [2, 0];
J = [2, 1];
K = [2, 2];
L = [2, 3];
M = [3, 0];
N = [3, 1];
O = [3, 2];
P = [3, 3];

function reverseHandedness(m) =
  [
    [m[0][3], m[0][2], m[0][1], m[0][0]],
    [m[1][3], m[1][2], m[1][1], m[1][0]],
    [m[2][3], m[2][2], m[2][1], m[2][0]],
    [m[3][3], m[3][2], m[3][1], m[3][0]],
  ];
