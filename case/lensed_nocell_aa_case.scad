// 2x AA case for TritiLED V2.x

layout = "PRINTING";
//layout = "EXLODED";

function inch(x) = x * 25.4;

batt_d = 17+0.5;
batt_case_thickness = 17.5+0.5;
batt_case_width = 30+1;
batt_case_len = 58+1;
//batt_case_len = 5;
//pcb_d = 28+1;
pcb_d = 26;
pcb_h = 5;
pcb_thickness = 1.6;
wire_gap = 3;

lens_len = 14;

case_thickness = 2;
bottom_thickness = 4;

outer_d = batt_case_thickness + 2*case_thickness;
outer_thickness = batt_case_thickness + 2*case_thickness;
outer_width = batt_case_width + 2 * case_thickness;
outer_len = bottom_thickness + batt_case_len + case_thickness +
  wire_gap + pcb_thickness + lens_len;
top_len = pcb_h + wire_gap + lens_len;
top_d = pcb_d + 2*case_thickness + 6;

echo(outer_d);
echo(outer_width);

cap_len = 5.5;
cap_hole_d1 = 18;
cap_hole_d2 = 31;

bevel_height = 2;

epsilon = 0.1;

module lens(){
  cylinder(d1 = 21,
           d2 = 22,
           h =14);
}


module chanzon_3W_LED()
{
  dome_d = 5;
  base_d = 7;
  base_h = 2;
  chip_size = 1.8;
  chip_thickness = 0.5;
  base_thickness = 1;
  difference(){
    color("white") cylinder($fn=23, d = base_d, h = base_h);
    translate([0, 0, base_thickness]){
      cylinder($fn=23, d = dome_d, h = base_h);
    }
  }
  translate([0, 0, base_h]){
    %sphere($fn=23, d = dome_d);
  }
  translate([-chip_size/2, -chip_size/2, base_thickness]){
    color("cyan") cube([chip_size, chip_size, chip_thickness]);
  }
}

module tritiled_nocell_pcb()
{
  length = inch(0.95);
  width = inch(0.625);
  corner_r = inch(0.125);

  rotate([0, 0, 90])
  color("purple"){
    hull(){
      translate([-length/2 + corner_r, -width/2 + corner_r, 0]){
        cylinder(r = corner_r, h = pcb_thickness);
      }
      translate([-length/2 + corner_r, +width/2 - corner_r, 0]){
        cylinder(r = corner_r, h = pcb_thickness);
      }
      translate([+length/2 - corner_r, -width/2 + corner_r, 0]){
        cylinder(r = corner_r, h = pcb_thickness);
      }
      translate([+length/2 - corner_r, +width/2 - corner_r, 0]){
        cylinder(r = corner_r, h = pcb_thickness);
      }      
    }
  }
  translate([0, 0, pcb_thickness]){
    chanzon_3W_LED();
  }
}


module pcb_clearance(len = pcb_thickness, tolerance = 0, chamfer = 0)
{
  cylinder(d1 = pcb_d - tolerance - chamfer,
           d2 = pcb_d - tolerance,
           h = chamfer);
  translate([0, 0, chamfer]){
    cylinder(d = pcb_d - tolerance, h = len - chamfer);
  }
}

module batt_case(len = batt_case_len, tolerance = 0, chamfer = 0)
{

  translate([-(batt_case_thickness-tolerance)/2, -batt_case_width/2 + batt_d/2, -epsilon]){
    cube ([batt_case_thickness - tolerance, batt_case_width - batt_d, len+2*epsilon]);
  }


  translate([0, -batt_case_width/2 + batt_d/2, 0]){
    cylinder(d1 = batt_d - tolerance - chamfer,
             d2 = batt_d - tolerance,
             h = chamfer);
  }
  translate([0, -batt_case_width/2 + batt_d/2, chamfer]){
    cylinder(d = batt_d - tolerance, h = len - chamfer);
  }


  translate([0, +batt_case_width/2 - batt_d/2, 0]){
    cylinder(d1 = batt_d - tolerance - chamfer,
             d2 = batt_d - tolerance,
             h = chamfer);
  }
  translate([0, +batt_case_width/2 - batt_d/2, chamfer]){
    cylinder(d = batt_d - tolerance, h = len-chamfer);
  }
}

module battery_cap()
{
  thickness = 2;
  difference(){
    batt_case(len = thickness, tolerance = 1, chamfer = 0);
    translate([3.6, -3, -2*epsilon]){
      cube ([5, 6, thickness + 4 * epsilon]);
    }
  }
}

module cap()
{
  difference(){
    chamfer = 0.5;
    union(){
      rotate([0, 0, 0]){
        translate([0, 0, chamfer]){
          cylinder($fn = 12,
                   d = top_d,
                   h = cap_len - bevel_height - chamfer);
        }
        cylinder($fn = 12,
                 d1 = top_d - 2*chamfer,
                 d2 = top_d,
                 h = chamfer);
      }
      translate([0, 0, cap_len - bevel_height]){
        rotate([0, 0, 0]){
          cylinder($fn = 12,
                   d1 = top_d,
                   d2 = top_d - 2 * bevel_height,
                   h = bevel_height + 0.75);
        }
      }
    }

    translate([0, 0, -epsilon]){
      cylinder(d = cap_hole_d1,
               h = cap_len + 2*epsilon);
    }

    translate([0, 0, 2]){
      cylinder($fn = 12,
               d2 = cap_hole_d2,
               d1 = cap_hole_d1,
               h = cap_len + epsilon);
    }
    

    N = 6;
    screw_ring_d = (top_d + pcb_d)/2;
    screw_clearance_d = 4.5;
    screw_sink = 2.1;
    pilot_d = 2;
    for (th = [0:N]){
      translate([screw_ring_d/2 * cos(360*th/N + 0),
                 screw_ring_d/2 * sin(360*th/N + 0),
                 0]){
        translate([0, 0, -epsilon]){
          cylinder(d = pilot_d, h = cap_len + 2*epsilon);
        }
        translate([0, 0, cap_len - screw_sink]){
          rotate([0, 0, 360*th/N]){
            hull(){
              cylinder($fn=12, d = screw_clearance_d, h = cap_len);
              translate([4, 0, 0])
              cylinder($fn=12, d = screw_clearance_d, h = cap_len);
              translate([-4, 0, 0])
              cylinder($fn=12, d = screw_clearance_d, h = cap_len);
            }
          }
        }
      }
    }
  }
}

module lens_holder()
{
  len = lens_len;
  chamfer = 1.5;
  difference(){
    union(){
      batt_case(len, tolerance = 0.5, chamfer = chamfer);
      pcb_clearance(len, tolerance = 0.5, chamfer = chamfer);
    }

    cylinder(d1 = 21.25,
             d2 = 22.25,
             h = 14);

    translate([0, 0, -1]){
      cylinder(d1 = 21.25,
               d2 = 22.25,
               h = 14);
    }

    translate([0, 0, 1]){
      cylinder(d1 = 21.25,
               d2 = 22.25,
               h = 14);
    }

  }
}

module bottom()
{
  difference(){
    union(){
      hull(){
        translate([0, -outer_width/2 + outer_d/2, bevel_height]){
          cylinder($fn = 36, d = outer_d, h = outer_len - bevel_height);
        }
        translate([0, +outer_width/2 - outer_d/2, bevel_height]){
          cylinder($fn = 36, d = outer_d, h = outer_len - bevel_height);
        }
      }

      hull(){
        translate([0, -outer_width/2 + outer_d/2, 0]){
          cylinder($fn = 36,
                   d1 = outer_d - 2*bevel_height,
                   d2 = outer_d,
                   h = bevel_height);
        }
        
        translate([0, +outer_width/2 - outer_d/2, 0]){
          cylinder($fn = 36,
                   d1 = outer_d - 2*bevel_height,
                   d2 = outer_d,
                   h = bevel_height);
        }
      }


      translate([0, 0, outer_len - top_len]){
        rotate([0, 0, 0*15]){
          cylinder($fn = 12,
                   d = top_d,
                   h = top_len);
        }
      }

      translate([0, 0, 0]){
        rotate([0, 0, 0*15]){
          cylinder($fn = 12,
                   d1 = 0,
                   d2 = top_d,
                   h = outer_len - top_len);
        }
      }
    }

    N = 6;
    screw_ring_d = (top_d + pcb_d)/2;
    pilot_d = 2;
    for (th = [0:N]){
      translate([screw_ring_d/2 * cos(360*th/N + 0*15),
                 screw_ring_d/2 * sin(360*th/N + 0*15),
                 outer_len - top_len + case_thickness]){
        rotate([0, 0, 360*th/N + 0*15]){
          cylinder($fn=3, d = pilot_d, h = top_len);
        }
      }
    }

    
    translate([0, 0, bottom_thickness]){
      batt_case(batt_case_len + wire_gap + top_len + bottom_thickness);
    }

    translate([0, 0, batt_case_len + wire_gap + case_thickness]){
      pcb_clearance(len = top_len);
    }
  }
}



if (layout == "PRINTING"){

  bottom();

  translate([20, -30, 0]){
    battery_cap();
  }


  translate([40, 0, 0]){
    cap();
  }

  translate([20, 30, 0]){
    lens_holder();
  }
} else {

  translate([-50, 0, 0])
  rotate([0, 90, 0]){
    %bottom();
    
    ex = 0.4;
    translate([0, 0, 5 + 50 * ex]){
      color("blue") batt_case();
    }

    translate([0, 0, 64 + 60 * ex]){
      color("black") battery_cap();
    }

    translate([0, 0, 67 + 60 * ex]){
      tritiled_nocell_pcb();
    }

    translate([0, 0, 69 + 70 * ex]){
      color("black") lens();
    }

    translate([0, 0, 69 + 90 * ex]){
      color("gray") lens_holder();
    }

    translate([0, 0, 83.5 + 110 * ex]){
      rotate([0, 0, 0*15]){
        cap();
      }
    }

  }
}
