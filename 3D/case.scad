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

  // cutout LoRa
  move([x_lora,y_lora,0]) cutout(width1=y2_lora-y1_lora,
                                 width2=yw_lora,depth=d_lora,pos=LEFT);
}

// --- cutout   --------------------------------------------------------------

module cutout(width1,width2,depth,pos) {
  z = b + z_sup + z_pcb;
  if (pos == FRONT) {
    xrot(-90) prismoid(size1=[width1,z], size2=[width2,z], h=depth,anchor=BACK);
  } else if (pos == BACK) {
    xrot(90) prismoid(size1=[width1,z], size2=[width2,z], h=depth,anchor=FRONT);
  } else if (pos == LEFT) {
    yrot(90) prismoid(size1=[z,width1], size2=[z,width2], h=depth,anchor=RIGHT);
  } else if (pos == RIGHT) {
    yrot(-90) prismoid(size1=[z,width1], size2=[z,width2], h=depth,anchor=LEFT);
  }
}

// --- bottom of case   ------------------------------------------------------

module case_bottom() {
  difference() {
    corpus_bottom();
    // cutout LoRa
    move([x_lora-w4,y_lora,0]) cutout(width1=y2_lora-y1_lora,
                                      width2=yw_lora,depth=d_lora,pos=LEFT);
    // cutout display
    move([x_display_off,y_display_off,-fuzz])
                 cuboid([x_display,y_display,b+2*fuzz],anchor=BOTTOM+CENTER);
  }
}

// --- top-level object   ----------------------------------------------------

// pcb_support(z_sup);
case_bottom();
