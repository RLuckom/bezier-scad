use <./lib/triangleBezier.scad>;

controlPoints = [
  [4, 0, 0],
  [3, 0, 0],
  [3, 1, 0],
  [2, 0, 0],
  [2, 1, 8],
  [2, 2, 0],
  [1, 0, 0],
  [1, 1, 0],
  [1, 2, 0],
  [1, 3, 0]
];


polyhedron(points=flipTriangle(cubicTriangleSurfacePoints(controlPoints, 8), 8 * 3), faces=(triangleFaces(8)));
