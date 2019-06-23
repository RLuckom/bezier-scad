use <./lib/bezier.scad>;

l = 35;
l0 = 0;
l3 = 35 / 4 * 3;
l6 = l;
l1 = l3 / 3;
l2 = l1 * 2;
l4 = l3 + (l6 - l3) / 3;
l5 = l3 + (l6 - l3) / 3 * 2;

w = 20;
w0 = 0;
w3 = w / 2;
w6 = w;
w1 = w3 / 3;
w2 = w1 * 2;
w4 = w3 + (w6 - w3) / 3;
w5 = w3 + (w6 - w3) / 3 * 2;

z0 = 0;


bottom = [
  [
    [w0 + 4, l3, z0],
    [w1 + 1, l2, z0],
    [w2, l1, z0],
    [w3, l0, z0]
  ],
  [
    [w1 + 1, l4, z0],
    [w2, l3, z0],
    [w3, l2, z0],
    [w4, l1, z0]
  ],
  [
    [w2, l5, z0],
    [w3, l4, z0],
    [w4, l3, z0],
    [w5 - 1, l2, z0]
  ],
  [
    [w3, l6, z0],
    [w4, l5, z0],
    [w5 - 1, l4, z0],
    [w6 - 4, l3, z0]
  ]
];
z00 = z0;
z01 = 1;
z02 = -16;
z03 = -6;
z04 = 16;
z05 = 20;
z06 = 24;
z10 = z0;
z11 = 4;
z12 = 8;
z13 = 16;
z14 = 24;
z15 = 20;
z20 = z0;
z21 = 8;
z22 = 16;
z23 = 24;
z24 = 20;
z30 = z0;
z31 = 16;
z32 = 24;
z33 = 16;
ls1 = 1.46;
ls2 = 1.8;
top = [
  [
    [w0 + 1.5, l3 * ls1 - 10, z33],
    [w1, l2 * ls1, z22],
    [w2, l1 * ls1, z11],
    [w3, l0 * ls1, z00]
  ],
  [
    [w1, l4 * ls1 + 2.75, z24],
    [w2, l3 * ls1, z13],
    [w3, l2 * ls1, z02],
    [w4, l1 * ls1, z11]
  ],
  [
    [w2, l5 * ls1 + 2.75, z15],
    [w3, l4 * ls1, z04],
    [w4, l3 * ls1 + 4, z13 + 6],
    [w5, l2 * ls1, z22]
  ],
  [
    [w3, l6 * ls1, z06],
    [w4, l5 * ls1 + 2.75, z15],
    [w5, l4 * ls1 + 2.75, z24],
    [w6 - 1.5, l3 * ls1 - 10, z33]
  ]
];

outside = [
 []
];

PETAL_EDGE_CONTROL_POINTS = [
  [0, 0, 0],
  [2, 20, 0],
  [24, 80, 60],
  [16, 40, 40],
  [0, 60, 75]
];

PETAL_CENTER_CONTROL_POINTS = [
  [0, 0, 0],
  [0, 20, 0],
  [0, 80, 10],
  [0, 40, 55],
  [0, 60, 75]
];

SAMPLES = 20;

module petal_half() {
  bezier(PETAL_EDGE_CONTROL_POINTS, SAMPLES) sphere(2);
  edge_points = bezierPoints(PETAL_EDGE_CONTROL_POINTS, SAMPLES);
  center_points = bezierPoints(PETAL_CENTER_CONTROL_POINTS, SAMPLES);
  for (i=[6:SAMPLES]) {
    ep = edge_points[i];
    cp = center_points[i - 3];
    vein_points = [
      ep,
      [((ep[0] + cp[0]) / 2), ((ep[1] + cp[1]) / 2), ((ep[2] + cp[2]) / 2) - 5],
      cp
    ];
    bezier(vein_points, SAMPLES) sphere(1.2);
  }
}

module petal() {
  petal_half();
  mirror([1, 0, 0]) petal_half();
  bezier(PETAL_CENTER_CONTROL_POINTS, SAMPLES) sphere(2);
  translate([- w / 2, 0, -2]) bezierSurfaceFromTwoFaces(bottom, top, controlPointSize=0.4);
}


module flower() {
  for (i=[0:30:360]) {
    rotate([0, 0, i]) petal();
  }
}

//petal();

flower();
