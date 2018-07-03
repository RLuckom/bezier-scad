include <./lib/bezier.scad>;
w = 15;
h = 21;
hexoffset = w / 3;
wexoffset = h / 3;
hex = (h - wexoffset) * (h / w) - 5;
wex = (w - hexoffset) * (w / h) - 5;

layerheight = 25;
l1 = layerheight + 15;
l1belly = 30;
l2 = layerheight * 2;
l2belly = 15;
l3 = layerheight * 3;
l3belly = 30;
lean = 7;
lean1 = lean;
lean2 = lean * 2;
lean3 = lean * 3;
SAMPLES = 10;

TOP_SLANT = -0.25;
ts = TOP_SLANT;

zh = layerheight * 5;
toplean = .07;

THICKNESS=3;

s1A = [-w, -h, 0];
s1M = [-w, h, 0];
s1D = [w, -h, 0];
s1P = [w, h, 0];

s1 = bezierSquare(s1A, s1M, s1D, s1P);

s1p = replacePointsCoords(s1, [
  [B, [-hexoffset, -h - hex, 0]],
  [C, [hexoffset, - h - hex, 0]],
  [I, [- w - wex, wexoffset, 0]],
  [E, [-w - wex, -wexoffset, 0]],
  [L, [ w + wex,  wexoffset, 0]],
  [H, [ w + wex, -wexoffset, 0]],
  [N, [-hexoffset,  h + hex, 0]],
  [O, [ hexoffset,  h + hex, 0]]
]);
//#translate([-300, -300, -10]) cube([600, 600, 1]);
//#translate([-300, 260, -300]) rotate([75, 0, 0]) cube([600, 1100, 1]);

s2 = [
  s1p[0],
  [[-w - l1belly, -h + lean1,l1 + ts * ( -h + lean1)], [-hexoffset, -h -hex - l1belly + lean1,l1 + ts * ( -h -hex - l1belly + lean1)], [hexoffset, -h - hex - l1belly + lean1,l1 + ts * ( -h - hex - l1belly + lean1)], [w + l1belly, -h + lean1,l1 + ts * ( -h + lean1)]],
  [[-w - l2belly, -h + lean2,l2 + ts * ( -h + lean2)], [-hexoffset, -h -hex - l2belly + lean2,l2 + ts * ( -h -hex - l2belly + lean2)], [hexoffset, -h - hex - l2belly + lean2,l2 + ts * ( -h - hex - l2belly + lean2)], [w + l2belly, -h + lean2,l2 + ts * ( -h + lean2)]],
  [[-w - l3belly, -h + lean3,l3 + ts * ( -h + lean3)], [-hexoffset, -h -hex - l3belly + lean3,l3 + ts * ( -h -hex - l3belly + lean3)], [hexoffset, -h - hex - l3belly + lean3,l3 + ts * ( -h - hex - l3belly + lean3)], [w + l3belly, -h + lean3,l3 + ts * ( -h + lean3)]],
];

s3 = [
  s1p[3],
  [[-w - l1belly, h + lean1, l1], [-hexoffset, h +hex + l1belly + lean1, l1], [hexoffset, h + hex + l1belly + lean1, l1], [w + l1belly, h + lean1, l1]],
  [[-w - l2belly, h + lean2, l2], [-hexoffset, h +hex + l2belly + lean2 + 7, l2], [hexoffset, h + hex + l2belly + lean2 + 7, l2], [w + l2belly, h + lean2, l2]],
  [[-w - l3belly, h + lean3,l3  + ts * ( h + lean3)], [-hexoffset, h +hex + l3belly + lean3,l3 + ts * ( h +hex + l3belly + lean3)], [hexoffset, h + hex + l3belly + lean3,l3  + ts * ( h + hex + l3belly + lean3)], [w + l3belly, h + lean3,l3  + ts * ( h + lean3)]],
];

s4 = [
  [s1p[0][3], s1p[1][3], s1p[2][3], s1p[3][3]],
  [s2[1][3], [s2[1][2][0] + ((s2[1][2][0] - s2[1][3][0]) /  (s2[1][2][1] - s2[1][3][1])) * ((-wexoffset + lean1) - s2[1][2][1]), -wexoffset + lean1, l1 + ts * (-wexoffset + lean1)], [s3[1][2][0] + ((s3[1][2][0] - s3[1][3][0]) /  (s3[1][2][1] - s3[1][3][1])) * (wexoffset + lean1 - s3[1][2][1]), wexoffset + lean1, l1 + ts * (wexoffset + lean1)], s3[1][3]],
  [s2[2][3], [s2[2][2][0] + ((s2[2][2][0] - s2[2][3][0]) / (s2[2][2][1] - s2[2][3][1])) * (-wexoffset + lean2 - s2[2][2][1]), -wexoffset + lean2, l2 + ts * (-wexoffset + lean2)], [s3[2][2][0] + ((s3[2][2][0] - s3[2][3][0]) /  (s3[2][2][1] - s3[2][3][1])) * (wexoffset + lean2 - s3[2][2][1]), wexoffset + lean2, l2 + ts * (wexoffset)], s3[2][3]],
  [s2[3][3], [s2[3][2][0] + ((s2[3][2][0] - s2[3][3][0]) /  (s2[3][2][1] - s2[3][3][1])) * (-wexoffset + lean3 - s2[3][2][1]), -wexoffset + lean3, l3 + ts * (-wexoffset + lean3)], [s3[3][2][0] + (s3[3][2][0] - s3[3][3][0]) /  (s3[3][2][1] - s3[3][3][1]) * (wexoffset + lean3 - s3[3][2][1]), wexoffset + lean3, l3 + ts * (wexoffset + lean3)], s3[3][3]],
];

tl = toplean;

s5 = [
  s3[3],
  [[-w - l3belly, h + hex + lean3 + l3belly + tl * (s3[3][0][2] + (zh - s3[3][0][2]) / 3), s3[3][0][2] + (zh - s3[3][0][2]) / 3], [-hexoffset, h + hex + lean3 + l3belly + tl * (s3[3][1][2] + (zh - s3[3][1][2]) / 3), s3[3][1][2] + (zh - s3[3][1][2]) / 3], [hexoffset, h + hex + lean3 + l3belly + tl * (s3[3][2][2] + (zh - s3[3][2][2]) / 3),  s3[3][2][2] + (zh - s3[3][2][2]) / 3], [w + l3belly, h + hex + lean3 + l3belly + tl * (s3[3][3][2] + (zh -s3[3][3][2]) / 3), s3[3][3][2] + (zh - s3[3][3][2]) / 3]],
  [[-w - l3belly, h + hex + lean3 + l3belly + tl * (s3[3][0][2] + (zh - s3[3][0][2]) / 3 * 2), s3[3][0][2] + (zh - s3[3][0][2]) / 3 * 2], [-hexoffset, h + hex + lean3 + l3belly + tl * (s3[3][0][2] + (zh - s3[3][0][2]) / 3 * 2), s3[3][1][2] + (zh - s3[3][1][2]) / 3 * 2], [hexoffset, h + hex + lean3 + l3belly + tl * (s3[3][2][2] + (zh - s3[3][2][2]) / 3 * 2), s3[3][2][2] + (zh - s3[3][2][2]) / 3 * 2], [w + l3belly, h + hex + lean3 + l3belly + tl * (s3[3][3][2] + (zh - s3[3][3][2]) / 3 * 2), s3[3][3][2] + (zh - s3[3][3][2]) / 3 * 2]],
  [[-w , h + hex + lean3 + l3belly + tl * zh, zh - 2], [-hexoffset, h + hex + lean3 + l3belly + tl * zh, zh], [hexoffset, h + hex + lean3 + l3belly + tl * zh, zh], [w, h + hex + lean3 + l3belly + tl * zh, zh - 2]]
];

module bezierSphere(controlPoints, samples=10, controlPointSize=1, startSize=1, endSize=1) {
  points = bezierPoints(controlPoints, samples);
  step = (endSize - startSize) / len(points);
  for (point=[1:len(points) - 1]) {
    hull() {
      translate(points[point - 1]) sphere(startSize + step * (point - 1), $fn=20);
      translate(points[point]) sphere(startSize + step * (point), $fn=20);
    }
  }
  showBezierControlPoints(controlPoints, controlPointSize=controlPointSize);
}

armthickness = 10;
module frontArm() {
  bezierSphere([s4[0][0], tie(s4[0][0], s4[0][1]), [w, -h * 1.6, 0], [w * 2, -h * 2, 0]], startSize=armthickness, endSize=armthickness / 4, samples=SAMPLES);
}

module backArm() {
  toplean_x = s5[3][0][1] - toplean * s5[0][1][2];
  bezierSphere([s3[0][1], tie(s3[0][0], s4[0][1]), [0, h * 4, 0], [-w * 2, toplean_x, 0]], startSize=armthickness, endSize=armthickness / 3, samples=SAMPLES, controlPointSize=10);
}

module cup(thickness=THICKNESS) {
  union() {
    bezierSurface(s1p, thickness=thickness, controlPointSize=.4);
    //bezierSphere(s4[0], startSize=armthickness / 4, endSize=armthickness, samples=SAMPLES);
    //bezierSphere(s1p[0], startSize=armthickness, endSize=armthickness, samples=SAMPLES);
    //mirror([1, 0, 0]) bezierSphere(s4[0], startSize=armthickness / 4, endSize=armthickness, samples=SAMPLES);
    //bezierSphere(s3[0], startSize=armthickness, endSize=armthickness, samples=SAMPLES);
    //frontArm();
    //backArm();
    //mirror([1, 0, 0]) backArm();
    //mirror([1, 0, 0]) frontArm();
    bezierSurface(s2, thickness=-thickness, controlPointSize=4, samples=SAMPLES);
    bezierSurface(s3, thickness=thickness, controlPointSize=8, samples=SAMPLES);
    bezierSurface(s4, thickness=-thickness, controlPointSize=6, samples=SAMPLES);
    mirror([1, 0, 0]) bezierSurface(s4, thickness=-thickness, controlPointSize=4, samples=SAMPLES);
    bezierSurface(reverseHandedness(s5), thickness=-thickness, controlPointSize=4, samples=SAMPLES);
  }
}

module keyhole(topY, topZ) {
#translate([0, topY, 110]) rotate([90, 0, 0])  cylinder(10, d=6, $fn=30);
#translate([-3, topY - 10, topZ - 6]) cube([6, 10, 6]);
#translate([0, topY, topZ - 8]) rotate([90, 0, 0])  cylinder(10, d=9, $fn=30);
}

module base(w, h) {
#translate([-3 * w, - 3 * h, -15]) cube([6 * w, 9 * h, 15]);
}

module small() {
difference() {
cup(thickness=3);
keyhole(h + 73, 110);
base();
dia = 10;
#translate([0, -h, -4]) cylinder(10, d=dia, $fn=20);

/*
 for (point=flattenPoints(bezierSurfacePoints(s1p, 9))) {
    #translate(point) cube([2, 3, 30], center=true);
  }

 for (point=flattenPoints(bezierSurfacePoints(s2, 15))) {
    if (point[2] > 10 && point[2] < 65) {
    #translate(point) rotate([0, 0,  -atan2(point[0], point[1])]) cube([2, 30, 3], center=true);
    }
  }

 for (point=flattenPoints(bezierSurfacePoints(s4, 15))) {
    if (point[2] > 10 && point[2] < 55) {
    #translate(point) rotate([0, 0,  -atan2(point[0], point[1])]) cube([2, 30, 3], center=true);
    mirror([1, 0, 0]) #translate(point) rotate([0, 0,  -atan2(point[0], point[1])]) cube([2, 30, 3], center=true);
    }
  }
*/
}
}

module medium() {
difference() {
scale([1.5, 1.5, 1.5]) cup(thickness=3 / 1.5);
keyhole((h + 75) * 1.5, 110 * 1.5);
base();
dia = 10;
#translate([0, -h, -4]) cylinder(10, d=dia, $fn=20);
}
}

module large() {
}

small();
