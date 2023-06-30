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

module pcb_support(height) {
  xy = xy_sup;       // xy-size
  d  = 4;       // pocket diameter
  z  = 5.7;     // height of pocket

  difference() {
    cyl(h=height,d=xy_sup,anchor=BOTTOM+CENTER);
    zmove(height-z+fuzz) cyl(h=z,d=d,anchor=BOTTOM+CENTER);
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
  move([-x_sup_off-fuzz,y_sup_off+fuzz,0]) pcb_support(b+z_sup);
  move([-x_sup_off-fuzz,-y_sup_off-fuzz,0]) pcb_support(b+z_sup);
  move([x_sup_off+fuzz,y_sup_off+fuzz,0]) pcb_support(b+z_sup);
  move([x_sup_off+fuzz,-y_sup_off-fuzz,0]) pcb_support(b+z_sup);
  
  // cutout LoRa
  move([x_lora,y_lora,0]) cutout(y2_lora-y1_lora,add=xdelta,pos=LEFT);
  
  // cutout UART
  move([x_uart,y_uart,0]) cutout(x2_uart-x1_uart,add=ydelta/2,pos=BACK);
  
  // cutout ADC
  move([x_adc,y_adc,0]) cutout(y2_adc-y1_adc,add=xdelta/2,pos=RIGHT);
  
  // cutout battery (+ reset-button)
  move([x_bat,y_bat,0]) cutout(y2_bat-y1_bat,add=xdelta,pos=RIGHT);
  
  // cutout SD (+ on-button)
  move([x_sd,y_sd,0]) cutout(x2_sd-x1_sd,add=ydelta,pos=FRONT);
}

// --- cutout   --------------------------------------------------------------

module cutout(width,add,pos) {
  z = b + z_sup + z_pcb;
  if (pos == FRONT) {
    xrot(-90) prismoid(size1=[width+2*add,z], size2=[width,z], h=y_cutout,anchor=BACK);
  } else if (pos == BACK) {
    xrot(90) prismoid(size1=[width+2*add,z], size2=[width,z], h=y_cutout,anchor=FRONT);
  } else if (pos == LEFT) {
    yrot(90) prismoid(size1=[z,width+2*add], size2=[z,width], h=x_cutout,anchor=RIGHT);
  } else if (pos == RIGHT) {
    yrot(-90) prismoid(size1=[z,width+2*add], size2=[z,width], h=x_cutout,anchor=LEFT);
  }
}

// --- bottom of case   ------------------------------------------------------

module case_bottom() {
  difference() {
    corpus_bottom();
    // cutout LoRa
    move([x_lora-w4,y_lora,0]) cutout(y2_lora-y1_lora,add=xdelta,pos=LEFT);
    // cutout UART
    move([x_uart,y_uart+w4,0]) cutout(x2_uart-x1_uart,add=ydelta/2,pos=BACK); 
    // cutout ADC
    move([x_adc+w4,y_adc,0]) cutout(y2_adc-y1_adc,add=xdelta/2,pos=RIGHT);
    // cutout battery (+ reset-button)
    move([x_bat+w4,y_bat,0]) cutout(y2_bat-y1_bat,add=xdelta,pos=RIGHT);
    // cutout SD (+ on-button)
    move([x_sd,y_sd-w4,0]) cutout(x2_sd-x1_sd,add=ydelta,pos=FRONT);
    // cutout display
    move([x_display_off,y_display_off,-fuzz]) cuboid([x_display,y_display,b+2*fuzz],anchor=BOTTOM+CENTER);
  }
}

// --- top-level object   ----------------------------------------------------

// pcb_support(z_sup);
case_bottom();
//cutout(x2_sd-x1_sd,add=ydelta,pos=RIGHT);
