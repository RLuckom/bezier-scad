u = 11.2;
p = 12;
h = 0.1 * p;
tenon_to_p = .33;
OVERLAP = 0.1;
OVER_HEIGHT = p * 3;
UNDER_HEIGHT = -p;
BACK_HEIGHT = -p;
center_tenon_thickness = tenon_to_p * p;
side_tenon_thickness = (1 - tenon_to_p) / 2 * p;
unit_length = 11;
length = unit_length * u;
z_scale = 1.25;
height = z_scale * p;
sphere_size = 1.5;
peg_dia_to_u = 0.4;
peg_r = peg_dia_to_u * u / 2;
peg_scale = 2.3;
expected_layer_height = 1;
end_curve_to_unit_length = 0.28;
end_curve_belly = end_curve_to_unit_length * unit_length;

function fnFromRadius(r) = (r / expected_layer_height) * 4;


function radFromChordHeight(chordLength, chordHeight) = (((chordLength * chordLength) / (chordHeight * 8))) + (chordHeight / 2);

rad = radFromChordHeight(u, h);
post_reference_location = [u / 2, -BACK_HEIGHT, 0];
post_back_reference_location = [length - (u / 2), -BACK_HEIGHT, 0];
echo(rad);
end_curve_rad = radFromChordHeight(height, end_curve_belly);

module lock_scale() {
    scale([1, 1, z_scale]) children();
}

module post_orientation() {
    rotate([0, 90, 0]) children();
}

module peg_orientation() {
    rotate([90, 0, 0]) children();
}

module post() {
  difference() {
      union() {
    lock_scale() post_orientation() cylinder(length, d=p, $fn=fnFromRadius(p / 2));
          translate([length, center_tenon_thickness / 2, 0]) round_end();
      }
          translate([u / 2, (rad + p / 2) - h, UNDER_HEIGHT]) cylinder(abs(UNDER_HEIGHT) * 2, r=rad, $fn=fnFromRadius(rad));
    translate([u / 2, -(rad + p / 2) + h, UNDER_HEIGHT]) cylinder(abs(UNDER_HEIGHT) * 2, r=rad, $fn=fnFromRadius(rad));
    for (i=[0:unit_length - 1]) {
        translate([i * u, 0, height / 2]) #sphere(sphere_size, $fn=fnFromRadius(sphere_size));
    }
  }
}

module tenoned_post() {
    difference() {
        post();
        #translate([-OVERLAP, -0.5 * p * tenon_to_p, -OVER_HEIGHT / 2]) center_block();
        translate([OVERLAP + length - u, center_tenon_thickness / 2, UNDER_HEIGHT]) side_block();
        translate([OVERLAP + length - u, - (center_tenon_thickness / 2 + side_tenon_thickness), UNDER_HEIGHT]) side_block();
    }
}

module peg() {
    intersection() {
        post();
        translate(post_reference_location) peg_stock();
    }
}
  
module round_end() {
    rotate([90, 0, 0]) cylinder(center_tenon_thickness, r=end_curve_rad);
}

module center_block() {
    union() {
    cube([u + OVERLAP, center_tenon_thickness, OVER_HEIGHT]);
        #translate([u + OVERLAP, center_tenon_thickness, OVER_HEIGHT / 2]) 
        round_end();
    }
}

module side_block() {
    cube([u + OVERLAP, side_tenon_thickness, OVER_HEIGHT]);
}

module peg_translation() {
    translate([-peg_r * peg_scale / 2, -peg_r / 2]) children();
}

module peg_stock(length=0) {
    lock_scale() peg_orientation() peg_translation() cube([peg_r * peg_scale, peg_r, length == 0 ? abs(BACK_HEIGHT) * 2 : length]);
}

module handle() {
difference() {
    tenoned_post();
    #translate(post_reference_location) peg_stock();
    #translate(post_back_reference_location) peg_stock();
}
}

handle();
//center_block();