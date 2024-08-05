// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) adapter for stevenson-screen: holder for datalogger.
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// -----------------------------------------------------------------------------

include <dimensions.scad>
include <shared_modules.scad>
include <BOSL2/std.scad>

x_pcb = 56;
z_pcb = 70;

r_pcb =  1.5;       // for M2.5 screws
o_pcb =  3.0;       // offset screw-holes

x_base = x_pcb + 2*w2;   // increase dimensions for printing
y_base = 2.6;
z_base = z_pcb + 2*w2;

x_foot = 40;   // clearance foot
z_foot = 10;
z_bat  = 35;

x_bat_off  = 10;
z_bat_off  =  5;

x_pico = w4;
y_pico =  2.0;
z_pico = 55.0;
o1_pico = 9.8;
o2_pico = 8.0;

// --- connector   -------------------------------------------------------------

module connector() {
  // main connector
  cuboid([x_base,y_base,z_base],anchor=BOTTOM+CENTER);
  // "foot" below connector
  color("blue") zmove(-z_foot) cuboid([x_base,y_base,z_foot],anchor=BOTTOM+CENTER);
  // battery holder above connector
  color("blue") zmove(z_base) cuboid([x_base,y_base,z_bat],anchor=BOTTOM+CENTER);
  // tube around internal Stevenson-holder
  color("green") move([0,y00_holder/2+w4/2,-z_foot]) holder_tube(); 
}

// --- holder (connector + cutouts)   ------------------------------------------

module dl_holder() {
  difference() {
    connector();

    // screw-holes (holes based on x_pcb, not x_base!)
    x_hole = +x_pcb/2-o_pcb;
    z_hole = +z_pcb-o_pcb; 
    move([-x_hole,-fuzz,+z_hole]) cyl(h=y_base+2*fuzz,r=r_pcb,anchor=CENTER,orient=BACK);
    move([-x_hole,-fuzz,o_pcb]) cyl(h=y_base+2*fuzz,r=r_pcb,anchor=CENTER,orient=BACK);
    move([+x_hole,-fuzz,+z_hole]) cyl(h=y_base+2*fuzz,r=r_pcb,anchor=CENTER,orient=BACK);
    move([+x_hole,-fuzz,o_pcb]) cyl(h=y_base+2*fuzz,r=r_pcb,anchor=CENTER,orient=BACK);

    // space for LoRa-PCB connector
    zmove(-z_foot-fuzz) cuboid([x_foot,100,z_foot+fuzz],anchor=BOTTOM+CENTER);
    
    // cutouts for battery holder
    move([x_bat_off,-fuzz,z_base+z_bat_off])
                        cuboid([2*w4,y_base+2*fuzz,z_bat],anchor=BOTTOM+CENTER);
    move([-x_bat_off,-fuzz,z_base+z_bat_off])
                        cuboid([2*w4,y_base+2*fuzz,z_bat],anchor=BOTTOM+CENTER);
    
    // cutouts for pico-connectors (solder joints on the back)
    move([-o1_pico,y_base/2-y_pico,z_pcb-z_pico+w2])
             cuboid([x_pico,y_pico,z_pico],anchor=BOTTOM+CENTER);
    move([o2_pico,y_base/2-y_pico,z_pcb-z_pico+w2])
             cuboid([x_pico,y_pico,z_pico],anchor=BOTTOM+CENTER);

    // remove some material from tube
    move([0,y00_holder+y_base/2,z_holder/4])
                           cuboid([x_base,2*y00_holder,z_holder/3],anchor=BOTTOM+CENTER);
  }
}

// --- final object   -----------------------------------------------------------

xrot(90) dl_holder();   // rotated for printing
