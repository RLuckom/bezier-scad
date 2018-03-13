POLY_COEFFICIENTS = [[1],   // n=0
            [1,1],          // n=1
           [1,2,1],         // n=2
          [1,3,3,1],        // n=3
         [1,4,6,4,1],       // n=4
        [1,5,10,10,5,1],    // n=5
       [1,6,15,20,15,6,1]];  // n=6

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
  [
    solveBezierSurfaceDerivative(u, t, POLY_COEFFICIENTS[len(controlPoints) - 1], [for (i=[0: len(controlPoints) - 1]) [for (j=[0:len(controlPoints) - 1]) controlPoints[i][j][0]]], direction),
    solveBezierSurfaceDerivative(u, t, POLY_COEFFICIENTS[len(controlPoints) - 1], [for (i=[0: len(controlPoints) - 1]) [for (j=[0:len(controlPoints) - 1]) controlPoints[i][j][1]]], direction),
    solveBezierSurfaceDerivative(u, t, POLY_COEFFICIENTS[len(controlPoints) - 1], [for (i=[0: len(controlPoints) - 1]) [for (j=[0:len(controlPoints) - 1]) len(controlPoints[i][j]) == 3 ? controlPoints[i][j][2] : 0]], direction)
  ];

function bezierSurfaceNormal(u, t, controlPoints) = 
  normalize(cross(bezierSurfaceTangentVec(u, t, controlPoints, 1), bezierSurfaceTangentVec(t, u, controlPoints, 0)));

function mag(vec) = let (z = len(vec) == 3 ? vec[2] : 0) sqrt(vec[0] * vec[0] + vec[1] * vec[1] + z * z);

function normalize(vec) = 
  let (z = len(vec) == 3 ? vec[2] : 0, m = mag(vec)) [vec[0] / m, vec[1] / m, z / m];

function mult(vec, s) = [vec[0] * s, vec[1] * s, (len(vec) == 3 ? vec[2] * s : 0)];

function addVecs(v1, v2) = [v1[0] + v2[0], v1[1] + v2[1], (len(v1) == 3 ? v1[2] : 0) + (len(v2) == 3 ? v2[2] : 0)];

function offsetBezierSurfacePoint(controlPoints, offsetDistance, i, j) =
  let (norm = bezierSurfaceNormal(i,j,controlPoints), surfacePoint = bezierSurfacePoint(i,j,controlPoints)) addVecs(surfacePoint, mult(norm, offsetDistance));

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

function addVecArray(vA, n=0, res=[0, 0, 0]) =
  (n == len(vA) ? res : addVecArray(vA, n + 1, addVecs(res, vA[n])));

function divVec(vec, scalar) =
  [vec[0] / scalar, vec[1] / scalar, len(vec) == 3 ? vec[2] / scalar : 0];

function interpolatePoint(points, row, col, u, t, utEpsilon, controlPoints, offsetDistance) =
  let (adjacentNorms = filterSafe([
    bezierSurfaceNormal(u + utEpsilon, t, controlPoints),
    bezierSurfaceNormal(u - utEpsilon, t, controlPoints),
    bezierSurfaceNormal(u, t + utEpsilon, controlPoints),
    bezierSurfaceNormal(u, t - utEpsilon, controlPoints)
  ])) (addVecs(
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
  [
    solveBezierSurfacePolynomial(u, v, POLY_COEFFICIENTS[len(controlPoints) - 1], [for (i=[0: len(controlPoints) - 1]) [for (j=[0:len(controlPoints) - 1]) controlPoints[i][j][0]]]),
    solveBezierSurfacePolynomial(u, v, POLY_COEFFICIENTS[len(controlPoints) - 1], [for (i=[0: len(controlPoints) - 1]) [for (j=[0:len(controlPoints) - 1]) controlPoints[i][j][1]]]),
    solveBezierSurfacePolynomial(u, v, POLY_COEFFICIENTS[len(controlPoints) - 1], [for (i=[0: len(controlPoints) - 1]) [for (j=[0:len(controlPoints) - 1]) len(controlPoints[i][j]) == 3 ? controlPoints[i][j][2] : 0]]),
  ];

function bezierSurfacePoints(controlPoints, samples=10) = 
  [for (i=[0:samples]) [for (j=[0:samples]) bezierSurfacePoint(i * (1 / samples), j * (1 / samples), controlPoints)]];


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
  [
    solveBezierPolynomial(t, POLY_COEFFICIENTS[len(controlPoints) - 1], [for (i=[0: len(controlPoints) - 1]) controlPoints[i][0]]),
    solveBezierPolynomial(t, POLY_COEFFICIENTS[len(controlPoints) - 1], [for (i=[0: len(controlPoints) - 1]) controlPoints[i][1]]),
    solveBezierPolynomial(t, POLY_COEFFICIENTS[len(controlPoints) - 1], [for (i=[0: len(controlPoints) - 1]) len(controlPoints[i]) == 3 ? controlPoints[i][2] : 0]),
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
  showBezierControlPoints(controlPoints);
}

module showBezierControlPoints(controlPoints, controlPointSize=1) {
  if (controlPointSize != 0) {
    for (cp = controlPoints) {
      %color("red", 1.0) translate([cp[0], cp[1], len(cp) == 3 ? cp[2] : 0]) sphere(controlPointSize, center=true);
    }
  }
}

function sub(v1, v2) = [
  v1[0] - v2[0],
  v1[1] - v2[1],
  (len(v1) == 3 ? v1[2] : 0) -  (len(v2) == 3 ? v2[2] : 0)
];

function hasArea(points) = 
  mag(cross(sub(points[0], points[1]), sub(points[1], points[2]))) > 0;

function deleteZeroAreaFaces(points, faces, n=0, newFaces=[]) =
  (n == len(faces) ? newFaces : 
    (hasArea([points[faces[n][0]], points[faces[n][1]], points[faces[n][2]]]) ? 
      deleteZeroAreaFaces(points, faces, n + 1, concat(newFaces, [faces[n]])) :
      deleteZeroAreaFaces(points, faces, n + 1, newFaces))
  );

module showBezierSurfaceControlPoints(controlPointArrays, controlPointSize=1) {
  if (controlPointSize != 0) {
    for (controlPoints = controlPointArrays) {
      showBezierControlPoints(controlPoints, controlPointSize);
    }
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
