include <./bezier.scad>;

// returns the ith possible permutatation of n-choose-k items.
// `n` and `k` must be posiitive integers. The order of the results
// is as though the array of numbers was a single integer in base `k`,
// ascending monotonically from 0 to the highest representable integer
// for the base and number of digits.
function combination(n, k, i, result=[]) = 
  (len(result) == k ? result :
    combination(n, k, i - (floor(i /  pow(n, k - len(result) - 1)) * pow(n, k - len(result) - 1)), concat(result, [floor(i / pow(n, k - len(result) - 1))])));

// Return the sum of the array. By supplying an initial `sum` parameter of
// [0, 0, 0, ...], this can sum arrays of integer vectors.
function sumArray(array, sum=0) =
  (len(array) == 0 ? sum : sumArray(slice(array, 1), sum + array[0]));

// Return the product of all the elements in the array.
function multArray(array, sum=1) =
  (len(array) == 0 ? sum : multArray(slice(array, 1), sum * array[0]));

// Return all combinations of `vars` digits with digits from 0-degree allowed,
// where the sum of the digits is equal to `degree`. This is useful for figuring
// out the exponents of terms in polynomial equations--each permutation of
// exponents from 0 to the polynomial's degree represents an arrangement of exponents
// next to variables in one term of the equation. The set of all permutations that add
// up to the degree of the polynomial is the exponents of all the terms in the polynomial.
// Assumes that the polynomial is a perfect power.
function nChooseKSum(degree, vars) =
  reverseArray([ for (i = [ 0 : pow(degree + 1, vars) - 1 ]) let (comb = combination(degree + 1, vars, i)) if (sumArray(comb) == degree) comb ]);

function fact(n, i=0, result=1) =
  i == n ? result : fact(n, i + 1, result * (i + 1));

// figures out the coefficient of a polynomial term based on the arrangement
// of exponents in the term.
// Assumes that the polynomial is a perfect power.
function coefficient(powerArray) =
  fact(sumArray(powerArray)) / multArray([for (i=powerArray) fact(i)]);

// using a "row" and "column" analogy, get the index into a one-dimensional
// array of an object using its coordinates in a pyramid structure. The capstone
// of the pyramid is position 0, 0 and each row has one more item than the one above
// it.
function getTriangleIndex(row, col) =
  sumArray([for (i = [0:row]) i]) + col;

// Unused, but interesting that it works.
function findControlPointIndexForPowers(powers) =
  getTriangleIndex(sumArray(powers) - powers[0], powers[len(powers) - 1]);

// Return the value of a term in a bezier polynomial.I think this should
// work for any number of barycentric dimensions.
// `powers`: an m-dimensional integer array of powers for each variable in the term
// `coefficient`: the scalar coefficient of the term
// `weights`: an m-dimensional array of weights, one for each variable
// `vars`: values for the variables, in the same order as the exponents
// `divisor`: an optional divisor to use for every value in `vars` before applying the exponent.
//   Useful for specifying barycentric coordinates as an array of integer numerators
//   of 1/`divisor` step sizes between 0 and 1.
function term(powers, coefficient, weights, vars, divisor=1) =
  multArray([for (i=[0:len(vars) - 1]) pow(vars[i] / divisor, powers[i])]) * weights * coefficient;

// Return a sampling of points on a cubic bezier triangle defined by `controlPoints`, 
// The points are in the triangular order specified in the `getTriangleIndex`
// function. 
// `controlPoints`: a list of 10 control points. using [this](https://upload.wikimedia.org/wikipedia/commons/e/e9/Bezier_triangle.png)
//    as a model, the points are b3, ab2, b2y, a2b, aby, by2, a3, a2y, ay2, y3
//  `detail`: a scalar to indicate how small the step size should be. Will be multiplied by 3
function cubicTriangleSurfacePoints(controlPoints, detail=4) =
  (
    let (
      powerArray = nChooseKSum(3, 3),
      coefficients = [for (p=powerArray) coefficient(p)],
      points = nChooseKSum(3 * detail, 3)
    )
    [
      for (point=points)
        sumArray(
          cubicTriangleSurfacePointTerms(powerArray, coefficients, controlPoints, point, 3 * detail),
          [0,0,0]
        )
    ]
  );

// a list of the values of each term in the polynomial
function cubicTriangleSurfacePointTerms(powerArray, coefficients, controlPoints, point, divisor) = 
  [for (t=[0:len(powerArray) - 1]) term(powerArray[t], coefficients[t], controlPoints[t], point, divisor)];

// A list of 3-vectors corresponding to faces represented as indicies
// into a flat array with the structure defined in `getTriangleIndex` using a detail 
// level as specified in `cubicTriangleSurfacePoints`
function triangleFaces(detail, start=0) =
  flattenPoints([for (row=[0:detail * 3 - 1])
    flattenPoints([for (index=[0:row]) 
      index == 0 ?
        [
          [
            getTriangleIndex(row, index) + start, 
            getTriangleIndex(row + 1, index) + start,
            getTriangleIndex(row + 1, index + 1) + start
          ]
        ]
      :
        [
          [
            getTriangleIndex(row, index) + start,
            getTriangleIndex(row, index - 1) + start,
            getTriangleIndex(row + 1, index) + start
          ],
          [
            getTriangleIndex(row, index) + start,
            getTriangleIndex(row + 1, index) + start,
            getTriangleIndex(row + 1, index + 1) + start
          ]
        ]
      ])
  ]);


function multipleTriangleFaces(detail, n) =
  (let (
    size=len(nChooseKSum(3 * detail, 3))
  )
  flattenPoints([for (face=[0:n - 1])
    triangleFaces(detail, face * size)
  ])
  );

function multipleCubicTriangleSurfacePoints(controlPointSets, detail) = 
  flattenPoints([for (controlPoints=controlPointSets)
    cubicTriangleSurfacePoints(controlPoints, detail)
  ]);


// flips a triagle, reversing a and y in the wikipedia image above.
function flipTriangle(triangle, rows) = 
  flattenPoints([for (row=[0:rows])
    [for (index=[0:row])
      triangle[getTriangleIndex(row, row - index)]
    ]
  ]);
