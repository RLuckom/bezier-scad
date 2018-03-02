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
  [for (i=[0:samples - 1]) [for (j=[0:samples - 1]) addVecs(bezierSurfacePoint(i * (1 / samples), j * (1 / samples), controlPoints), mult(bezierSurfaceNormal(i * (1 / samples), j * (1 / samples), controlPoints), offsetDistance))]];

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
  [for (i=[0:samples - 1]) [for (j=[0:samples - 1]) bezierSurfacePoint(i * (1 / samples), j * (1 / samples), controlPoints)]];


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

function squareGridSurfaceFaces(sideSize) =
  let (secondStart = sideSize * sideSize)
  flattenPoints(flattenPoints([for (col=[0:sideSize - 2]) [for (row=[0:sideSize - 2]) [
    [(col * sideSize) + row, (col * sideSize) + row + 1, (col + 1) * sideSize + row],
    [(col + 1) * sideSize + row, col * sideSize + row + 1, (col + 1) * sideSize + row + 1],
    [(col * sideSize) + row + 1 + secondStart, (col * sideSize) + row + secondStart, (col + 1) * sideSize + row + secondStart],
    [col * sideSize + row + 1 + secondStart, (col + 1) * sideSize + row + secondStart, (col + 1) * sideSize + row + 1 + secondStart]
  ]]]));

function squareGridEdgeFaces(sideSize) = 
  let (secondStart = sideSize * sideSize)
  flattenPoints(flattenPoints([
    [for (step=[0:sideSize:secondStart - sideSize * 2]) [
      [step, step + sideSize, step + secondStart],
      [step + sideSize, step + sideSize + secondStart, step + secondStart],
      [step + sideSize - 1 + sideSize, step + sideSize - 1, step + sideSize - 1 + secondStart],
      [step + sideSize - 1 + sideSize, step + sideSize - 1 + secondStart, step + sideSize - 1 + sideSize + secondStart]
    ]],
    [for (step=[0:sideSize - 2]) [
      [step + 1, step, step + secondStart],
      [step + 1, step + secondStart, step + 1 + secondStart],
      [(secondStart - sideSize) + step, (secondStart - sideSize) + step + 1, secondStart * 2 - sideSize + step],
      [secondStart * 2 - sideSize + step, (secondStart - sideSize) + step + 1, secondStart * 2 - sideSize + step + 1]
    ]]
  ]));

function squareGridFaces(sideSize) = concat(squareGridEdgeFaces(sideSize), squareGridSurfaceFaces(sideSize));

module bezier(controlPoints, samples=10) {
  points = bezierPoints(controlPoints, samples);
  for (point=[1:len(points) - 1]) {
    hull() {
      translate(points[point - 1]) children(0);
      translate(points[point]) children(0);
    }
  }
  for (cp = controlPoints) {
    %color("red", 1.0) translate([cp[0], cp[1], len(cp) == 3 ? cp[2] : 0]) children(0);
  } 
}

module bezierSurface(controlPoints, thickness=1, samples=10) {
  polyhedron(points=concat(flattenPoints(bezierSurfacePoints(controlPoints, samples)), flattenPoints(offsetBezierSurfacePoints(controlPoints, thickness, samples))), faces=concat(squareGridEdgeFaces(samples), squareGridSurfaceFaces(samples)));
}
