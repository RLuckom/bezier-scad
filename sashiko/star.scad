UNIT = 16;
THIRD_UNIT = UNIT / 3;
THREE_HALF_UNIT = UNIT + UNIT * 0.5;
HALF_UNIT = UNIT / 2;
UNIT_WIDTH = sqrt(UNIT * UNIT + HALF_UNIT * HALF_UNIT);
THICKNESS=1;

POINTS = [
  [-3 * UNIT, -HALF_UNIT],
  [-3 * UNIT, 2.5 * UNIT],
  [-2 * UNIT, 2 * UNIT],
  [UNIT, 3.5 * UNIT],
  [UNIT, 2.5 * UNIT],
  [4 * UNIT, UNIT],
  [3 * UNIT, HALF_UNIT],
  [3 * UNIT, -2.5 * UNIT],
  [2 * UNIT, -2 * UNIT],
  [-UNIT, -3.5 * UNIT],
  [-UNIT, -2.5 * UNIT],
  [-4 * UNIT, -UNIT],
  [-UNIT, -HALF_UNIT],
  [-UNIT, HALF_UNIT],
  [0, UNIT],
  [UNIT, HALF_UNIT],
  [UNIT, -HALF_UNIT],
  [0, -UNIT],
];

linear_extrude(THICKNESS) polygon(points=POINTS, paths=[[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], [12, 13, 14, 15, 16, 17]]);
