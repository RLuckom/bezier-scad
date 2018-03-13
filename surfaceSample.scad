use <./lib/bezier.scad>;

POINTS = [
  [[8, 8, -20], [0, -10, -10], [20, 0, 0], [24, 3, -10]],
  [[0, 10, 0], [10, 10, -50], [20, 10, 100], [30, 10, 0]],
  [[0, 20, 0], [10, 20, 100], [20, 20, -50], [30, 20, 0]],
  [[8, 29, -10], [10, 30, 0], [20, 30, 0], [22, 22, -20]]
];

CLOSING_POINTS = [
  [[8, 8, -20], [0, -10, -10], [20, 0, 0], [24, 3, -10]],
  [[0, 10, 0], [10, 10, -50], [20, 10, 100], [30, 10, 0]],
  [[0, 20, 0], [10, 20, 100], [20, 20, -50], [30, 20, 0]],
  [[8, 29, -10], [10, 30, 0], [20, 30, 0], [22, 22, -20]]
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

EYE_POINTS = [
  [[0.8, 0.8, 0], [2, 0, 0], [3.7, 0, 0], [5, 0.8, 0]],
  [[0.5, 2.5, 0], [-2, -2, 6], [8, -2, 6], [5.5, 2.3, 0]],
  [[0, 3.7, 0], [-2, 8, 6], [8, 8, 6], [6, 4, 0]],
  [[0.8, 5, 0], [2.3, 5.5, 0], [4, 6, 0], [5.2, 5.2, 0]]
];

module eye() {
difference() {
  hull() bezierSurface(EYE_POINTS, 0.2, 20, 0.2);
}
}

PUPIL_POINTS = [
  [0, 0, -1],
  [1.5, -10, -1.3],
  [3, 10, 1],
  [4.5, -10, -1.3],
  [6, 0, -0]
];

module pupil() {
  scale([0.4, 0.4, 0.4]) bezier(PUPIL_POINTS, 30) sphere(1, $fn=20);
}

module thing() {
translate([14.2, -1, 5]) rotate([-80, 49, -45]) eye();
rotate([0, 0, 97]) translate([13.6, -2, 5]) rotate([-80, 45, -125]) eye();
translate([-15, -20, 0]) for(x=[15:15:360]) scale([x/360, x / 360, x/ 360]) rotate([x, 0, 0]) translate([0, x / 360 * 4, 0]) bezierSurface(POINTS, 5, 37, 1); 
}
thing();
