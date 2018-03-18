use <./lib/bezier.scad>;
use<../vases/scad/lib/vase_functions.scad>;

FLAT_POINTS = [
  [[0, 0, 0], [2, -0, 0], [2, 0.5, -1], [4.5, 1, -2.5]],
  [[-0, 2, 0], [1, 1, 0], [3, 2, 2], [6, 3, -1]],
  [[0.5, 2, 0], [2, 3, 2], [4, 4, 2.5], [6, 4, 1]],
  [[1, 4.5, 0.5], [3, 6, 0], [4,6, 1], [6, 6, 1.5]]
];

module surface() {
bezierSurface(FLAT_POINTS, 0.15, 10, 0);
}

module petal() {
rotate([90, 0, 0]) rotate([0, 0, 45]) surface();
}


module bracelet() {
ring(2, 10) {
  translate([0, 0, 1 / 10 * 3]) mirror([0, 1, 0]) petal();
  translate([0, 0, 2 / 10 * 3]) mirror([0, 1, 0]) petal();
  translate([0, 0, 3 / 10 * 3]) mirror([0, 1, 0]) petal();
  translate([0, 0, 4 / 10 * 3]) mirror([0, 1, 0]) petal();
  translate([0, 0, 5 / 10 * 3]) mirror([0, 1, 0]) petal();
  translate([0, 0, 6 / 10 * 3]) mirror([0, 1, 0]) petal();
  translate([0, 0, 7 / 10 * 3]) mirror([0, 1, 0]) petal();
  translate([0, 0, 8 / 10 * 3]) mirror([0, 1, 0]) petal();
  translate([0, 0, 9 / 10 * 3]) mirror([0, 1, 0]) petal();
  translate([0, 0, 10 / 10 * 3]) mirror([0, 1, 0]) petal();
}
}
module vase() {
translate([0, 0, -0.5]) cylinder(1, r=6.3, $fn=50);
stack(3.3, 4) {
  scale([1.5, 1.5, 1]) bracelet();
  rotate([0, 0, 45]) scale([1.5, 1.5, 1]) bracelet();
}
}

//surface();

vase();
