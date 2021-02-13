UNIT = 20;
HALF_UNIT = UNIT / 2;
HEIGHT = UNIT * 4;
UNIT_WIDTH = sqrt(UNIT * UNIT + HALF_UNIT * HALF_UNIT);
THICKNESS=1;

POINTS = [
  [-2 * UNIT_WIDTH, -UNIT],
  [-2 * UNIT_WIDTH, UNIT],
  [0, UNIT * 2],
  [2 * UNIT_WIDTH, UNIT],
  [2 * UNIT_WIDTH, -UNIT],
  [0, UNIT * -2],
  [-UNIT_WIDTH, -UNIT / 2],
  [-UNIT_WIDTH, UNIT / 2],
  [0, UNIT],
  [UNIT_WIDTH, UNIT / 2],
  [UNIT_WIDTH, -UNIT / 2],
  [0, -UNIT]
];

linear_extrude(THICKNESS) polygon(points=POINTS, paths=[[0, 1, 2, 3, 4, 5], [6, 7, 8, 9, 10, 11]]);
