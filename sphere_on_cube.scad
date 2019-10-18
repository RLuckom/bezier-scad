
binomial_terms = [
      [1],               // n = 0
     [1, 1],             // n = 1
    [1, 2, 1],           // n = 2
   [1, 3, 3, 1],         // n = 3
  [1, 4, 6, 4, 1],       // n = 4
 [1, 5, 10, 10, 5, 1],   // n = 5
[1, 6, 15, 20, 15, 6, 1] // n = 6
];
function bezier_coordinate(t, weights, term=0, total=0) =
  let (
     n = len(weights) - 1,
     binomial_row = binomial_terms[n],
     a = 1 - t,
     b = t,
     a_pow = n - term,
     b_pow = term
  )
  (term > n ? total :
    bezier_coordinate(
      t,
      weights,
      term + 1,
      total + (weights[term] * binomial_row[term] * pow(a, a_pow) * pow(b, b_pow))
    )
  );
function bezier_point(t, control_points) =
  [
    bezier_coordinate(t, [for (point = control_points) point[0]]),
    bezier_coordinate(t, [for (point = control_points) point[1]]),
    bezier_coordinate(t, [for (point = control_points) point[2]]),
  ];

function bezier_curve_points(control_points, number_of_points) =
  [for (t=[0:number_of_points]) bezier_point(t * (1 / number_of_points), control_points)];

module draw_points(points) {
  for (point = points) {
    translate(point) children(0);
  }
}
module piecewise_join(points) {
  for (n=[1:len(points) - 1]) {
    hull() {
      translate(points[n-1]) children(0);
      translate(points[n]) children(0);
    }
  }
}

module bezier(control_points, number_of_sections) {
  piecewise_join(bezier_curve_points(control_points, number_of_sections)) children(0);
}

LEAF_EDGE_CONTROL_POINTS = [
  [0, 0, 0],
  [2, 20, 0],
  [24, 80, 60],
  [16, 40, 40],
  [0, 60, 75]
];
LEAF_CENTER_CONTROL_POINTS = [
  [0, 0, 0],
  [0, 20, 0],
  [0, 80, 10],
  [0, 40, 55],
  [0, 60, 75]
];


SAMPLES = 20;

module leaf_half() {
  bezier(LEAF_EDGE_CONTROL_POINTS, SAMPLES) sphere(2);
  edge_points = bezier_curve_points(LEAF_EDGE_CONTROL_POINTS, SAMPLES);
  center_points = bezier_curve_points(LEAF_CENTER_CONTROL_POINTS, SAMPLES);
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


module leaf() {
  leaf_half();
  mirror([1, 0, 0]) leaf_half();
  bezier(LEAF_CENTER_CONTROL_POINTS, SAMPLES) sphere(2);
}

LEAVES = 12;
for (i=[0:360 / LEAVES: 360]) {
  rotate([0, 0, i]) leaf();
}
