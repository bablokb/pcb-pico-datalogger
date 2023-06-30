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
include <BOSL2/std.scad>

x_display     = 42;
y_display     = 88;
x_display_off = -x_pcb/2 + x_display/2 + 24;
y_display_off = (y_pcb - y_display)/2;

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
  z = b + z_sup + z_pcb;
  x_sup_off = x_pcb/2-r_pcb;
  y_sup_off = y_pcb/2-r_pcb;
  
  // base plate
  cuboid([xsize+2*w4,ysize+2*w4,b],anchor=BOTTOM+CENTER,
            rounding=r_pcb,edges="Z");
  
  // walls
  rect_tube(isize=[xsize,ysize],wall=w4,h=z,anchor=BOTTOM+CENTER,
            rounding=r_pcb,irounding=r_pcb);
  
  // supports
  move([-x_sup_off-fuzz,y_sup_off+fuzz,0]) pcb_support();
  move([-x_sup_off-fuzz,-y_sup_off-fuzz,0]) pcb_support();
  move([x_sup_off+fuzz,y_sup_off+fuzz,0]) pcb_support();
  move([x_sup_off+fuzz,-y_sup_off-fuzz,0]) pcb_support();
}

// --- bottom of case   ------------------------------------------------------

module case_bottom() {
  difference() {
    corpus_bottom();
    // cutout display
    move([x_display_off,y_display_off,-fuzz]) cuboid([x_display,y_display,b+2*fuzz],anchor=BOTTOM+CENTER);
  }
}

// --- top-level object   ----------------------------------------------------

// pcb_support(z_sup);
case_bottom();
//cutout(x2_sd-x1_sd,add=ydelta,pos=RIGHT);
