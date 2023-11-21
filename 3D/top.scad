// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) case (top) for datalogger.
//
// TODOs:
//  - support ENS160 breakout (?)
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// ---------------------------------------------------------------------------

include <dimensions.scad>
include <dimensions_top.scad>
include <shared_modules.scad>
include <sensors.scad>
include <btn_pcb.scad>
include <BOSL2/std.scad>

h_screw = b;
h_top = b + h_screw + zsize;     // base-plate + screws + height of standoffs
x_off = x_pcb/2-r_pcb;
y_off = y_pcb/2-r_pcb;

x_btn_off = 0;                   // offset button-pcb
y_btn_off = -y_pcb/2+20;

// --- case (top-part)   -----------------------------------------------------

module corpus_top() {
  x_sup_off = x_pcb/2-r_pcb;
  y_sup_off = y_pcb/2-r_pcb;
  
  // base plate
  cuboid([xsize+2*w4,ysize+2*w4,b],anchor=BOTTOM+CENTER,
            rounding=r_pcb,edges="Z");
  
  // screws
  move([-x_off,+y_off,b-fuzz]) cyl(h=h_screw,d=1.2*d_screw_h,anchor=BOTTOM+CENTER);
  move([-x_off,-y_off,b-fuzz]) cyl(h=h_screw,d=1.2*d_screw_h,anchor=BOTTOM+CENTER);
  move([+x_off,+y_off,b-fuzz]) cyl(h=h_screw,d=1.2*d_screw_h,anchor=BOTTOM+CENTER);
  move([+x_off,-y_off,b-fuzz]) cyl(h=h_screw,d=1.2*d_screw_h,anchor=BOTTOM+CENTER);

  // walls
  rect_tube(isize=[xsize,ysize],wall=w4,h=h_top,anchor=BOTTOM+CENTER,
            rounding=r_pcb,irounding=r_pcb);
  
  // cutout LoRa
  move([-x_lora,y_lora,0]) cutout(width1=y2_lora-y1_lora,
                                 width2=yw_lora,depth=d_lora,h=h_top,pos=RIGHT);
  // cutout i2c+pico
  move([x_i2c,y_i2c,0]) cutout(width1=x2_i2c-x1_i2c,
                                 width2=x2_i2c-x1_i2c,depth=d_i2c,h=h_top,pos=BACK);
}

// --- top of case   ---------------------------------------------------------

module case_top() {
  difference() {
    corpus_top();

    // cutout screw-holes
    move([-x_off,+y_off,-fuzz]) cyl(h=b,d=d_screw_h,anchor=BOTTOM+CENTER);
    move([-x_off,-y_off,-fuzz]) cyl(h=b,d=d_screw_h,anchor=BOTTOM+CENTER);
    move([+x_off,+y_off,-fuzz]) cyl(h=b,d=d_screw_h,anchor=BOTTOM+CENTER);
    move([+x_off,-y_off,-fuzz]) cyl(h=b,d=d_screw_h,anchor=BOTTOM+CENTER);

    move([-x_off,+y_off,-fuzz]) cyl(h=2*b+2*fuzz,d=d_screw,anchor=BOTTOM+CENTER);
    move([-x_off,-y_off,-fuzz]) cyl(h=2*b+2*fuzz,d=d_screw,anchor=BOTTOM+CENTER);
    move([+x_off,+y_off,-fuzz]) cyl(h=2*b+2*fuzz,d=d_screw,anchor=BOTTOM+CENTER);
    move([+x_off,-y_off,-fuzz]) cyl(h=2*b+2*fuzz,d=d_screw,anchor=BOTTOM+CENTER);

    // cutout LoRa
    move([-x_lora,y_lora,0]) cutout(width1=y2_lora-y1_lora,
                             width2=yw_lora,depth=d_lora,h=h_top,pos=RIGHT);
    // cutout i2c+pico
    move([x_i2c,y_i2c+w2,0]) cutout(width1=x2_i2c-x1_i2c-w4,
                            width2=x2_i2c-x1_i2c-w4,depth=d_i2c,h=h_top,pos=BACK);
    move([x_i2c,y_i2c,h_top-z_i2c]) cutout(width1=x2_i2c-x1_i2c-w4,
                            width2=x2_i2c-x1_i2c-w4,depth=d_i2c,h=h_top,pos=BACK);

    // cutout UART/I2C0
    move([x_uart,ysize/2,b]) 
       cuboid([(x2_uart-x1_uart),4*w4,h_top],anchor=BOTTOM+CENTER);
    // cutout SD
    move([x_sd,-ysize/2,h_top-z_sd])
       cuboid([(x2_sd-x1_sd),4*w4,z_sd+fuzz],anchor=BOTTOM+CENTER);
    // cutout Bat
    move([-xsize/2,y_bat,h_top-z_bat])
       cuboid([4*w4,(y2_bat-y1_bat),z_bat+fuzz],anchor=BOTTOM+CENTER);
    // cutout ADC (add if needed)
    move([-xsize/2,y_adc,b])
        cuboid([4*w4,(y2_adc-y1_adc),h_top],anchor=BOTTOM+CENTER);
    // cutout sensor and buttons
    qtpy_base(b);
    translate([x_btn_off,y_btn_off,0]) btn_base(b);
  }
  // sensor-holder and buttons-holder
  qtpy_sensor(b,0,0);
  translate([x_btn_off,y_btn_off,0]) btn_pcb_holder(b);
}

// --- top-level object   ----------------------------------------------------

//intersection() {
//  case_top();
//  move([-xsize/2-10,-5,0])
//                 cuboid([xsize/2+5,40,b+z_pcb],anchor=BOTTOM+CENTER);
//}
case_top();

