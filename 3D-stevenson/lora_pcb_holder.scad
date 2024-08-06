// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) adapter for stevenson-screen: connector for LoRa-PCB.
//
// This slides into the bottom_tube() from stevenson_holder.scad.
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// -----------------------------------------------------------------------------

include <dimensions.scad>
include <stevenson_holder.scad>
include <BOSL2/std.scad>

x_pcb = 36.5;
y_pcb = 33.0;
r_pcb =  1.5;       // for M2.5 screws
o_pcb =  3.0;       // offset screw-holes

x_base = x_pcb + 2*w2;   // increase dimensions for printing
y_base = y_pcb + 2*w2;

// --- base   -------------------------------------------------------------------

module lora_base() {
  // lora-base plate
  cuboid([x_base,y_base,b],anchor=BOTTOM+CENTER);
  // connector for stevenson-holder (offsets from stevenson_holder.scad)
  move([x_lora_off,y_base/2-z_lora/2,b]) cuboid([w4,z_lora,2*w4],anchor=BOTTOM+CENTER);
  move([-x_lora_off,y_base/2-z_lora/2,b]) cuboid([w4,z_lora,2*w4],anchor=BOTTOM+CENTER);
}

// --- base + cutouts   ---------------------------------------------------------

module lora_holder() {
  difference() {
    lora_base();

    // screw-holes (holes based on x_pcb, not x_base!)
    x_hole = +x_pcb/2-o_pcb;
    y_hole = +y_pcb/2-o_pcb; 
    move([-x_hole,+y_hole,-fuzz]) cyl(h=b+2*fuzz,r=r_pcb,anchor=BOTTOM+CENTER); 
    move([-x_hole,-y_hole,-fuzz]) cyl(h=b+2*fuzz,r=r_pcb,anchor=BOTTOM+CENTER); 
    move([+x_hole,+y_hole,-fuzz]) cyl(h=b+2*fuzz,r=r_pcb,anchor=BOTTOM+CENTER); 
    move([+x_hole,-y_hole,-fuzz]) cyl(h=b+2*fuzz,r=r_pcb,anchor=BOTTOM+CENTER); 

    // cutout stenvenson-holder (from stevenson_holder.scad)
    ymove(y_base/2+1.5*w4) holder_cutout();
  }
}

// --- final object   -----------------------------------------------------------

lora_holder();
