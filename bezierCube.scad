use <./lib/bezier.scad>;

s0 = bezierSquare([2, 2, 0], [1, 2, 0], [2, 1, 0], [1, 1, 0]);
s1 = bezierSquare([0, 3, 0], [0, 3, 3], [0, 0, 0], [0, 0, 3]);
s1p = tieTop(s0, s1);
s2 = bezierSquare([3, 0, 0], [0, 0, 0], [3, 0, 3], [0, 0, 3]);
s2p = tieRight(s0, s2);
s3 = bezierSquare([3, 3, 3], [3, 3, 0], [3, 0, 3], [3, 0, 0]);
s3p = tieBottom(s0, s3);
s4 = bezierSquare([3, 3, 3], [0, 3, 3], [3, 3, 0], [0, 3, 0]);
s4p = tieLeft(s0, s4);
s5 = bezierSquare([3, 3, 3], [3, 0, 3], [0, 3, 3], [0, 0, 3]);

s5p = replacePoints(s5, [
  [2, 2, [0, 0, 0]],
  [2, 1, [3, 0, 0]],
  [1, 2, [0, 3, 0]],
  [1, 1, [3, 3, 0]]
]);

bezierSolid([s0, s1p, s2p, s3p, s4p, s5p], 30, 0.1);
