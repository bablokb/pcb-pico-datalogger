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
include <BOSL2/std.scad>

include <stevenson_holder_dims.scad>

x_pcb = 36.5;
y_pcb = 33.0;
r_pcb =  1.5;       // for M2.5 screws
o_pcb =  3.0;       // offset screw-holes

x_base = x_pcb + 2*w2;   // increase dimensions for printing
y_base = y_pcb + 2*w2;

z_strut = 2;

// --- base   -------------------------------------------------------------------

module lora_base() {
  // lora-base plate
  cuboid([x_base,y_base,b],anchor=BOTTOM+CENTER);

  // connector for stevenson-holder (offsets from stevenson_holder.scad)
  move([x_lora_off,y_base/2-z_lora/2,b])
     cuboid([w4,z_lora,2*z_strut],anchor=BOTTOM+CENTER);
  move([-x_lora_off,y_base/2-z_lora/2,b])
     cuboid([w4,z_lora,2*z_strut],anchor=BOTTOM+CENTER);

  // distance strut
  zmove(b-fuzz)
     cuboid([4*x_lora_off,y_base,z_strut],anchor=BOTTOM+CENTER);
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
    
    // take away from distance strut
    move([0,-y_base/2,b-fuzz])
     cuboid([3*x_lora_off,0.75*y_base,z_strut+2*fuzz],anchor=BOTTOM+CENTER);
    
  }
}

// --- final object   -----------------------------------------------------------

lora_holder();
