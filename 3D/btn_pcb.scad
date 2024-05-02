// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) shapes for datalogger.
//
// Two shapes for the datalogger:
//   - pcb_base: base-size of shape (for cutout and pcb_holder)
//   - pcb_holder: the holder for the pcb
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// ---------------------------------------------------------------------------

include <dimensions.scad>
include <BOSL2/std.scad>

// dimensions button-pcb
btn_gap = 0.2;
x_btn_pcb = 36 + 2*btn_gap;
y_btn_pcb = 10 + 2*btn_gap;
h_btn_pcb = 1.6;
a_btn_pcb = 1.6;

// cutout pins (back of connectors): 2x2/3x1 pins
y_co_pins       = 5.1 + 2*btn_gap;
x_co_pins       = 7.6 + 3*btn_gap;
x_co_pins_off   = 0;                          // relative to pcb
y_co_pins_off   = -y_btn_pcb/2+y_co_pins/2;   // relative to pcb
h_co_pins       = 0.4;

// cutout buttons
x_co_btn        = 6.3;
y_co_btn        = x_co_btn;
x_co_btn2       = 6.7;
y_co_btn2       = 7.2;
h_co_btn2       = 0.4;
x_co_btn_off    = 8.21;
y_co_btn_off    = 0;

// dimensions cylinders for pcb mounting holes
d_btn_pcb_cyl = 2.5 - 2*btn_gap;
x_btn_pcb_cyl_off = 14.87;
y_btn_pcb_cyl_off = 0;

x_cutout     = 18.4;
y_cutout     = 11;
h_cutout     = 2.6;

// --- base of pcb-holder   ------------------------------------------------------------

module btn_base(z) {
  cuboid([x_btn_pcb+2*w2,y_btn_pcb+2*w2,z],anchor=BOTTOM+CENTER);
}

// --- holder for button/led-pcb   -----------------------------------------------------

module btn_pcb_holder(z) {

  // body of pcb-holder
  difference() {
    // base
    btn_base(z);

    // minus pin-cutout
    translate([x_co_pins_off,y_co_pins_off,h_co_pins])
       cuboid([x_co_pins,y_co_pins,z+2*fuzz],anchor=BOTTOM+CENTER);

    // minus button-cutouts
    translate([x_co_btn_off,y_co_btn_off,-fuzz])
       cuboid([x_co_btn,y_co_btn,z+2*fuzz],anchor=BOTTOM+CENTER);
    translate([x_co_btn_off,y_co_btn_off,h_co_btn2])
       cuboid([x_co_btn2,y_co_btn2,z+2*fuzz],anchor=BOTTOM+CENTER);
    translate([-x_co_btn_off,y_co_btn_off,-fuzz])
       cuboid([x_co_btn,y_co_btn,z+2*fuzz],anchor=BOTTOM+CENTER);
    translate([-x_co_btn_off,y_co_btn_off,h_co_btn2])
       cuboid([x_co_btn2,y_co_btn2,z+2*fuzz],anchor=BOTTOM+CENTER);
  }

  // walls above pcb-holder
  translate([0,0,z-fuzz])
     rect_tube(isize=[x_btn_pcb,y_btn_pcb],h=h_btn_pcb+a_btn_pcb,wall=w2,anchor=BOTTOM+CENTER);

  // two cylinders for mounting-holes
  translate([-x_btn_pcb_cyl_off,y_btn_pcb_cyl_off,z-fuzz])
     cylinder(d=d_btn_pcb_cyl,h=h_btn_pcb+a_btn_pcb,anchor=BOTTOM+CENTER);
  translate([+x_btn_pcb_cyl_off,y_btn_pcb_cyl_off,z-fuzz])
     cylinder(d=d_btn_pcb_cyl,h=h_btn_pcb+a_btn_pcb,anchor=BOTTOM+CENTER);
}

// --- cover for button/led-pcb   ----------------------------------------------

module btn_pcb_cover() {
   difference() {
    // body of pcb-cover
    cuboid([x_btn_pcb,y_btn_pcb,a_btn_pcb],anchor=BOTTOM+CENTER);
    // minus LED-cutout
    translate([x_co_led_off,y_co_led_off,-fuzz])
       cuboid([x_co_led,y_co_led,a_btn_pcb+2*fuzz],anchor=BOTTOM+CENTER);
    // minus pin-cutout
    translate([x_co_pins_off,y_co_pins_off,-fuzz])
       cuboid([x_co_pins,y_co_pins,a_btn_pcb+2*fuzz],anchor=BOTTOM+CENTER);
    // minus button-cutout
    translate([x_co_btn_off,y_co_btn_off,-fuzz])
       cuboid([x_co_btn2,y_co_btn2,a_btn_pcb+2*fuzz],anchor=BOTTOM+CENTER);
    // minus cylinder-cutouts
    translate([-x_btn_pcb_cyl_off,y_btn_pcb_cyl_off,-fuzz])
       cylinder(d=d_btn_pcb_cyl,h=a_btn_pcb+2*fuzz,anchor=BOTTOM+CENTER);
    translate([+x_btn_pcb_cyl_off,y_btn_pcb_cyl_off,-fuzz])
       cylinder(d=d_btn_pcb_cyl,h=a_btn_pcb+2*fuzz,anchor=BOTTOM+CENTER);
  } 
}
