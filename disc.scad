use <./lib/triangleBezier.scad>;

dec = radiusTriangle(30, 36);
top_dec = flipTriangleControlPoints(interpolatedControlPoints([0, 0, 3], dec[6], dec[9]));
side_1 = interpolatedControlPoints(top_dec[0], dec[0], dec[6]);
side_2 = interpolatedControlPoints(top_dec[0], dec[0], dec[9]);

function z_vals(t, zvals) = 
  [
    repz(t[0], zvals[0]),
    repz(t[1], zvals[1]),
    repz(t[2], zvals[1]),
    repz(t[3], zvals[2]),
    repz(t[4], zvals[2]),
    repz(t[5], zvals[2]),
    repz(t[6], zvals[3]),
    repz(t[7], zvals[3]),
    repz(t[8], zvals[3]),
    repz(t[9], zvals[3])
  ];


function repz(p, val) = rep(p, 2, val);

function rep(p, indx, v) = [for (i=[0:len(p) - 1]) i == indx ? v : p[i]];

upper_z_vals = [1, 0, 0, 19];
lower_z_vals = [-1, -2, -2, 19];

upper = flipTriangleControlPoints(z_vals(dec, upper_z_vals));
lower = z_vals(dec, lower_z_vals);

bowl_faces = multipleTriangleFaces(4, 20);
bowl_points = flattenPoints([for (n=[0:10]) multipleCubicTriangleSurfacePoints([rotatePointArray([0, 0, n * 36], upper), rotatePointArray([0, 0, n * 36], lower)], 4)]);

polyhedron(points=bowl_points, faces=bowl_faces);
