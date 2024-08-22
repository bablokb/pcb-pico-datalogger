// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) case (bottom) for datalogger.
//
// Case for the M5-Stack CO2-sensor.
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// ---------------------------------------------------------------------------

include <dimensions.scad>
include <BOSL2/std.scad>

TEST = false;

// dimensions M5-Stack CO2-sensor   --------------------------------------------

b_m5 = 0.8;
x_m5 = 24+2*w2;
y_m5 = 48+2*w2;
z_m5 = TEST ? 4: 8.2;
r_m5 = 3;
x_grove = 10;
zoff_grove = 2;

// --- M5-holder   -------------------------------------------------------------

module m5_holder() {
  cuboid([x_m5,y_m5,b_m5],anchor=BOTTOM+CENTER,
               rounding=r_m5,edges="Z");
  zmove(b_m5-fuzz) difference() {
     // wall around sensor
     rect_tube(size=[x_m5,y_m5],wall=w2,h=z_m5,anchor=BOTTOM+CENTER,
               rounding=r_m5,irounding=r_m5);
     // cutout for Grove
     translate([0,+y_m5/2,zoff_grove])
         cuboid([x_grove,2*w2+2*fuzz,z_m5+2*fuzz],anchor=BOTTOM+CENTER);
   }
}

// --- top-level object   ----------------------------------------------------

m5_holder();
