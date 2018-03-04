use <./lib/bezier.scad>;

POINTS = [
  [[8, 8, 0], [0, -10, -10], [20, 0, 0], [24, 3, 0]],
  [[0, 10, 0], [10, 10, -50], [20, 10, 0], [30, 10, 0]],
  [[0, 20, 0], [10, 20, 0], [20, 20, -50], [30, 20, 0]],
  [[8, 29, 0], [10, 30, 0], [20, 30, 0], [22, 22, 0]]
];

RAISED_POINTS = [
  [[0, 0, 12], [0, -10, -8], [20, 0, 2], [30, 0, 2]],
  [[0, 10, 2], [10, 10, -48], [20, 10, 2], [30, 10, 2]],
  [[0, 20, 2], [10, 20, 2], [20, 20, 52], [30, 20, 2]],
  [[0, 30, 2], [10, 30, 2], [20, 30, 2], [30, 30, 2]]
];

module bezierPointDots(controlPointArrays, samples=10) {
  pointArrays = bezierSurfacePoints(controlPointArrays, samples);
  for (pointArray=pointArrays) {
    for (point=pointArray) {
      translate(point) children(0);
    }
  }
  for (controlPointArray = controlPointArrays) {
    for(cp=controlPointArray) {
      %color("red", 1.0) translate([cp[0], cp[1], len(cp) == 3 ? cp[2] : 0]) children(0);
    }
  } 
}

//bezierPointDots(POINTS, 20) sphere(1);
//bezierPointDots(RAISED_POINTS, 20) sphere(1);

sps = concat(flattenPoints(bezierSurfacePoints(POINTS)), flattenPoints(bezierSurfacePoints(RAISED_POINTS)));

echo(squareGridSurfaceFaces(10));
echo(len(squareGridSurfaceFaces(10)));
echo(len(sps));
echo(sps[109]);
echo(sps[110]);
/*
for (points = squareGridEdgeFaces(10)) {
  echo([for (point = points) sps[point]]);
}


for (p = bezierSurfacePoints(POINTS)[0]) {
  echo(p);
  translate(p) sphere(1);
}
echo(2);
for (p = bezierSurfacePoints(RAISED_POINTS)[0]) {
  echo(p);
  translate(p) sphere(1);
}
*/

FLAT_POINTS = [
  [[0, 0, 0], [1, 0, 0], [2, 0, 0], [3, 0, 0]],
  [[0, 1, 0], [1, 1, 0], [2, 1, 0], [3, 1, 0]],
  [[0, 2, 0], [1, 2, 0], [2, 2, 0], [3, 2, 0]],
  [[0, 3, 0], [1, 3, 0], [2, 3, 0], [3, 3, 0]]
];

echo(solveDerivativeValue(1, 3, 0, 1, 1));
echo(0 * pow(1 - 1, -1));

echo(bezierSurfaceTangentVec(0.8, 1, FLAT_POINTS, 1));

echo(offsetBezierSurfacePoints(FLAT_POINTS));
bezierSurface(POINTS, 1, 36); 
