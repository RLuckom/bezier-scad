RADIUS = 30;
CENTER_TO_CENTER_RATIO = 1.6;
FACETS = 200;
THICKNESS = 1;
CENTER_DIST = RADIUS * CENTER_TO_CENTER_RATIO;
INNER_RADIUS = 25;
INNER_CENTER_TO_CENTER_RATIO = 1.3;
INNER_CENTER_DIST = INNER_RADIUS * INNER_CENTER_TO_CENTER_RATIO;

module section() {
difference() {
    difference() {
      cylinder(THICKNESS, r=RADIUS, $fn=FACETS);
      rotate([0, 0, 120]) translate([CENTER_DIST, 0, -2]) cylinder(THICKNESS + 4, r=RADIUS, $fn=FACETS);
      rotate([0, 0, 240]) translate([CENTER_DIST, 0, -2]) cylinder(THICKNESS + 4, r=RADIUS, $fn=FACETS);
      translate([CENTER_DIST, 0, -2]) cylinder(THICKNESS + 4, r=RADIUS, $fn=FACETS);
    }
    #translate([0, 0, -2]) difference() {
      cylinder(THICKNESS + 4, r=INNER_RADIUS, $fn=FACETS);
      rotate([0, 0, 120]) translate([INNER_CENTER_DIST, 0, -2]) cylinder(THICKNESS + 8, r=INNER_RADIUS, $fn=FACETS);
      rotate([0, 0, 240]) translate([INNER_CENTER_DIST, 0, -2]) cylinder(THICKNESS + 8, r=INNER_RADIUS, $fn=FACETS);
      translate([INNER_CENTER_DIST, 0, -2]) cylinder(THICKNESS + 8, r=INNER_RADIUS, $fn=FACETS);
    }
  }
}

section();
translate([-CENTER_DIST, 0, 0]) section();
translate([CENTER_DIST, 0, 0]) section();
