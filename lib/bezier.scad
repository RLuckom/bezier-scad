POLY_COEFFICIENTS = [[1],   // n=0
            [1,1],          // n=1
           [1,2,1],         // n=2
          [1,3,3,1],        // n=3
         [1,4,6,4,1],       // n=4
        [1,5,10,10,5,1],    // n=5
       [1,6,15,20,15,6,1]];  // n=6


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
