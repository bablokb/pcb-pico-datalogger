// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) case (bottom) for datalogger.
//
// Sensor-holder for the top of the printed case.
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

// dimensions for standard adafruit-breakout   ---------------------------------

x_stemma     = 8;
z_stemma     = 3.2;
z_pcb        = 1.6;

b_breakout = 0.8;
x_breakout = 17.98 + gap;
y_breakout = 25.4  + gap;
z_breakout = z_pcb + z_stemma;

// --- standard-breakout from Adafruit   ---------------------------------------

module breakout() {
  cuboid([x_breakout+2*w2,y_breakout+2*w2,b_breakout],anchor=BOTTOM+CENTER);
  zmove(b_breakout-fuzz) difference() {
     // wall around breadboard
     rect_tube(size=[x_breakout+2*w2,y_breakout+2*w2],wall=w2,h=z_breakout,
                     anchor=BOTTOM+CENTER);
     // cutouts for Stemma/Qt
     translate([0,-y_breakout/2-w2/2-fuzz,0])
         cuboid([x_stemma,w2+2*fuzz,z_breakout+2*fuzz],anchor=BOTTOM+CENTER);
     translate([0,+y_breakout/2+w2/2+fuzz,0]) 
         cuboid([x_stemma,w2+2*fuzz,z_breakout+2*fuzz],anchor=BOTTOM+CENTER);
   }
}

// --- sensor-holder   -------------------------------------------------------

module sensor_holder() {
  // this is printed on the side, so change names
  height  = x_bat_holder - 3*gap;
  xlength = z_bat_holder;
  union() {
    // the cover (top)
    cuboid([w4,z_case+2*w4+gap,height],anchor=BOTTOM+CENTER);
     // holder for sensors
    ymove(z_case/2+0.5*w4+gap/2)
      xmove(xlength/2-fuzz)
        cuboid([x_breakout+2*w2,w4,height],anchor=BOTTOM+CENTER);
     // holder for main sensor-case
     ymove(z_case/2+0.5*w4+gap/2)
        xmove(-xlength/4+fuzz)
          cuboid([xlength/2,w4,height],anchor=BOTTOM+CENTER);
     ymove(-z_case/2-0.5*w4-gap/2)
      xmove(-xlength/4+fuzz)
        cuboid([xlength/2,w4,height],anchor=BOTTOM+CENTER);
  }
}

// --- top-level object   ----------------------------------------------------

sensor_holder();
//breakout();