// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD): generic pcb-holder.
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/motor-turntable
// ---------------------------------------------------------------------------

include <dimensions.scad>
include <BOSL2/std.scad>

z_pcb_def = 1.6;
z_sup_def = 2.0;

// --- helper functions to expose dimensions   -------------------------------

function pcb_holder_dim(x) = x + 2*gap + 2*w4;
function pcb_holder_z(z_pcb=z_pcb_def,z_support=z_sup_def) = z_pcb+z_support+b;

// --- supports   ------------------------------------------------------------

module supports(x_size,y_size,x_sup,y_sup,z_sup,sups) {
  x = x_sup + w4 + gap;
  y = y_sup + w4 + gap;
  x_off = x_size/2-x/2;
  y_off = y_size/2-y/2;
  if (sups[0]) {
    move([-x_off,+y_off,0]) cuboid([x,y,z_sup],anchor=BOTTOM+CENTER);
  }
  if (sups[1]) {
    move([+x_off,+y_off,0]) cuboid([x,y,z_sup],anchor=BOTTOM+CENTER);
  }
  if (sups[2]) {
    move([+x_off,-y_off,0]) cuboid([x,y,z_sup],anchor=BOTTOM+CENTER);
  }
  if (sups[3]) {
    move([-x_off,-y_off,0]) cuboid([x,y,z_sup],anchor=BOTTOM+CENTER);
  }
}

// --- screws   ----------------------------------------------------------------

module screws(d,x_size,y_size,h_size,xo_screw,yo_screw,screws) {
  x_off = x_size/2-xo_screw;
  y_off = y_size/2-yo_screw;
  r     = d/2 - gap/2;
  if (screws[0]) {
    move([-x_off,+y_off,0]) cyl(r=r,h=h_size,anchor=BOTTOM+CENTER);
  }
  if (screws[1]) {
    move([+x_off,+y_off,0]) cyl(r=r,h=h_size,anchor=BOTTOM+CENTER);
  }
  if (screws[2]) {
    move([+x_off,-y_off,0]) cyl(r=r,h=h_size,anchor=BOTTOM+CENTER);
  }
  if (screws[3]) {
    move([-x_off,-y_off,0]) cyl(r=r,h=h_size,anchor=BOTTOM+CENTER);
  }
}

// --- pcb-holder   ------------------------------------------------------------

module pcb_holder(
         x_pcb, y_pcb, z_pcb=z_pcb_def,
         x_support = 6.0, y_support = 6.0, z_support = z_sup_def, supports = [1,1,1,1],
         x_screw = 3, y_screw = 3, d_screw = 2.5, screws = [1,1,1,1]) {

  // box dimensions
  x_case = pcb_holder_dim(x_pcb);
  y_case = pcb_holder_dim(y_pcb);

  difference() {
    union() {
      // base plate
      cuboid([x_case,y_case,b],anchor=BOTTOM+CENTER);
      // suport and screws
      supports(x_case,y_case,x_support,y_support,b+z_support,supports);
      screws(d_screw,x_pcb,y_pcb,b+z_support+z_pcb,x_screw,y_screw,screws);
      // walls around pcb
      rect_tube(size=[x_case,y_case],wall=w4,h=b+z_pcb+z_support,anchor=BOTTOM+CENTER);
    }
  }
}
