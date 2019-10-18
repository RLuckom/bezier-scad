use <./lib/triangleBezier.scad>;


// UTILS
function pct_between(a, b, pct) = a + ((b - a) * (pct / 100.0));

function x_from_angle_height(angle, height) = cos(angle) * (height / sin(angle));

function x_from_points_y(a, b, y) = a[0] + (b[0] - a[0]) * ((y - a[1]) / (b[1] - a[1]));

function replace_index(array, indx, replacement) = 
  [for (i=[0:len(array) - 1]) i == indx ? replacement : array[i]];

function tieArrays(array1, array2) =
  [for (i = [0:len(array1) - 1]) tie(array1[i], array2[i])];


// BLADE PARAMS
blade_height_mm = 38;
blade_bottom_width_mm = 15;
blade_angle_deg = 70;
back_blade_angle_deg = 55;
back_blade_height_mm = 20;
blade_bottom_curve_pct = 10;
blade_top_curve_pct = 12;
blade_shoulder_height_mm = 8;
blade_thickness_0_mm = 0;
blade_thickness_1_mm = 0;
blade_thickness_2_mm = 8;
blade_thickness_3_mm = 0;
blade_thickness_top = 0;
edge_thickness_mm = 0.4;

// BLADE
// pct is 0-100.0
    
// inm_: intermediate

// x-position of blade tip
inm_blade_front_sweep_mm = x_from_angle_height(blade_angle_deg, blade_height_mm);
// x-position of blade back tip
inm_blade_back_sweep_mm = x_from_angle_height(back_blade_angle_deg, back_blade_height_mm) + blade_bottom_width_mm;

// y-position of blade back_tip
inm_blade_back_tip_height_mm = back_blade_height_mm + blade_shoulder_height_mm;

inm_p1_a = [0, 0, blade_thickness_0_mm];
inm_p1_d = [blade_bottom_width_mm, blade_shoulder_height_mm, blade_thickness_3_mm];
inm_p1_m = [inm_blade_front_sweep_mm, blade_height_mm, blade_thickness_top];
inm_p1_p =  [inm_blade_back_sweep_mm, inm_blade_back_tip_height_mm, blade_thickness_top];

inm_p1_b_natural = pct_between(inm_p1_a, inm_p1_d, 33.33);
inm_p1_n_natural = pct_between(inm_p1_m, inm_p1_p, 33.33);
inm_p1_b = replace_index(pct_between(inm_p1_b_natural, inm_p1_n_natural, blade_bottom_curve_pct), 2, blade_thickness_1_mm);
inm_p1_n = replace_index(pct_between(inm_p1_n_natural, inm_p1_b_natural, blade_top_curve_pct), 2, blade_thickness_top);


inm_p1_c_natural = pct_between(inm_p1_a, inm_p1_d, 66.66);
inm_p1_o_natural = pct_between(inm_p1_m, inm_p1_p, 66.66);
inm_p1_c_x = x_from_points_y(inm_p1_c_natural, inm_p1_o_natural, inm_p1_b[1]);
inm_p1_c = [inm_p1_c_x, inm_p1_b[1], blade_thickness_2_mm];
inm_p1_o_x = x_from_points_y(inm_p1_c_natural, inm_p1_o_natural, inm_p1_n[1]);
inm_p1_o = [inm_p1_o_x, inm_p1_n[1], blade_thickness_top];

inm_p1_e = pct_between(inm_p1_a, inm_p1_m, 33.33);
inm_p1_f = pct_between(inm_p1_b, inm_p1_n, 33.33);
inm_p1_g = pct_between(inm_p1_c, inm_p1_o, 33.33);
inm_p1_h = pct_between(inm_p1_d, inm_p1_p, 33.33);

inm_p1_i = pct_between(inm_p1_a, inm_p1_m, 66.66);
inm_p1_j = pct_between(inm_p1_b, inm_p1_n, 66.66);
inm_p1_k = pct_between(inm_p1_c, inm_p1_o, 66.66);
inm_p1_l = pct_between(inm_p1_d, inm_p1_p, 66.66);

inm_p1 = [
  [inm_p1_a, inm_p1_b, inm_p1_c, inm_p1_d],
  [inm_p1_e, inm_p1_f, inm_p1_g, inm_p1_h],
  [inm_p1_i, inm_p1_j, inm_p1_k, inm_p1_l],
  [inm_p1_m, inm_p1_n, inm_p1_o, inm_p1_p],
];

// HANDLE PARAMS
//
// pu: pull units--mm but the measurement refers
// to a non-corner control point location

handle_thickness_pu = 8;
nub_width_mm = 5;
nub_shoulder_pu = 10;
nub_inner_pu = 8;
p2_height_mm = 35;
thumb_rest_depth = 10;
front_handle_end_sweep = 0;
handle_length_mm = 120;
handle_width_mm = 20;
front_handle_end_sweep = 15;
back_handle_end_sweep = 10;
front_handle_middle_sweep_pu = 15;
back_handle_middle_sweep_pu = 20;

// HANDLE

inm_p2_a = [-nub_width_mm, -p2_height_mm, blade_thickness_0_mm];
inm_p2_d = [handle_width_mm, -p2_height_mm, blade_thickness_0_mm];
inm_p2_b = [pct_between(inm_p2_a, inm_p2_d, 33.33)[0], pct_between(inm_p2_a, inm_p2_d, 33.33)[1], handle_thickness_pu];
inm_p2_c = [pct_between(inm_p2_a, inm_p2_d, 66.66)[0], pct_between(inm_p2_a, inm_p2_d, 66.66)[1], handle_thickness_pu];
inm_p2_i = [nub_inner_pu - nub_width_mm, pct_between(inm_p1_a, inm_p2_a, 33.33)[1], blade_thickness_0_mm];
inm_p2_l = [blade_bottom_width_mm - thumb_rest_depth, pct_between(inm_p1_d, inm_p2_d, 50)[1], blade_thickness_0_mm];
inm_p2_j = [pct_between(inm_p2_i, inm_p2_l, 33.33)[0], pct_between(inm_p1_b, inm_p2_b, 33.33)[1], handle_thickness_pu];
inm_p2_k = [pct_between(inm_p2_i, inm_p2_l, 66.66)[0], pct_between(inm_p1_c, inm_p2_c, 33.33)[1], handle_thickness_pu];
inm_p2_e =[-nub_shoulder_pu, pct_between(inm_p1_a, inm_p2_a, 66.66)[1], blade_thickness_0_mm];
inm_p2_h = [blade_bottom_width_mm - thumb_rest_depth, pct_between(inm_p1_d, inm_p2_d, 50)[1], blade_thickness_0_mm];
inm_p2_f =[pct_between(inm_p2_e, inm_p2_h, 33.33)[0], pct_between(inm_p1_e, inm_p2_h, 33.33)[1], handle_thickness_pu];
inm_p2_g =[pct_between(inm_p2_e, inm_p2_h, 66.66)[0], pct_between(inm_p1_e, inm_p2_h, 66.66)[1], handle_thickness_pu];

inm_p2 = [
  [inm_p2_a, inm_p2_b, inm_p2_c, inm_p2_d],
  [inm_p2_e, inm_p2_f, inm_p2_g, inm_p2_h],
  [inm_p2_i, inm_p2_j, inm_p2_k, inm_p2_l],
  inm_p1[0]
];

inm_p3_a = [front_handle_end_sweep, -handle_length_mm, , blade_thickness_0_mm];
inm_p3_d = [handle_width_mm + back_handle_end_sweep, -handle_length_mm, blade_thickness_0_mm];
inm_p3_b = replace_index(pct_between(inm_p3_a, inm_p3_d, 33.3), 2, handle_thickness_pu);
inm_p3_c = replace_index(pct_between(inm_p3_a, inm_p3_d, 66.66), 2, handle_thickness_pu);

inm_p3_e = [front_handle_middle_sweep_pu, pct_between(inm_p2[0][0], inm_p3_a, 66.66)[1], blade_thickness_0_mm];
inm_p3_h = [handle_width_mm + back_handle_middle_sweep_pu, pct_between(inm_p2[0][3], inm_p3_d, 66.66)[1], blade_thickness_0_mm];
inm_p3_f = replace_index(pct_between(inm_p3_e, inm_p3_h, 33.3), 2, handle_thickness_pu);
inm_p3_g = replace_index(pct_between(inm_p3_e, inm_p3_h, 66.66), 2, handle_thickness_pu);

inm_p3 = [
  [inm_p3_a, inm_p3_b, inm_p3_c, inm_p3_d],
  [inm_p3_e, inm_p3_f, inm_p3_g, inm_p3_h],
  tieArrays(inm_p2[0], inm_p2[1]),
  inm_p2[0],
];

bottom_transition_height_mm = 10;
paddle_top_width_mm = 30;
paddle_bottom_width_mm = 30;
paddle_thickness_mm = 4;
paddle_back_bottom_pu = 12;
paddle_front_bottom_pu = 8;
paddle_back_top_pu = 4;
paddle_front_top_pu = 8;
paddle_height_mm = 30;

inm_p4_a = [front_handle_end_sweep, -handle_length_mm - bottom_transition_height_mm, blade_thickness_0_mm];
inm_p4_d = [front_handle_end_sweep + paddle_top_width_mm, -handle_length_mm - bottom_transition_height_mm, blade_thickness_0_mm];
inm_p4_b = replace_index(pct_between(inm_p4_a, inm_p4_d, 33.33), 2, paddle_thickness_mm);
inm_p4_c = replace_index(pct_between(inm_p4_a, inm_p4_d, 66.66), 2, paddle_thickness_mm);

inm_p4_e = pct_between(inm_p3_a, inm_p4_a, 66.66);
inm_p4_f = replace_index(pct_between(inm_p3_b, inm_p4_b, 66.66), 2, paddle_thickness_mm);
inm_p4_g = replace_index(pct_between(inm_p3_b, inm_p4_b, 66.66), 2, paddle_thickness_mm);
inm_p4_h = replace_index(pct_between(inm_p3_d, inm_p4_d, 66.66), 0, inm_p3_d[0]);

inm_p4_i = pct_between(inm_p3_a, inm_p4_e, 50);
inm_p4_j = pct_between(inm_p3_b, inm_p4_f, 50);
inm_p4_k = pct_between(inm_p3_c, inm_p4_g, 50);
inm_p4_l = pct_between(inm_p3_d, inm_p4_h, 50);

inm_p4 = [
  [inm_p4_a, inm_p4_b, inm_p4_c, inm_p4_d],
  [inm_p4_e, inm_p4_f, inm_p4_g, inm_p4_h],
  [inm_p4_i, inm_p4_j, inm_p4_k, inm_p4_l],
  inm_p3[0]
];

inm_paddle_top_y_mm = -handle_length_mm - bottom_transition_height_mm;
inm_paddle_bottom_y_mm = inm_paddle_top_y_mm - paddle_height_mm;

inm_p5_a = [front_handle_end_sweep, inm_paddle_bottom_y_mm, blade_thickness_0_mm];
inm_p5_d = [front_handle_end_sweep + paddle_bottom_width_mm, inm_paddle_bottom_y_mm, blade_thickness_0_mm];
inm_p5_b = pct_between(inm_p5_a, inm_p5_d, 33.33);
inm_p5_c = pct_between(inm_p5_a, inm_p5_d, 66.66);

inm_p5_e = [front_handle_end_sweep - paddle_back_bottom_pu, inm_paddle_bottom_y_mm, blade_thickness_0_mm];
inm_p5_h = [front_handle_end_sweep + paddle_bottom_width_mm + paddle_front_bottom_pu, inm_paddle_bottom_y_mm, blade_thickness_0_mm];
inm_p5_f = replace_index(pct_between(inm_p5_e, inm_p5_h, 0), 2, paddle_thickness_mm);
inm_p5_g = replace_index(pct_between(inm_p5_e, inm_p5_h, 100), 2, paddle_thickness_mm);
inm_p5_i = [front_handle_end_sweep - paddle_back_top_pu, pct_between(inm_p5_a, inm_p4_a, 66.66)[1], blade_thickness_0_mm];
inm_p5_l = [front_handle_end_sweep + paddle_top_width_mm + paddle_front_top_pu, inm_paddle_top_y_mm, blade_thickness_0_mm];
inm_p5_j = replace_index(pct_between(inm_p5_i, inm_p5_l, 0), 2, paddle_thickness_mm);
inm_p5_k = replace_index(pct_between(inm_p5_i, inm_p5_l, 100), 2, paddle_thickness_mm);

inm_p5 = [
  [inm_p5_a, inm_p5_b, inm_p5_c, inm_p5_d],
  [inm_p5_e, inm_p5_f, inm_p5_g, inm_p5_h],
  [inm_p5_i, inm_p5_j, inm_p5_k, inm_p5_l],
  inm_p4[0]
];


// ASSEMBLY
function y_mirrored_offset(control_points) = 
 reverseHandedness([for (ps =[for (pa=control_points) mirrorPointsArray([0, 0, 1], pa)]) [for (p=ps) [p[0], p[1], p[2] - edge_thickness_mm]]]);

echo(inm_p5[0]);
echo(inm_p5[1]);
echo(inm_p5[2]);
echo(inm_p5[3]);

bezierSurfaceFromTwoFaces(reverseHandedness(inm_p1), y_mirrored_offset(inm_p1), 20);
bezierSurfaceFromTwoFaces(reverseHandedness(inm_p2), y_mirrored_offset(inm_p2), 20);
bezierSurfaceFromTwoFaces(reverseHandedness(inm_p3), y_mirrored_offset(inm_p3), 20);
bezierSurfaceFromTwoFaces(reverseHandedness(inm_p4), y_mirrored_offset(inm_p4), 20);
bezierSurfaceFromTwoFaces(reverseHandedness(inm_p5), y_mirrored_offset(inm_p5), 20);
