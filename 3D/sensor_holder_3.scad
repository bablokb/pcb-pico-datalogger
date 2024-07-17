// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) case (bottom) for datalogger.
//
// Sensor-holder for the back of the printed case.
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// ---------------------------------------------------------------------------

include <dimensions.scad>
include <dimensions_top.scad>
include <dimensions_bottom.scad>
include <dimensions_foot.scad>
include <shared_modules.scad>
include <BOSL2/std.scad>

// dimensions M5-Stack CO2-sensor   --------------------------------------------

x_m5 = 24+2*w2;
y_m5 = 48+2*w2;
z_m5 = 10;
x_grove = 10;

// dimensions base-plate   -----------------------------------------------------

o_plate = 10;
x_plate = ysize+2*w4;
y_plate = xsize+2*w4 - o_plate;
z_plate = b;
x_off = y_pcb/2-r_pcb;
y_off = x_pcb/2-r_pcb;

// dimensions for standard adafruit-breakout   ---------------------------------

y_stemma     = 8;
z_stemma     = 3.2;
z_pcb        = 1.6;

b_breakout = 0.8;
x_breakout = 25.4  + gap;
y_breakout = 17.98 + gap;
z_breakout = z_pcb + z_stemma;

xo_breakout = 10;
yo_breakout =  2;

// --- standard-breakout from Adafruit   ---------------------------------------

module breakout() {
  cuboid([x_breakout+2*w2,y_breakout+2*w2,b_breakout],anchor=BOTTOM+CENTER);
  zmove(b_breakout-fuzz) difference() {
     // wall around breadboard
     rect_tube(size=[x_breakout+2*w2,y_breakout+2*w2],wall=w2,h=z_breakout,
                     anchor=BOTTOM+CENTER);
     // cutouts for Stemma/Qt
     translate([-x_breakout/2-w2/2-fuzz,0,0])
         cuboid([w2+2*fuzz,y_stemma,z_breakout+2*fuzz],anchor=BOTTOM+CENTER);
     translate([+x_breakout/2+w2/2+fuzz,0,0]) 
         cuboid([w2+2*fuzz,y_stemma,z_breakout+2*fuzz],anchor=BOTTOM+CENTER);
   }
}

// --- standard-breakout from Adafruit   ---------------------------------------

module m5() {
  cuboid([x_m5,y_m5,b_breakout],anchor=BOTTOM+CENTER);
  zmove(b_breakout-fuzz) difference() {
     // wall around sensor
     rect_tube(size=[x_m5,y_m5],wall=w2,h=z_m5,anchor=BOTTOM+CENTER);
     // cutout for Grove
     translate([0,+y_m5/2,0])
         cuboid([x_grove,2*w2+2*fuzz,z_m5+2*fuzz],anchor=BOTTOM+CENTER);
   }
}


// --- sensor-holder   -------------------------------------------------------

module sensor_holder() {
  difference() {
    union() {
      // base plate
      cuboid([x_plate,y_plate,z_plate],anchor=BOTTOM+CENTER,
              rounding=r_pcb,edges="Z");
      // m5-sensor
      translate([0,-y_plate/2+y_m5/2,z_plate]) m5();
      // breakouts
      translate([-x_plate/2+x_breakout/2+w2+xo_breakout,
                 y_plate/2-y_breakout/2-w2-yo_breakout,z_plate])
        breakout();
      translate([+x_plate/2-x_breakout/2+w2-xo_breakout,
                 y_plate/2-y_breakout/2-w2-yo_breakout,z_plate])
        breakout();
    }
    move([-x_off,+y_off-o_plate/2,-fuzz])
              cyl(h=z_plate+2*fuzz,d=d_screw,anchor=BOTTOM+CENTER);
    move([+x_off,+y_off-o_plate/2,-fuzz])
              cyl(h=z_plate+2*fuzz,d=d_screw,anchor=BOTTOM+CENTER);
  }
}

// --- top-level object   ----------------------------------------------------

sensor_holder();
//breakout();