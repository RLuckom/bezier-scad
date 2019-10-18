SCREW_SHAFT_DIA = 4.3;
SCREW_HEAD_HEIGHT = 2.54;
SCREW_HEAD_DIA = 7.9;
NUT_FLAT_TO_FLAT = 8.52;
NUT_POINT_TO_POINT = 9.68;
NUT_THICKNESS = 3.11;
FN = 60;
SCREW_OUTLINE_SCALE_FACTOR = 1.1;
NUT_SCALE_FACTOR = 1.06;
NYLON_NUT_SCALE_FACTOR = 1.02;
NUT_HEIGHT_SCALE_FACTOR = 1.1;

module rounded_cube(h, w, d, diag=3) {
    difference() {
        cube([h, w, d]);
        rounded_cube_bezel(h, w, d, diag);
    }
}

module rounded_cube_bezel(h, w, d, diag=3) {
    translate([0, w, 0]) face_bezel(w, d, diag);
    side = sqrt(diag * diag / 2);
    translate([h, w, 0]) rotate([0, 270, 0]) face_bezel(w, h, diag);
    translate([h, w, d]) rotate([0, -180, 0]) face_bezel(w, d, diag);;
    translate([0, w, d]) rotate([0, 90, 0]) face_bezel(w, h, diag);
}

module face_bezel(d1, d2, diag=3) {
    side = sqrt(diag * diag / 2);
    translate([side, 0, side]) rotate([90, 180, 0]) bezel_cutout(d1, diag);
    translate([side, -d1, (d2 - side)]) rotate([270, 180, 0]) bezel_cutout(d1, diag);
    translate([side, -side, d2]) rotate([0, 180, 0]) bezel_cutout(d2, diag);
    translate([side, -(d1 - side), d2]) rotate([0, 180, 90]) bezel_cutout(d2, diag);
}

module bezel_cutout(length, diag) {
    side = sqrt(diag * diag / 2);
    linear_extrude(length) {
      bezel_shape(side);
  }
}

module bezel_shape(side) {
      difference() {
        square(side, false);
        circle(side, $fn=40);
      }
  }

module screw(shaft_length_in) {
    shaft_length = (25.4 * shaft_length_in) + 1;
    union() {
    cylinder(SCREW_HEAD_HEIGHT, d=SCREW_HEAD_DIA, $fn=FN);
    translate([0, 0, SCREW_HEAD_HEIGHT - 1]) cylinder(shaft_length, d=SCREW_SHAFT_DIA + 0.5, $fn=FN);
    }
}

module nylon_screw(shaft_length_in) {
    shaft_length = (25.4 * shaft_length_in) + 1;
    union() {
    cylinder(SCREW_HEAD_HEIGHT, d=SCREW_HEAD_DIA, $fn=FN);
    translate([0, 0, SCREW_HEAD_HEIGHT - 1]) cylinder(shaft_length, d=SCREW_SHAFT_DIA + 0.3, $fn=FN);
    }
}

module hex_nut() {
    cylinder(NUT_THICKNESS * NUT_SCALE_FACTOR, d=NUT_POINT_TO_POINT * NUT_SCALE_FACTOR, $fn=6);
}

module nylon_hex_nut() {
    cylinder(NUT_THICKNESS * NYLON_NUT_SCALE_FACTOR, d=NUT_POINT_TO_POINT * NYLON_NUT_SCALE_FACTOR, $fn=6);
}

module hex_nut_pocket(depth) {
    rounded_cube(depth, NUT_FLAT_TO_FLAT * NUT_HEIGHT_SCALE_FACTOR, NUT_THICKNESS* NUT_SCALE_FACTOR);
}

module screw_recess(shaft_length_in) {
    scale([SCREW_OUTLINE_SCALE_FACTOR, SCREW_OUTLINE_SCALE_FACTOR, 1]) screw(shaft_length_in);
}
