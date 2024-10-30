// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) adapter for stevenson-screen: holder for datalogger.
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// -----------------------------------------------------------------------------

include <dimensions.scad>
include <BOSL2/std.scad>

include <stevenson_holder_dims.scad>
include <dl_holder_dims.scad>
include <battery_cage_dims.scad>

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
    move([-(x_holder/2+w4+gap/2)+w4/2,-fuzz,-z_foot])
       cuboid([w4+gap,y_base+2*fuzz,z_bottom+gap],anchor=BOTTOM+CENTER);
    move([+(x_holder/2+w4+gap/2)-w4/2,-fuzz,-z_foot])
       cuboid([w4+gap,y_base+2*fuzz,z_bottom+gap],anchor=BOTTOM+CENTER);

    // cutouts for top_tube
    move([-(x_holder/2+w4+gap/2)+w4/2,-fuzz,z_holder-z_top-z_foot-gap])
       cuboid([w4+gap,y_base+2*fuzz,z_top+2*gap],anchor=BOTTOM+CENTER);
    move([+(x_holder/2+w4+gap/2)-w4/2,-fuzz,z_holder-z_top-z_foot-gap])
       cuboid([w4+gap,y_base+2*fuzz,z_top+2*gap],anchor=BOTTOM+CENTER);
  }
}

// --- final object   -----------------------------------------------------------

xrot(-90) dl_holder();   // rotated for printing
