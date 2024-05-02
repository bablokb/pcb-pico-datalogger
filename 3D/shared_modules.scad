// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) for datalogger (shared modules).
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// ---------------------------------------------------------------------------

include <dimensions.scad>
include <BOSL2/std.scad>

// --- cutout   --------------------------------------------------------------

module cutout(width1,width2,depth,h,pos) {
  if (pos == FRONT) {
    xrot(-90) prismoid(size1=[width1,h], size2=[width2,h], h=depth,anchor=BACK);
  } else if (pos == BACK) {
    xrot(90) prismoid(size1=[width1,h], size2=[width2,h], h=depth,anchor=FRONT);
  } else if (pos == LEFT) {
    yrot(90) prismoid(size1=[h,width1], size2=[h,width2], h=depth,anchor=RIGHT);
  } else if (pos == RIGHT) {
    yrot(-90) prismoid(size1=[h,width1], size2=[h,width2], h=depth,anchor=LEFT);
  }
}
