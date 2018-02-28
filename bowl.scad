use <./lib/bezier.scad>;

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
}


module flower() {
  for (i=[0:30:360]) {
    rotate([0, 0, i]) petal();
  }
}

flower();
