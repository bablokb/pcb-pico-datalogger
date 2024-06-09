// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) case (bottom) for datalogger.
//
// There are two versions of the bottom part: one with a cutout for the display
// and one without cutout.
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// ---------------------------------------------------------------------------

include <dimensions.scad>
include <dimensions_bottom.scad>
include <shared_modules.scad>
include <BOSL2/std.scad>

x_display     = 42;
y_display     = 88;
x_display_off = -x_pcb/2 + x_display/2 + 24;
y_display_off = (y_pcb - y_display)/2 - 1.5;

// --- support + thread-pocket   ---------------------------------------------

module pcb_support() {
  h = b+z_sup;
  difference() {
    cyl(h=h,d=xy_sup,anchor=BOTTOM+CENTER);
    zmove(h-ht_sup+fuzz) cyl(h=ht_sup,d=dt_sup,anchor=BOTTOM+CENTER);
  }
}

// --- case (bottom-part)   --------------------------------------------------

module corpus_bottom() {
  h = b + z_sup + z_pcb;
  x_sup_off = x_pcb/2-r_pcb;
  y_sup_off = y_pcb/2-r_pcb;
  
  // base plate
  cuboid([xsize+2*w4,ysize+2*w4,b],anchor=BOTTOM+CENTER,
            rounding=r_pcb,edges="Z");
  
  // walls
  rect_tube(isize=[xsize,ysize],wall=w4,h=h,anchor=BOTTOM+CENTER,
            rounding=r_pcb,irounding=r_pcb);
  
  // supports
  move([-x_sup_off-fuzz,y_sup_off+fuzz,0]) pcb_support();
  move([-x_sup_off-fuzz,-y_sup_off-fuzz,0]) pcb_support();
  move([x_sup_off+fuzz,y_sup_off+fuzz,0]) pcb_support();
  move([x_sup_off+fuzz,-y_sup_off-fuzz,0]) pcb_support();

  // cutout LoRa
  move([x_lora,y_lora,0]) cutout(width1=y2_lora-y1_lora,
                                 width2=yw_lora,depth=d_lora,h=h,pos=LEFT);
}

// --- bottom of case   ------------------------------------------------------

module case_bottom() {
  difference() {
    corpus_bottom();
    // cutout LoRa
    h = b + z_sup + z_pcb;
    move([x_lora-w4,y_lora,0]) cutout(width1=y2_lora-y1_lora-w4,
                                width2=yw_lora-w4,depth=d_lora,h=h,pos=LEFT);
    // cutout display
    move([x_display_off,y_display_off,-fuzz])
                 cuboid([x_display,y_display,b+2*fuzz],anchor=BOTTOM+CENTER);
  }
}

// --- top-level object   ----------------------------------------------------

//intersection() {
//  case_bottom();
//  move([-xsize/2-10,-5,0])
//                 cuboid([xsize/2+5,40,b+z_pcb],anchor=BOTTOM+CENTER);
//}
case_bottom();
