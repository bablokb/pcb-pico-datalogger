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
include <dimensions_top.scad>
include <dimensions_bottom.scad>
include <dimensions_foot.scad>
include <shared_modules.scad>
include <BOSL2/std.scad>

// --- foot   ----------------------------------------------------------------

module foot() {
  // base foot with case-holder
  difference() {
    prismoid([x_foot+x_foot_add,y_foot+y_foot_add],[x_foot,y_foot],h=z_foot+w4,anchor=BOTTOM+CENTER,rounding=5);
    zmove(b) cuboid([x_bat_holder,y_bat_holder,z_bat_holder+fuzz],anchor=BOTTOM+CENTER);
    zmove(b+z_bat_holder) cuboid([x_bat_holder,y_bat_holder+2*w4+fuzz,w4+fuzz],anchor=BOTTOM+CENTER);
  }
}

// --- foot-cover   ----------------------------------------------------------

module foot_cover() {
  // this is printed on the side, so change names
  height  = x_bat_holder - 3*gap;
  xlength = z_bat_holder;
  difference() {
    union() {
      // the cover (top)
      cuboid([w4,y_foot,height],anchor=BOTTOM+CENTER);

      // sides of the cover
      ymove(y_foot/2-1.5*w4)
        xmove(xlength/2-fuzz)
          cuboid([z_bat_holder,w4,height],anchor=BOTTOM+CENTER);
      ymove(-y_foot/2+1.5*w4)
        xmove(xlength/2-fuzz)
          cuboid([xlength,w4,height],anchor=BOTTOM+CENTER);

      // holder for sensor-case
      ymove(z_case/2+0.5*w4+gap/2)
        xmove(-xlength/4+fuzz)
          cuboid([xlength/2,w4,height],anchor=BOTTOM+CENTER);
      ymove(-z_case/2-0.5*w4-gap/2)
        xmove(-xlength/4+fuzz)
          cuboid([xlength/2,w4,height],anchor=BOTTOM+CENTER);
    }
    // cutout for battery-connector
    ymove(-z_case/2 - z_bat/2 + z_case_t)  // move just to the rim and then back 
      zmove(height/2+y_bat)
        cuboid([2*w4,z_bat,y2_bat-y1_bat],anchor=CENTER);
  }
}

// --- top-level object   ----------------------------------------------------

foot();
//foot_cover();