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

TEST = true;

// dimensions M5-Stack CO2-sensor   --------------------------------------------

x_m5 = 24+2*w2;
y_m5 = 48+2*w2;
z_m5 = TEST ? 4: 10;
r_m5 = 3;
x_grove = 10;

// dimensions base-plate   -----------------------------------------------------
//
// This is in the same orientation as top.scad. When assembling, the
// right side ends up at the top.

x_plate   = xsize+2*w4;
y_plate   = ysize+2*w4 + w4;  // additional wall at the top
z_plate   = b;
h_plate_r = z_plate + z_case;  // right
h_plate_s = z_plate + 8;       // top+bottom sides
h_plate_l = h_plate_s - w4;    // left
x_off = x_pcb/2-r_pcb;
y_off = y_pcb/2-r_pcb;

h_top = 3*b + zsize;     // base-plate + screws + height of standoffs
z_lora_cutout = 7;

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
  cuboid([x_m5,y_m5,b_breakout],anchor=BOTTOM+CENTER,
               rounding=r_m5,edges="Z");
  zmove(b_breakout-fuzz) difference() {
     // wall around sensor
     rect_tube(size=[x_m5,y_m5],wall=w2,h=z_m5,anchor=BOTTOM+CENTER,
               rounding=r_m5,irounding=r_m5);
     // cutout for Grove
     translate([0,+y_m5/2,0])
         cuboid([x_grove,2*w2+2*fuzz,z_m5+2*fuzz],anchor=BOTTOM+CENTER);
   }
}


// --- sensor-holder   -------------------------------------------------------

module sensor_holder() {
  difference() {
    union() {
      // base plate + right, top, bottom, left walls
      cuboid([x_plate,y_plate,z_plate],anchor=BOTTOM+CENTER);
      xmove(x_plate/2-w4/2)  cuboid([w4,y_plate-2*w4,h_plate_r],anchor=BOTTOM+CENTER,
            rounding=r_pcb,edges=TOP,except="Y");
      ymove(y_plate/2-w4/2)  cuboid([x_plate,w4,h_plate_s],anchor=BOTTOM+CENTER);
      ymove(-y_plate/2+w4/2) cuboid([x_plate,w4,h_plate_s],anchor=BOTTOM+CENTER);
      xmove(-x_plate/2+w4/2) cuboid([w4,y_plate,h_plate_l],anchor=BOTTOM+CENTER);
    }
    // cutout for LoRa
    move([x_plate/2,y_lora,h_top-z_lora])
                      cuboid([4*w4,z_lora_cutout,z_lora_cutout],anchor=BOTTOM+CENTER);

  }
}

// --- top-level object   ----------------------------------------------------

//sensor_holder();
m5();
//breakout();