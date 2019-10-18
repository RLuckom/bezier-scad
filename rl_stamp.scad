use <./lib/bezier.scad>
use <./lib/screws.scad>


halfRPoints = [
[0, 0, 0],
[4.5, 0, 0],
[1, 4, 0],
[0, 5, 0],
];
backHalfRPoints = [
[0, 5, 0],
[-4.5, 5, 0],
[-1, 1, 0],
[0, 0, 0],
];

bladePoints = [
[2.1, -3.5, 0],
[2, -3, 0],
[-3, -2, 0],
[-4, -0.5, 0],
[0, 0, 0],
[4, 0.5, 0],
[3, 2, 0],
[-2, 3, 0],
[-2.1, 3.5, 0],
];

lPoints = [
[0, 4, 0],
[2, 3.7, 0],
[4.25, 3, 0],
[4.25, 2, 0],
[0, 3, 0],
[0, 0, 0],
[0, -6, 0],
];

forwardLPoints = [for (p=lPoints) p * -1];

module wedge(points, degrees, $fn=20) { 
hull() {
    bezier(points, $fn, 0.1) sphere(0.1, $fn=$fn);
    rotate([0, degrees, 0]) bezier(points, $fn, 0.1) sphere(0.1, $fn=$fn);
}
}
wedge(halfRPoints, 35);
translate([0, -5, 0]) wedge(backHalfRPoints, -35);
translate([-3.6, 2, 0]) wedge(lPoints, 35);
translate([3.6, -2, 0]) wedge(forwardLPoints, -35);
rotate([0, 0, 30]) scale([1, 1.2, 1]) difference() {
    translate([0, 0, 20]) cylinder(40, r=7, center=true, $fn=55);
    for (x=[0:10:360]) {
        rotate([0, 0, x]) translate([6.4, 0, 0]) scale([1, 1, 2]) sphere(0.4, $fn=20);
    }
}


//translate([0, 0, -21]) scale([1.5, 1.2, 1]) cylinder(40, r=4, center=true);