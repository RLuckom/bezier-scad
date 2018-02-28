use <./lib/bezier.scad>;

POINTS = [
  [12, 16],
  [3.5, 20, 20],
  [22, 26, -20],
  [22, 4, 4.5]
];

POINTS2 = [
  [22, 4, 4.5],
  [22, -26, 29],
  [5, 10, -9], 
  [0, -20, 0]
]; 

bezier(POINTS, 30) sphere(1, $fn=20);
bezier(POINTS2, 30) sphere(1, $fn=20);


flatPoints = [
  [22, 4],
  [50, 10], 
  [-40, -200],
  [0, -200]
];

translate([40, 30, 0]) bezier(flatPoints, 100) circle(2);
