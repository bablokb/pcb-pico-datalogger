// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) adapter for stevenson-screen: connector for
// inner holder.
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// -----------------------------------------------------------------------------

include <dimensions.scad>
include <BOSL2/std.scad>

x_holder   = 31.1;
z_holder   = 60.0;
z_bottom   = 39.0;
z_top      = 10.0;
w_holder   =  1.5;
y00_holder = 10.0;   // y at z=00
y60_holder =  7.5;   // y at z=60

z_lora = 20.0;
x_lora_off = 5;

// --- helper-module (side)   --------------------------------------------------

module holder_side() {
  ymove(y00_holder/2-w_holder/2)
  prismoid(size1=[w_holder+2*gap,y00_holder+2*gap],
           size2=[w_holder+2*gap,y60_holder+2*gap], h=z_holder,
           shift=[0,-(y00_holder-y60_holder)/2]);
}

// --- reproduce vertical holder of stevenson-screen (needed for cutouts)   ----

module holder_cutout() {
  // front-side with some added size
  cuboid([x_holder+2*gap,w_holder+2*gap,z_holder],anchor=BOTTOM+CENTER);
  // sides
  xmove(-x_holder/2+w_holder/2) holder_side();
  xmove(+x_holder/2-w_holder/2) holder_side();
}

// --- tube fitting around holder   ---------------------------------------------

module holder_tube() {
  difference() {
    rect_tube(size1=[x_holder+2*w4+gap,y00_holder+2*w4+gap],
              size2=[x_holder+2*w4+gap,y60_holder+2*w4+gap],
              shift=[0,-(y00_holder-y60_holder)/2],
              h=z_holder,
              wall=w4,anchor=BOTTOM+CENTER);
    // remove back
    ymove(-y00_holder/2-w4)
           cuboid([x_holder,2*w4,z_holder],anchor=BOTTOM+CENTER);
  }
}

// --- bottom part of tube   ---------------------------------------------------

module bottom_tube() {
  difference() {
    holder_tube();
    // remove top part
    zmove(z_bottom)
      cuboid([2*x_holder,2*y00_holder,z_holder],anchor=BOTTOM+CENTER);
    // cutouts for LoRa holder
    move([x_lora_off,0,z_bottom - z_lora+fuzz])
      prismoid(size1=[w4,2*y00_holder],
               size2=[w4+gap,2*y00_holder],h=z_lora,anchor=BOTTOM+CENTER);
    move([-x_lora_off,0,z_bottom - z_lora+fuzz])
      prismoid(size1=[w4,2*y00_holder],
               size2=[w4+gap,2*y00_holder],h=z_lora,anchor=BOTTOM+CENTER);
  }
}

// --- top part of tube   ---------------------------------------------------

module top_tube() {
  difference() {
    holder_tube();
    // remove bottom part
    zmove(z_holder-z_top)
      cuboid([2*x_holder,2*y00_holder,z_holder],anchor=TOP+CENTER);
  }
}

// --- tests   ------------------------------------------------------------------

//top_tube();
//bottom_tube();
