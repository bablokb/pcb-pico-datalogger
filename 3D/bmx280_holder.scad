// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD): enclosure for sensor+i2c-adapter.
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-bmx280-i2c-adapter
// ---------------------------------------------------------------------------

include <dimensions.scad>
include <BOSL2/std.scad>

// dimensions   ----------------------------------------------------------------

bmx280_x_pcb   = 20.0;
bmx280_y_pcb   = 34.0;
bmx280_z_pcb   = 1.6;
xo_screw = 2.525;
yo_screw = 3.45;
r_screw  = 1.50; 

bmx280_x_support = 5.60;           // support (for solder joints at the back)
bmx280_y_support = bmx280_x_support;
bmx280_z_support = b + 2.00;

z1_bot  = bmx280_z_support + bmx280_z_pcb;        // wall with 4 perimeters from bottom
z2_bot  = z1_bot + 4.5;             // wall with 2 perimeters from bottom
z2_top  = b + 4.5;                  // wall with 2 perimeters from top

yb_sensor = 11.20;                             // distance sensor to bottom
yt_sensor = 10.50;                             // distance sensor to top
bmx280_y_sensor  = bmx280_y_pcb - yb_sensor - yt_sensor;

bmx280_x_stemma = 8.0;
bmx280_y_stemma = 5.5;
bmx280_z_stemma = 3.2;

bmx280_x_grove = 10;
bmx280_z_grove = 0;      // TBD

bmx280_x_case = bmx280_x_pcb + 2*gap + 2*w4;
bmx280_y_case = bmx280_y_pcb + 2*gap + 2*w4;

bmx280_d_screw = 4.5;    // enclosure screw

// --- supports   --------------------------------------------------------------

module supports() {
  x = bmx280_x_support + w4 + gap;
  y = bmx280_y_support + w4 + gap;
  bmx280_x_off = bmx280_x_case/2-x/2;
  bmx280_y_off = bmx280_y_case/2-y/2;
  move([-bmx280_x_off,-bmx280_y_off,0]) cuboid([x,y,bmx280_z_support],anchor=BOTTOM+CENTER);
  move([-bmx280_x_off,+bmx280_y_off,0]) cuboid([x,y,bmx280_z_support],anchor=BOTTOM+CENTER);
  move([+bmx280_x_off,-bmx280_y_off,0]) cuboid([x,y,bmx280_z_support],anchor=BOTTOM+CENTER);
  move([+bmx280_x_off,+bmx280_y_off,0]) cuboid([x,y,bmx280_z_support],anchor=BOTTOM+CENTER);
}

// --- screws   ----------------------------------------------------------------

module screws() {
  bmx280_x_off = bmx280_x_pcb/2-xo_screw;
  bmx280_y_off = bmx280_y_pcb/2-yo_screw;
  r     = r_screw - 2*gap;
  move([-bmx280_x_off,-bmx280_y_off,bmx280_z_support-fuzz]) cyl(r=r,h=bmx280_z_pcb,anchor=BOTTOM+CENTER);
  move([-bmx280_x_off,+bmx280_y_off,bmx280_z_support-fuzz]) cyl(r=r,h=bmx280_z_pcb,anchor=BOTTOM+CENTER);
  move([+bmx280_x_off,-bmx280_y_off,bmx280_z_support-fuzz]) cyl(r=r,h=bmx280_z_pcb,anchor=BOTTOM+CENTER);
  move([+bmx280_x_off,+bmx280_y_off,bmx280_z_support-fuzz]) cyl(r=r,h=bmx280_z_pcb,anchor=BOTTOM+CENTER);
}

// --- bottom part   -----------------------------------------------------------

module bmx280_bottom() {
  difference() {
    union() {
      // base plate
      cuboid([bmx280_x_case,bmx280_y_case,b],anchor=BOTTOM+CENTER);
      // suport and screws
      supports();
      screws();
      // walls around sensor
      rect_tube(size=[bmx280_x_case,bmx280_y_case],wall=w4,h=z1_bot,anchor=BOTTOM+CENTER);
      rect_tube(size=[bmx280_x_case,bmx280_y_case],wall=w2,h=z2_bot,anchor=BOTTOM+CENTER);
    }
    // cutouts Stemma
    move([0,-bmx280_y_case/2+w4/2,z1_bot])
                 cuboid([bmx280_x_stemma,2*w4,z2_bot-b+fuzz],anchor=BOTTOM+CENTER);
    move([0,+bmx280_y_case/2-w4/2,z1_bot])
                 cuboid([bmx280_x_stemma,2*w4,z2_bot-b+fuzz],anchor=BOTTOM+CENTER);
    // cutout screw
    move([0,bmx280_y_pcb/2-bmx280_y_support/2,-fuzz]) cyl(d=bmx280_d_screw,h=b+2*fuzz,anchor=BOTTOM+CENTER);
  }
}

// --- top part   --------------------------------------------------------------

module bmx280_top() {
  difference() {
    union() {
      // base plate
      cuboid([bmx280_x_case,bmx280_y_case,b],anchor=BOTTOM+CENTER);
      // walls around sensor
      rect_tube(size=[bmx280_x_case-2*w2,bmx280_y_case-2*w2],
                wall=w4,h=z2_top,anchor=BOTTOM+CENTER);
      // walls around Stemma
      move([0,-bmx280_y_case/2+bmx280_y_stemma/2+w4+w2-fuzz,0])
        rect_tube(size=[bmx280_x_stemma+2*w2,bmx280_y_stemma+2*w2],
                  wall=w2,h=z2_top,anchor=BOTTOM+CENTER);
      move([0,+bmx280_y_case/2-bmx280_y_stemma/2-w4-w2+fuzz,0])
        rect_tube(size=[bmx280_x_stemma+2*w2,bmx280_y_stemma+2*w2],
                  wall=w2,h=z2_top,anchor=BOTTOM+CENTER);
    }
    // cutouts Stemma
    move([0,-bmx280_y_case/2+1.5*w2+bmx280_y_stemma/2-fuzz,-fuzz])
          cuboid([bmx280_x_stemma,3*w2+bmx280_y_stemma,z2_top+bmx280_z_pcb-b+2*fuzz],anchor=BOTTOM+CENTER);
    move([0,+bmx280_y_case/2-1.5*w2-bmx280_y_stemma/2+fuzz,-fuzz])
          cuboid([bmx280_x_stemma,3*w2+bmx280_y_stemma,z2_top+bmx280_z_pcb-b+2*fuzz],anchor=BOTTOM+CENTER);
    // cutouts ventilation
    move([0,0,-fuzz]) cuboid([bmx280_x_pcb/2,w4,b+2*fuzz],anchor=BOTTOM+CENTER);
    move([0,3*w4,-fuzz]) cuboid([bmx280_x_pcb/2,w4,b+2*fuzz],anchor=BOTTOM+CENTER);
    move([0,-3*w4,-fuzz]) cuboid([bmx280_x_pcb/2,w4,b+2*fuzz],anchor=BOTTOM+CENTER);
  }
}

// --- top-level object   ----------------------------------------------------

//bmx280_bottom();
//bmx280_top();
