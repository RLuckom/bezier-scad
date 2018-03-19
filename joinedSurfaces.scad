use <./lib/bezier.scad>;

s0 = bezierSquare([0, 0, 0], [0, 3, 0], [3, 0, 3], [3, 3, 3]);
s1 = bezierSquare([-3, 0, 0], [-3, 3, 0], [0, 0, 0], [0, 3, 0]);
s2 = bezierSquare([3, 0, 0], [3, 3, 0], [6, 0, 0], [6, 3, 0]);
s3 = bezierSquare([0, -3, 0], [0, 0, 0], [3, -3, 0], [3, 0, 0]);
s4 = bezierSquare([0, 3, 0], [0, 6, 0], [3, 3, 0], [3, 6, 0]);
s5 = bezierSquare([3, -3, 0], [3, 0, 0], [6, -3, 0], [6, 0, 0]);
s6 = bezierSquare([-3, 3, 0], [-3, 6, 0], [0, 3, 0], [0, 6, 0]);
s7 = bezierSquare([-3, -3, 0], [-3, 0, 0], [0, -3, 0], [0, 0, 0]);
s8 = bezierSquare([3, 3, 0], [3, 6, 0], [6, 3, 0], [6, 6, 0]);

s1p = tieHardLeft(s0, s1);
s2p = tieHardRight(s0, s2);
s3p = tieHardBottom(s0, s3);
s4p = tieHardTop(s0, s4);
s5p = tieHardBottom(s2p, s5);
s6p = tieHardTop(s1p, s6);
s7p = tieHardBottom(s1p, s7);
s8p = tieHardTop(s2p, s8);

bezierSolid([s0, s1p, s2p, s3p, s4p, s5p, s6p, s7p, s8p], 10, 0.1);
