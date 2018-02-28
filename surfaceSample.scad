use <./lib/bezier.scad>;

POINTS = [
  [[0, 0, 10], [0, -10, -10], [20, 0, 0], [30, 0, 0]],
  [[0, 10, 0], [10, 10, -50], [20, 10, 0], [30, 10, 0]],
  [[0, 20, 0], [10, 20, 0], [20, 20, 50], [30, 20, 0]],
  [[0, 30, 0], [10, 30, 0], [20, 30, 0], [30, 30, 0]]
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

bezierPointDots(POINTS, 20) sphere(1);
