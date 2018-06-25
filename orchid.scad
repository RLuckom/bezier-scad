use <./lib/bezier.scad>;
w = 150;
wToH = 15 / 12;
wBy2 = w / 2;
a1x = wBy2 - wBy2 / 3;
a2x = wBy2 - wBy2 / 2;
b0x = wBy2;
c0x = wBy2;
wBy3 = w / 3;
h = wToH * w;
hBy2 = h / 2;
hBy3 = h / 3;
a1y = h / 10;
a2y = h / 20;
b0y = h - h / 5;
c0y = h - h / 6;

shouldery = hBy3 * 2;


s0 = [
[[-wBy2, shouldery, 0], [-a1x, a1y, 0], [-a2x, a2y, 0], [0, 0, 0]], 
[[-b0x, b0y, 0], [0, h / 2, 0], [0, h / 2, 0], [a2x, a2y, 0]],
[[-c0x, c0y, 0], [0, h / 2, 0], [0, h / 2, 0], [a1x, a1y, 0]], 
[[0, hBy3 * 2.8, 0], [c0x, c0y, 0], [b0x, b0y, 0], [wBy2, shouldery, 0]]
];

s1 = bezierSquare(s0[0][0], s0[0][3], s0[3][0], s0[3][3]);
s1p = replacePoints(s1, [
  [0, 1, s0[1][0]],
  [0, 2, s0[2][0]],
  [1, 0, s0[0][1]],
  [1, 3, s0[3][1]],
  [2, 0, s0[0][2]],
  [2, 3, s0[3][2]],
  [3, 1, s0[1][3]],
  [3, 2, s0[2][3]],
]);

wToD = 10 / 12;
depth = wToD * w;
halfOut = [-0.1, -h / 12, depth / 3];
out = [-0.1, shouldery, depth];

s2 = bezierSquare(s1p[3][3], s1p[3][0], out, halfOut);
s2 = bezierSquare(s1p[3][3], s1p[3][0], out, halfOut);

//s2p = replacePoints(s2, [
//]);

s2p = replacePoints(s2, [
  [2, 0, s1p[3][1]],
  [1, 0, s1p[3][2]],
  [2, 1, [w / 3, h / 3, depth / 3]],
  [2, 2, [w / 4, h / 3, depth / 2]],
  [1, 1, [w / 3, h / 3, depth / 3]],
  [1, 2, [w / 4, h / 3, depth / 2]],
  [0, 1, [w / 3, shouldery, depth]],
  [1, 3, [s2[1][3][0], s2[1][3][1], depth]],
  [2, 3, [s2[2][3][0], s2[2][3][1], depth]],
  [3, 1, [s2[3][1][0] - 0.2, s2[3][1][1] - 1, s2[3][1][2]]],
  [3, 2, [s2[3][2][0] + 0.4, s2[3][2][1] - 1, s2[3][2][2]]],
]);

thickness = 2;

difference() {
union() {
bezierSurface(s1p, thickness=-thickness, controlPointSize=.2);
bezierSurface(s2p, thickness=thickness, controlPointSize=.2);
mirror([1, 0, 0]) bezierSurface(s2p, thickness=thickness, controlPointSize=.2);
}
#translate([0, h - 30, -5]) cylinder(10, d=6, $fn=30);
#translate([-w, -h, -1]) cube([w * 2, h * 2, 1]);
}



// planter
//translate([0, 140, 40]) rotate([90, 0, 0]) cylinder(70, d1=80, d2=70);
