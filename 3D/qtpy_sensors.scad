// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) shapes for datalogger.
//
// Two shapes for the datalogger:
//   - qtpy: for standard qtpy breakouts
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// ---------------------------------------------------------------------------

include <dimensions.scad>
include <BOSL2/std.scad>

x_sensor     = 3.4;
y_sensor     = 3.4;
y_sensor_off = 1.27;

y_stemma     = 8;
z_stemma     = 3.1;
z_pcb        = 1.6;

x_qtpy      = 25.4  + gap;
y_qtpy      = 17.98 + gap;

// --- sensor   ----------------------------------------------------------------

module qtpy_breakout(z) {
  z_sensor = z_pcb + z_stemma;
  translate([0,0,z-fuzz]) {
    difference() {
      // wall around breakout
      rect_tube(size=[x_qtpy+2*w2,y_qtpy+2*w2],wall=w2,h=z_sensor,
                      anchor=BOTTOM+CENTER);
      // cutouts for Stemma/Qt
      translate([-x_qtpy/2-w2/2-fuzz,0,0])
          cuboid([w2+2*fuzz,y_stemma,z_sensor+fuzz],anchor=BOTTOM+CENTER);
      translate([+x_qtpy/2+w2/2-fuzz,0,0])
          cuboid([w2+2*fuzz,y_stemma,z_sensor+fuzz],anchor=BOTTOM+CENTER);
    }
    // wall around sensor
    translate([0,y_sensor_off,0])
         rect_tube(size=[x_sensor+2*w2,y_sensor+2*w2],wall=w2,h=z_stemma+2*fuzz,
                   anchor=BOTTOM+CENTER);
  }
}

// --- base for qtpy-formfactor   ----------------------------------------------

module qtpy_base(z) {
  cuboid([x_qtpy+2*w2,y_qtpy+2*w2,z],anchor=BOTTOM+CENTER);
}

// --- sensor in qtpy-formfactor   ---------------------------------------------

module qtpy_sensor(z) {
  difference() {
    // base plate
    qtpy_base(z);
    // cutout for sensor
    translate([0,y_sensor_off,-fuzz]) 
      cuboid([x_sensor,y_sensor,z+2*fuzz], anchor=BOTTOM+CENTER);
  }
  qtpy_breakout(z);
}
