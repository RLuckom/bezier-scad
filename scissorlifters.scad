use <./lib/bezier.scad>
use <./lib/screws.scad>


bladePoints = [
[0, 0, 0],
[1, 0.5, 0],
[2, 0.5, 0],
[4, 4, 0],
[0, 8, 0]];

thumbHandlePoints = [
  bladePoints[0],
  bladePoints[1] * -1,
  [-0.5, -1, 0],
  [ -0.5, -2, 0],
  [-2, -1.5, 0],
  [-2.6, -.35, 0],
  [-0.4, -0.25, 0]
];

fingerHandlePoints = [
  bladePoints[0],
  bladePoints[1] * -1,
  [-1, -2, 0],
  [ -1, -3, 0],
  [-2, -2.5, 0],
  [-3, -1, 0],
   [-1.5, 0, 0],
  [-0.35, -0.25, 0]
];
module bottom() {
rotate([0, 0, 25]) {
    difference() {
        union() {
           cylinder(0.4, r=0.3, $fn=25);

hull() bezier([for (p = bladePoints) p + [0, 0, 0]], 40, 0) sphere(0.02, $fn=20);
bezier([for (p = bladePoints) p + [0, 0, 0.1]], 40, 0) scale([1, 1, 1.5]) sphere(0.2, $fn=20);
} 
            bezier([for (p = bladePoints) p + [-2.5, -2.5, -0.6]], 40, 0) cube([5, 5, 0.6]);
}
difference() {
translate([0, 0, 0.25]) bezier([for (p = thumbHandlePoints) p + [0, 0, 0.1]], 40, 0) scale([0.45, 0.45, 1]) sphere(0.2, $fn=20);
                    translate([0, 0, .4]) cylinder(0.65, r=0.5, $fn=25);
}
}
}

module top() {
rotate([0, 0, -25]) {
    mirror([1, 0, 0]) {
       translate([0, 0, 0.3]) 
        difference() {
            union() {
                translate([0, 0, 0]) cylinder(0.3, r=0.3, $fn=25);
            bezier([for (p = bladePoints) p + [0, 0, 0.15]], 40, 0) sphere(0.2, $fn=20);
            }
            bezier([for (p = bladePoints) p + [-2.5, -2.5, -0.1]], 40, 0) cube([5, 5, 0.2]);
            translate([0, 0, .3]) bezier([for (p = bladePoints) p + [-2.5, -2.5, -0]], 40, 0) cube([5, 5, 0.2]);
            }
             difference() {
            translate([0, 0, 0.25]) bezier([for (p = fingerHandlePoints) p + [0, 0, 0.1]], 40, 0) scale([0.45, 0.45, 1]) sphere(0.2, $fn=20);
                cylinder(0.4, r=0.5, $fn=25);
        }

        }
    }
}

scale_factor = [27, 27, 27];
module full_size_top() {
    difference() {
scale(scale_factor) top();
    screw_assembly();

        }
}

module full_size_bottom() {
difference() {
scale(scale_factor) bottom();
    screw_assembly();
}
}

module screw_assembly() {
    #translate([0, 0, .61 * 25.4 + 2.54]) rotate([0, 180, 0]) screw_recess(0.6);
    #hex_nut(3.11);
}
translate([45, 8, 16]) rotate([0, 180, 0]) full_size_top();
full_size_bottom();