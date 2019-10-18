use <./lib/triangleBezier.scad>;

echo(nChooseKSum(3, 3));
echo([for (i=nChooseKSum(3, 3)) findControlPointIndexForPowers(i)]);
echo(nChooseKSum(12, 3));
echo(combination(4, 3, 8));
echo(getTriangleIndex(3,0));
echo([0, 3, 0] + [0, 1, 1]);
echo(fact(0));
echo(cubicTriangleSurfacePoints(nChooseKSum(3,3)));
echo(len(cubicTriangleSurfacePoints(nChooseKSum(3,3))));
echo(cubicTriangleSurfacePointTerms(
   nChooseKSum(3, 3),
   [for (p=nChooseKSum(3, 3)) coefficient(p)],
   nChooseKSum(3, 3),
   [12, 0, 0],
   12
));
echo(radiusTriangle(40, 90));
for (n = radiusTriangle(40, 90)) {
  translate(n) sphere(1);
}
polyhedron(points=mirrorPointsArray([0,0, 1], translatePointsArray([0, 0, 3], cubicTriangleSurfacePoints(flipTriangleControlPoints(radiusTriangle(4, 90), 8)))), faces=(triangleFaces(8)));
