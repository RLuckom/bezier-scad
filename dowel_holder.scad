use <./lib/bezier.scad>;

stem_width = 10;
max_width = 20;
close_width = 16;
point_width = 4;
throat_depth = 16;
mouth_depth = 8;
inner_height = 10;
throat_height = 3;
mouth_height = 8;
base_thickness = 3;
base_top_thickness = 1;
base_top_thickness_2 = .75;
base_top_thickness_3 = .25;

top_1_pull_1 = 4;
top_1_pull_2 = 3;

a1 = [stem_width / -2, 0, 0];
d1 = [stem_width / 2, 0, 0];
m1a2 = [max_width / -2, throat_depth / 2, inner_height / 2];
p1d2 = [max_width / 2, throat_depth / 2, inner_height / 2];
m2a3 = [close_width / -2, throat_depth, throat_height / 2];
p2d3 = [close_width / 2, throat_depth, throat_height / 2];
m3 = [point_width / -2, throat_depth + mouth_depth, mouth_height / 2];
p3 = [point_width / 2, throat_depth + mouth_depth, mouth_height / 2];
a1_base = [stem_width / -2, -base_thickness, 0];
d1_base = [stem_width / 2, -base_thickness, 0];
m1a2_base = [max_width / -2, throat_depth / 2, inner_height / 2 + base_top_thickness];
p1d2_base = [max_width / 2, throat_depth / 2, inner_height / 2 + base_top_thickness];
m2a3_base = [close_width / -2, throat_depth, throat_height / 2 + base_top_thickness_2];
p2d3_base = [close_width / 2, throat_depth, throat_height / 2 + base_top_thickness_2];
m3_base = [point_width / -2, throat_depth + mouth_depth, mouth_height / 2 + base_top_thickness_3];
p3_base = [point_width / 2, throat_depth + mouth_depth, mouth_height / 2 + base_top_thickness_3];

surface_1_outline = bezierSquare(a1,  m1a2, d1, p1d2);
surface_2_outline = bezierSquare(m1a2, m2a3, p1d2, p2d3);
surface_3_outline = bezierSquare(m2a3, m3, p2d3, p3);

surface_1_base_outline = bezierSquare(a1_base,  m1a2_base, d1_base, p1d2_base);
surface_2_base_outline = bezierSquare(m1a2_base, m2a3_base, p1d2_base, p2d3_base);
surface_3_base_outline = bezierSquare(m2a3_base, m3_base, p2d3_base, p3_base);

surface_1 = [
  surface_1_outline[0],
  pullLine(scaleLine(surface_1_outline[1], [1.5, 1, 1]), [0, 0, 3]),
  pullLine(scaleLine(surface_1_outline[2], [1.2, 1, 1]), [0, 0, 1]),
  surface_1_outline[3]
];

surface_1_base = [
  surface_1_base_outline[3],
  pullLine(scaleLine(surface_1_base_outline[2], [1.2, 1, 1]), [0, 0, 1]),
  pullLine(scaleLine(surface_1_base_outline[1], [1.5, 1, 1]), [0, 0, 3]),
  surface_1_base_outline[0]
];

surface_2_base = [
  surface_2_base_outline[3],
  pullLine(scaleLine(surface_2_base_outline[2], [1, 1, 1.2]), [0, 0, 0]),
  pullLine(scaleLine(surface_2_base_outline[1], [1, 1.05, 1.2]), [0, 0, 0]),
  surface_2_base_outline[0]
];

surface_3 = [
  surface_3_outline[0],
  pullLine(scaleLine(surface_3_outline[1], [1.1, 1, 1]), [0, 0, -3]),
  pullLine(scaleLine(surface_3_outline[2], [1, 1, 1]), [0, 0, -1]),
  [
    surface_3_outline[3][0],
    pull(surface_3_outline[3][1], [0, 2, 0]),
    pull(surface_3_outline[3][2], [0, 2, 0]),
    surface_3_outline[3][3]
  ]
];

surface_3_base = [
  surface_3_base_outline[0],
  pullLine(scaleLine(surface_3_base_outline[1], [1.1, 1, 1]), [0, 0, -3]),
  pullLine(scaleLine(surface_3_base_outline[2], [1, 1, 1]), [0, 0, -1]),
  [
    surface_3_base_outline[3][0],
    pull(surface_3_base_outline[3][1], [0, 2, 0]),
    pull(surface_3_base_outline[3][2], [0, 2, 0]),
    surface_3_base_outline[3][3]
  ]
];

surface_2_tied = tieHardBottom(surface_3, tieHardTop(surface_1, surface_2_outline));

surface_2 = [
  surface_2_tied[0],
  pullLine(surface_2_outline[1], [0, 0, 1]),
  surface_2_tied[2],
  surface_2_tied[3]
];

module poly(cp, samples=10) {
  points = flattenPoints(bezierSurfacePoints(cp, samples));
  faces = squareGridSurfaceFaces(samples);
  polyhedron(faces=faces, points=points);
}

function rotate_matrix(matrix) = 
  [for (i = [0:len(matrix[0]) - 1])
    [for (j = [0:len(matrix) - 1]) matrix[j][i]]
  ];

s1r = rotate_matrix(surface_1);
s1br = rotate_matrix(surface_1_base);
s2r = rotate_matrix(surface_2);
s2br = rotate_matrix(surface_2_base);
s3r = rotate_matrix(surface_3);
s3br = rotate_matrix(surface_3_base);

left_side = bezierSquare(
  s1br[0][3],
  s1br[0][0],
  s1r[0][0],
  s1r[0][3]
);

left_side_renderable = [
 s1br[0],
 left_side[1],
 left_side[1],
 s1r[0]
];
module clip_half() {
bezierSolid([
  surface_1,
  surface_1_base,
  flip(join(s1br[0], flip(s1r[0]))),
  join(s1br[3], flip(s1r[3])),
  surface_2,
  surface_2_base,
  flip(join(s2br[0], flip(s2r[0]))),
  join(s2br[3], flip(s2r[3])),
  surface_3,
  flip(surface_3_base),
  join(s3br[0], s3r[0]),
  flip(join(s3br[3], s3r[3])),
  join(surface_3_base[3], surface_3[3]),
  join(surface_1_base[3], surface_1[0]),
  mirrorMat(surface_1, [1, 1, -1]),
  mirrorMat(surface_1_base, [1, 1, -1]),
  mirrorMat(flip(join(s1br[0], flip(s1r[0]))), [1, 1, -1]),
  mirrorMat(join(s1br[3], flip(s1r[3])), [1, 1, -1]),
  mirrorMat(surface_2, [1, 1, -1]),
  mirrorMat(surface_2_base, [1, 1, -1]),
  mirrorMat(flip(join(s2br[0], flip(s2r[0]))), [1, 1, -1]),
  mirrorMat(join(s2br[3], flip(s2r[3])), [1, 1, -1]),
  mirrorMat(surface_3, [1, 1, -1]),
  mirrorMat(flip(surface_3_base), [1, 1, -1]),
  mirrorMat(join(s3br[0], s3r[0]), [1, 1, -1]),
  mirrorMat(flip(join(s3br[3], s3r[3])), [1, 1, -1]),
  mirrorMat(join(surface_3_base[3], surface_3[3]), [1, 1, -1]),
  mirrorMat(join(surface_1_base[3], surface_1[0]), [1, 1, -1])
]);
}

echo(mirrorMat(surface_2, [1, 1, -1]));
clip_half();
//mirror([0, 0, 1]) clip_half();
