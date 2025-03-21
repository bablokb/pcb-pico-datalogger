// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) adapter for stevenson-screen: battery cage.
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// -----------------------------------------------------------------------------

include <dimensions.scad>
include <BOSL2/std.scad>

include <battery_holder_dims.scad>
include <dl_holder_dims.scad>

// battery cage   ------------------------------------------------------------

module battery_cage() {
  difference() {
    union() {
      // base plate
      cuboid([x_bat+2*w2,y_bat+2*w2,b],anchor=BOTTOM+BACK);
      // cage
      rect_tube(size=[x_bat+2*w2,y_bat+2*w2], h=z_bat,
                wall=w2,anchor=BOTTOM+BACK);
      // struts
      move([x_bat_off,-fuzz,0])
                            cuboid([w4,y_base+gap+2*fuzz,z_bat],anchor=BOTTOM+FRONT);
      move([-x_bat_off,-fuzz,0])
                            cuboid([w4,y_base+gap+2*fuzz,z_bat],anchor=BOTTOM+FRONT);
      // back wall
      ymove(y_base+gap) cuboid([x_bat,w2,z_bat],anchor=BOTTOM+FRONT);
    }
    
    // cutout PH2 battery cable
    move([x_bat/2-x_ph2/2-w2,-y_bat/2-y_ph2/2,-fuzz])
       cuboid([x_ph2,y_ph2,b+2*fuzz],anchor=BOTTOM+CENTER);
    
    // cutout onoff switch
    move([-xo_onoff,-y_bat-w2+fuzz,b+z_onoff])
       cuboid([x_onoff,w2+2*fuzz,z_onoff],anchor=BOTTOM+BACK);
    
  }
}

// test   ---------------------------------------------------------------------

battery_cage();
