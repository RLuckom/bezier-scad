use <./lib/triangleBezier.scad>;

controlPoints = [
  [4, 0, 0],
  [3, 0, 0],
  [3, 1, 0],
  [2, 0, 0],
  [2, 1, 7],
  [2, 2, 0],
  [1, 0, 0],
  [1, 1, 0],
  [1, 2, 0],
  [1, 3, 0]
];

controlPoints2 = flipTriangle([
  [4, 0, 0],
  [3, 0, 0],
  [3, 1, 0],
  [2, 0, 0],
  [2, 1, -7],
  [2, 2, 0],
  [1, 0, 0],
  [1, 1, 0],
  [1, 2, 0],
  [1, 3, 0]
], 4);

polyhedron(points=multipleCubicTriangleSurfacePoints([controlPoints, controlPoints2], 8), faces=(multipleTriangleFaces(8, 2)));
