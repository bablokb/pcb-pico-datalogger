// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) case (bottom) for datalogger.
//
// Sensor-holder for the back of the printed case. This holder adds
// enclosures for the M5-Stack SCD4x-sensors and for a BMx280-sensor.
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
include <m5_holder.scad>
include <bmx280_holder.scad>

TEST = false;

// dimensions base-plate   -----------------------------------------------------

z_plate = 1.6;
z_plate_screw = 0.8;

x_horizontal = ysize+2*w4;
y_horizontal = 34.4;

yo_bmx280 = y_horizontal/2+bmx280_x_case/2-fuzz;
xo_bmx280 = x_horizontal/2 - bmx280_y_case/2 - 20;

x_off = x_horizontal/2 - (gap + w4 + r_pcb);
y_off = y_horizontal/2 - (gap + w4 + r_pcb);

x_co_button = 28;
y_co_button = 10;

// --- sensor-holder   -------------------------------------------------------

module sensor_holder() {
  difference() {
    union() {
      // horizontal plate
      cuboid([x_horizontal,y_horizontal,z_plate],anchor=BOTTOM+CENTER,
              rounding=r_pcb,edges="Z",except=FWD);
    }
    // screw-holes
    move([-x_off,y_off,-fuzz])
      cyl(h=z_plate,d=d_screw,anchor=BOTTOM+CENTER);
    move([+x_off,y_off,-fuzz])
      cyl(h=z_plate,d=d_screw,anchor=BOTTOM+CENTER);
    // screw-holes (heads)
    move([-x_off,y_off,z_plate_screw-fuzz])
      cyl(h=z_plate+2*fuzz,d=d_screw_h,anchor=BOTTOM+CENTER);
    move([+x_off,y_off,z_plate_screw-fuzz])
      cyl(h=z_plate+2*fuzz,d=d_screw_h,anchor=BOTTOM+CENTER);
    // buttons
    move([-x_horizontal/2+x_co_button/2-fuzz,-y_horizontal/2+y_co_button/2-fuzz,-fuzz])
      cuboid([x_co_button,y_co_button,z_plate+2*fuzz],anchor=BOTTOM+CENTER,
              rounding=r_pcb,edges=RIGHT+BACK);
  }
}

// --- m5 module   -----------------------------------------------------------

module m5() {
  move([x_off-y_m5/2,-r_pcb,z_plate-b_m5]) zrot(90) m5_holder();
}

// --- bmx280 module   -------------------------------------------------------

module bmx280() {
  move([xo_bmx280,-yo_bmx280,0]) zrot(90) bmx280_bottom();
}

// --- top-level object   ----------------------------------------------------

difference() {
  union() {
    sensor_holder();
    m5();
    bmx280();
  }
  // for testing prints
  //move([0,y_horizontal/2-3*r_pcb,-fuzz])
  // cuboid([2*x_horizontal,100,100],anchor=BOTTOM+BACK);
}
