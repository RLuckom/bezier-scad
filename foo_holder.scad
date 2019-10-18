use <./lib/bezier.scad>;

rad = 35;
echo(rad);
pad = 4;
width = PI * rad * 2 / 6;
peg_width = 30;
peg_thickness = 4;
SAMPLES = 40;

shoulder_height = width / 3 * 2;
height = width * 3;
bowl_depth = width / 4 * 3;

A = [0, 0, 0];
M = [width, 0, shoulder_height];

E = [width / 2, 0, 0];
I = [width, 0, shoulder_height / 3];

F = [0, -bowl_depth, height / 3];
J = [width / 6, -bowl_depth - bowl_depth / 3, height / 2];

N = [I[0] - width / 12, 0, shoulder_height * 2];
O = [width, 0, height / 4 * 3];

G = [-J[0], J[1], J[2]];
K = [F[0], F[1], height / 3 * 2.5];

P = [0, bowl_depth / 3 * 2, height];

C = [-I[0], I[1], I[2]];
B = [-E[0], E[1], E[2]];
D = [-M[0], M[1], M[2]];
H = [-N[0], N[1], N[2]];
L = [-O[0], O[1], O[2]];

points = [
  [A, B, C, D],
  [E, F, G, H],
  [I, J, K, L],
  [M, N, O, P]
];

module outer_petal() {
  hull() translate([0, -(rad + pad), -bowl_depth / 3]) rotate([38, 0, 0]) bezierSurface(points, samples=SAMPLES, controlPointSize=1);
}

module inner_petal() {
  hull() translate([0, -(rad + pad), 0]) rotate([30, 0, 0]) bezierSurface(points, samples=SAMPLES, controlPointSize=1);
}

module keyhole(topY, topZ) {
#translate([0, topY, topZ]) rotate([90, 0, 0])  cylinder(10, d=6, $fn=30);
#translate([-3, topY - 10, topZ - 6]) cube([6, 10, 6]);
#translate([0, topY, topZ - 8]) rotate([90, 0, 0])  cylinder(10, d=9, $fn=30);
}


difference() {
union() {
translate([-peg_width / 2, -peg_thickness, height / 2]) cube([peg_width, peg_thickness, height / 3]);
translate([0, 0, height / 8 * 3]) cylinder(height / 8, r1=rad * 2, r2=rad * 2.25, $fn=80);
outer_petal();
rotate([0, 0, 70]) outer_petal();
rotate([0, 0, 35]) inner_petal();
rotate([0, 0, -35]) inner_petal();
rotate([0, 0, -70]) outer_petal();
}
translate([-height * 4, 0, -height * 2]) cube(height * 8);
keyhole(0, height / 4 * 3);
translate([-42.5, -57 - peg_thickness - 3, height / 2]) cube([85, 57, 400]);
}
