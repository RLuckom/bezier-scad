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

function normalize(vec) = 
  let (z = len(vec) == 3 ? vec[2] : 0, mag = sqrt(vec[0] * vec[0] + vec[1] * vec[1] + z * z)) [vec[0] / mag, vec[1] / mag, z / mag];

function mult(vec, s) = [vec[0] * s, vec[1] * s, (len(vec) == 3 ? vec[2] * s : 0)];

function addVecs(v1, v2) = [v1[0] + v2[0], v1[1] + v2[1], (len(v1) == 3 ? v1[2] : 0) + (len(v2) == 3 ? v2[2] : 0)];

function offsetBezierSurfacePoints(controlPoints, offsetDistance=5, samples=10) = 
  [for (i=[0:samples]) [for (j=[0:samples]) addVecs(bezierSurfacePoint(i * (1 / samples), j * (1 / samples), controlPoints), mult(bezierSurfaceNormal(i * (1 / samples), j * (1 / samples), controlPoints), offsetDistance))]];

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

function squareGridSurfaceFaces(sideSize, faceNumber = 0) =
  let (start = (sideSize + 1) * (sideSize + 1) * faceNumber)
  flattenPoints(flattenPoints([for (col=[0:sideSize - 1]) [for (row=[0:sideSize - 1]) [
    [col * (sideSize + 1) + row + start, (col * (sideSize + 1)) + row + 1 + start, (col + 1) * (sideSize + 1) + row + start],
    [(col + 1) * (sideSize + 1) + row + start, col * (sideSize + 1) + row + 1 + start, (col + 1) * (sideSize + 1) + row + 1 + start],
  ]]]));

function dualSquareGridSurfaceFaces(sideSize) =
  concat(squareGridSurfaceFaces(sideSize), squareGridSurfaceFaces(sideSize, 1));

function squareGridEdgeFaces(sideSize) = 
  let (secondStart = (sideSize + 1) * (sideSize + 1))
  flattenPoints(flattenPoints([
    [for (step=[0:sideSize + 1:secondStart - (sideSize * 2)]) [
      [step, step + sideSize + 1, step + secondStart],
      [step + sideSize + 1, step + sideSize + 1 + secondStart, step + secondStart],
      [step + sideSize + sideSize + 1, step + sideSize, step + sideSize + secondStart],
      [step + sideSize + sideSize + 1, step + sideSize + secondStart, step + sideSize + sideSize + 1 + secondStart]
    ]],
    [for (step=[0:sideSize]) [
      [step, step - 1, step + secondStart],
      [step + secondStart, step -1, step - 1 + secondStart],
      [(secondStart - sideSize) + step - 1,(secondStart - sideSize) + step, secondStart * 2 - sideSize + step],
      [(secondStart - sideSize) + step - 1, secondStart * 2 - sideSize + step, secondStart * 2 - sideSize + step - 1]
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

module bezierSurface(controlPointArrays, thickness=1, samples=10, controlPointSize=1) {
  p = concat(
    flattenPoints(bezierSurfacePoints(controlPointArrays, samples)),
    flattenPoints(offsetBezierSurfacePoints(controlPointArrays, thickness, samples))
  );
  polyhedron(points=p, faces=dualSquareGridFaces(samples));
  showBezierSurfaceControlPoints(controlPointArrays, controlPointSize);
}
