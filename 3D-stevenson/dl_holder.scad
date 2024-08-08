// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) adapter for stevenson-screen: holder for datalogger.
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// -----------------------------------------------------------------------------

include <dimensions.scad>
include <stevenson_holder.scad>
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
}

// --- screw-holes   -----------------------------------------------------------

module screw_holes(x_pos,z_pos,offset) {
  move([-x_pos,-fuzz,+z_pos]) cyl(h=y_base+2*fuzz,r=r_pcb,anchor=CENTER,orient=BACK);
  move([-x_pos,-fuzz,offset]) cyl(h=y_base+2*fuzz,r=r_pcb,anchor=CENTER,orient=BACK);
  move([+x_pos,-fuzz,+z_pos]) cyl(h=y_base+2*fuzz,r=r_pcb,anchor=CENTER,orient=BACK);
  move([+x_pos,-fuzz,offset]) cyl(h=y_base+2*fuzz,r=r_pcb,anchor=CENTER,orient=BACK);
}

// --- holder (connector + cutouts)   ------------------------------------------

module dl_holder() {
  difference() {
    connector();

    // screw-holes (holes based on x_pcb, not x_base!)
    x_hole = +x_pcb/2-o_pcb;
    z_hole = +z_pcb-o_pcb; 
    screw_holes(x_hole,z_hole,o_pcb);

    // screw-holes (for 0.94 PCB)
    x_hole2 = +(x_pcb-10)/2-o_pcb;
    z_hole2 = +(z_pcb-10)-o_pcb;
    screw_holes(x_hole2,z_hole2,o_pcb);

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

    // cutouts for bottom_tube
    move([-(x_holder/2+w4+gap)+w4/2,-fuzz,-z_foot])
       cuboid([w4+2*gap,y_base+2*fuzz,z_bottom+gap],anchor=BOTTOM+CENTER);
    move([+(x_holder/2+w4+gap)-w4/2,-fuzz,-z_foot])
       cuboid([w4+2*gap,y_base+2*fuzz,z_bottom+gap],anchor=BOTTOM+CENTER);

    // cutouts for top_tube
    move([-(x_holder/2+w4+gap)+w4/2,-fuzz,z_holder-z_top-z_foot-gap])
       cuboid([w4+2*gap,y_base+2*fuzz,z_top+gap],anchor=BOTTOM+CENTER);
    move([+(x_holder/2+w4+gap)-w4/2,-fuzz,z_holder-z_top-z_foot-gap])
       cuboid([w4+2*gap,y_base+2*fuzz,z_top+gap],anchor=BOTTOM+CENTER);
  }
}

// --- final object   -----------------------------------------------------------

xrot(-90) dl_holder();   // rotated for printing
