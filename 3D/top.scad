// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) case (top) for datalogger.
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// ---------------------------------------------------------------------------

include <dimensions.scad>
include <BOSL2/std.scad>

// --- case (top-part)   -----------------------------------------------------

module corpus_top() {
  z = b + z_sup + z_pcb;
  x_sup_off = x_pcb/2-r_pcb;
  y_sup_off = y_pcb/2-r_pcb;
  
  // base plate
  cuboid([xsize+2*w4,ysize+2*w4,b],anchor=BOTTOM+CENTER,
            rounding=r_pcb,edges="Z");
  
  // walls
  rect_tube(isize=[xsize,ysize],wall=w4,h=z,anchor=BOTTOM+CENTER,
            rounding=r_pcb,irounding=r_pcb);
  
  // cutout LoRa
  move([-x_lora,y_lora,0]) cutout(y2_lora-y1_lora,add=xdelta,pos=RIGHT);
  
  // cutout UART
  move([-x_uart,y_uart,0]) cutout(x2_uart-x1_uart,add=ydelta/2,pos=BACK);
  
  // cutout ADC
  move([-x_adc,y_adc,0]) cutout(y2_adc-y1_adc,add=xdelta/2,pos=LEFT);
  
  // cutout battery (+ reset-button)
  move([-x_bat,y_bat,0]) cutout(y2_bat-y1_bat,add=xdelta,pos=LEFT);
  
  // cutout SD (+ on-button)
  move([-x_sd,y_sd,0]) cutout(x2_sd-x1_sd,add=ydelta,pos=FRONT);
}
