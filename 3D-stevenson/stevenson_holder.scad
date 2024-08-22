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

include <stevenson_holder_dims.scad>
include <dl_holder_dims.scad>

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
    union() {
      rect_tube(size1=[x_holder+2*w4+gap,y00_holder+2*w4+gap],
                size2=[x_holder+2*w4+gap,y60_holder+2*w4+gap],
                shift=[0,-(y00_holder-y60_holder)/2],
                h=z_holder,
                wall=w4,anchor=BOTTOM+FRONT);
      // add more depth at the front (slides into dl_holder)
      cuboid([x_holder+2*w4+gap,y_base,z_holder],anchor=BOTTOM+BACK);
    }
    // remove front
    move([0,-y_base-fuzz,-fuzz])
       cuboid([x_holder+gap,y_base+w4+2*fuzz,z_holder+2*fuzz],anchor=BOTTOM+FRONT);
  }
}

// --- bottom part of tube   ---------------------------------------------------

module bottom_tube() {
  difference() {
    holder_tube();
    // remove top part
    move([0,-y_base-fuzz,z_bottom])
      cuboid([2*x_holder,2*y00_holder,z_holder],anchor=BOTTOM+FRONT);
    // cutouts for LoRa holder
    move([x_lora_off,0,z_bottom - z_lora+fuzz])
      prismoid(size1=[w4,2*y00_holder],
               size2=[w4+gap,2*y00_holder],h=z_lora,anchor=BOTTOM+FRONT);
    move([-x_lora_off,0,z_bottom - z_lora+fuzz])
      prismoid(size1=[w4,2*y00_holder],
               size2=[w4+gap,2*y00_holder],h=z_lora,anchor=BOTTOM+FRONT);
  }
}

// --- top part of tube   ---------------------------------------------------

module top_tube() {
  difference() {
    holder_tube();
    // remove bottom part
    move([0,-y_base-fuzz,z_holder-z_top])
      cuboid([2*x_holder,2*y00_holder,z_holder],anchor=TOP+FRONT);
  }
}

// --- tests   ------------------------------------------------------------------

//top_tube();
//bottom_tube();
