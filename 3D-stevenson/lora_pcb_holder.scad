// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) adapter for stevenson-screen: shared modules.
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// -----------------------------------------------------------------------------

include <dimensions.scad>
include <shared_modules.scad>
include <BOSL2/std.scad>

x_pcb = 36.5;
y_pcb = 33.0;
r_pcb =  1.5;       // for M2.5 screws
o_pcb =  3.0;       // offset screw-holes

x_conn = 32.0;
y_conn = 12.0 + w4;
z_conn =   2.0 + b;

x_base = x_pcb + 2*w2;   // increase dimensions for printing
y_base = y_pcb + 2*w2;

// --- base   -------------------------------------------------------------------

module lora_base() {
  // lora-base plate and a support tube
  zmove(z_conn-b) cuboid([x_base,y_base,b],anchor=BOTTOM+CENTER);
  rect_tube(size=y_pcb-2*o_pcb, wall=w4, rounding=10, irounding=10,
                                                  h=z_conn,anchor=BOTTOM+CENTER);
  // connector plate
  color("blue") ymove(y_base/2+y_conn/2-fuzz)
                            cuboid([x_base,y_conn,z_conn],anchor=BOTTOM+CENTER);
}

// --- base + cutouts   ---------------------------------------------------------

module lora_holder() {
  difference() {
    lora_base();

    // screw-holes (holes based on x_pcb, not x_base!)
    x_hole = +x_pcb/2-o_pcb;
    y_hole = +y_pcb/2-o_pcb; 
    move([-x_hole,+y_hole,-fuzz]) cyl(h=z_conn+2*fuzz,r=r_pcb,anchor=BOTTOM+CENTER); 
    move([-x_hole,-y_hole,-fuzz]) cyl(h=z_conn+2*fuzz,r=r_pcb,anchor=BOTTOM+CENTER); 
    move([+x_hole,+y_hole,-fuzz]) cyl(h=z_conn+2*fuzz,r=r_pcb,anchor=BOTTOM+CENTER); 
    move([+x_hole,-y_hole,-fuzz]) cyl(h=z_conn+2*fuzz,r=r_pcb,anchor=BOTTOM+CENTER); 

    // cutout stenvenson-holder (from shared_modules)
    ymove(y_base/2+1.5*w4) holder_cutout();
  }
}

// --- final object   -----------------------------------------------------------

yrot(180) lora_holder();   // rotated for printing
