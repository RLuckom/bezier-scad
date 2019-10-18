mirror([1, 0, 0]) scale([20, 20, 1]) linear_extrude(height = 3.5,  convexity = 10)
   import (file = "/input/img/outfile.dxf");
   
   translate([-16,13,0]) difference() {
       scale([0.9, 1, 1]) cylinder(7, r=28, $fn=90);
       scale([0.9, 1, 1]) translate([0, 0, 1]) cylinder(7, r=25, $fn=90);
   }
   