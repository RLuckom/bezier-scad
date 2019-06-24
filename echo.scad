use <./lib/bezier.scad>;

function combination(n, k, i, result=[]) = 
  (len(result) == k ? result :
    combination(n, k, i - (floor(i /  pow(n, k - len(result) - 1)) * pow(n, k - len(result) - 1)), concat(result, [floor(i / pow(n, k - len(result) - 1))])));

function sumArray(array, sum=0) =
  (len(array) == 0 ? sum : sumArray(slice(array, 1), sum + array[0]));

function multArray(array, sum=1) =
  (len(array) == 0 ? sum : multArray(slice(array, 1), sum * array[0]));

function nChooseKSum(degree, vars) =
  reverseArray([ for (i = [ 0 : pow(degree + 1, vars) - 1 ]) let (comb = combination(degree + 1, vars, i)) if (sumArray(comb) == degree) comb ]);

function fact(n, i=0, result=1) =
  i == n ? result : fact(n, i + 1, result * (i + 1));

function coefficient(powerArray) =
  fact(sumArray(powerArray)) / multArray([for (i=powerArray) fact(i)]);

function getTriangleIndex(row, col) =
  sumArray([for (i = [0:row]) i]) + col;

function findControlPointIndexForPowers(powers) =
  getTriangleIndex(sumArray(powers) - powers[0], powers[len(powers) - 1]);

function term(powers, coefficient, weights, vars, longDetail) =
  multArray([for (i=[0:len(vars) - 1]) pow(vars[i] / longDetail, powers[i])]) * weights;

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

function cubicTriangleSurfacePointTerms(powerArray, coefficients, controlPoints, point, longDetail) = 
  [for (t=[0:len(powerArray) - 1]) term(powerArray[t], coefficients[t], controlPoints[t], point, longDetail)];

function triangleFaces(longDetail) =
  flattenPoints([for (row=[0:longDetail - 1])
    flattenPoints([for (index=[0:row]) 
      index == 0 ?
        [
          [
            getTriangleIndex(row, index), 
            getTriangleIndex(row + 1, index),
            getTriangleIndex(row + 1, index + 1)
          ]
        ]
      :
        [
          [
            getTriangleIndex(row, index),
            getTriangleIndex(row, index - 1), 
            getTriangleIndex(row + 1, index)
          ],
          [
            getTriangleIndex(row, index),
            getTriangleIndex(row + 1, index),
            getTriangleIndex(row + 1, index + 1)
          ]
        ]
      ])
  ]);

echo(nChooseKSum(3, 3));
echo([for (i=nChooseKSum(3, 3)) findControlPointIndexForPowers(i)]);
echo(nChooseKSum(12, 3));
echo(combination(4, 3, 8));
echo(getTriangleIndex(3,0));
echo([0, 3, 0] + [0, 1, 1]);
echo(fact(0));
echo(cubicTriangleSurfacePoints(nChooseKSum(3,3)));
echo(triangleFaces(12));
echo(len(cubicTriangleSurfacePoints(nChooseKSum(3,3))));
echo(cubicTriangleSurfacePointTerms(
   nChooseKSum(3, 3),
   [for (p=nChooseKSum(3, 3)) coefficient(p)],
   nChooseKSum(3, 3),
   [12, 0, 0],
   12
));
polyhedron(points=cubicTriangleSurfacePoints(nChooseKSum(3,3), 8), faces=(triangleFaces(3 * 8)));
