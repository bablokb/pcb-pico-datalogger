// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) case (bottom) for datalogger.
//
// Sensor-holder (variant) for the top of the printed case.
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

TEST = false;
// dimensions plate in xy-plane
x_holder = 80;
y_holder = 80;
z_holder = TEST ? 0.8 : w4;

// offsets
scd40_off  = -28;
scd40_off1 = scd40_off - 8;
scd40_off2 = scd40_off + 8;
scd40_offy = -y_holder/2+38;

am2301_off  = 0;
am2301_offy = -y_holder/2+76;

ens160_off  = 27.5;
ens160_offy = -y_holder/2+46;

// cutouts
x_cutout = 6.5;
y_cutout = 13;
y_off    = y_cutout + 4;

d_screw   = 3.0 + 2*gap;

// --- cable-cutout   --------------------------------------------------------

module cutout() {
  cuboid([x_cutout,y_cutout,20],anchor=CENTER);
  ymove(y_off) cuboid([x_cutout,y_cutout,20],anchor=CENTER);
}

// --- sensor-plate   --------------------------------------------------------

module plate(rotate = 0) {
  xrot(rotate) zrot(-rotate) difference() {
    cuboid([x_holder,y_holder,z_holder],anchor=CENTER);
    // SCD40 screw-holes
    translate([scd40_off1,scd40_offy,0]) cylinder(h=20,d=d_screw,anchor=CENTER);
    translate([scd40_off2,scd40_offy,0]) cylinder(h=20,d=d_screw,anchor=CENTER);
    // AM2301B screw-hole
    translate([am2301_off,am2301_offy,0]) cylinder(h=20,d=d_screw,anchor=CENTER);
    // SEN160 screw-hole
    translate([ens160_off,ens160_offy,0]) cylinder(h=20,d=d_screw,anchor=CENTER);
    // cable-cutouts
    translate([scd40_off,-y_holder/2+y_cutout/2-fuzz,0]) cutout();
    translate([am2301_off,-y_holder/2+y_cutout/2-fuzz,0]) cutout();
    translate([ens160_off,-y_holder/2+y_cutout/2-fuzz,0]) cutout();
  }
}

// --- sensor-holder   -------------------------------------------------------

module sensor_holder() {
  // this is printed on the side, so change names
  height  = y_holder;
  xlength = z_bat_holder;
  union() {
    // the cover (top)
    cuboid([w4,z_case+2*w4+gap,height],anchor=BOTTOM+CENTER);
     // holder for sensors
    color("blue") ymove(z_case/2+0.5*w4+gap/2)
      xmove(w4/2-fuzz)
        translate([y_holder/2,0,x_holder/2]) plate(90);
     // holder for main sensor-case
     ymove(z_case/2+0.5*w4+gap/2)
        xmove(-xlength/4+fuzz)
          cuboid([xlength/2,w4,height],anchor=BOTTOM+CENTER);
     ymove(-z_case/2-0.5*w4-gap/2)
      xmove(-xlength/4+fuzz)
        cuboid([xlength/2,w4,height],anchor=BOTTOM+CENTER);
  }
}

// --- top-level object   ----------------------------------------------------

if (TEST) {
  // translate([x_holder,y_holder/2,0]) zrot(-90) ymove(-y_holder) plate();
  plate(0);
} else {
  sensor_holder();
}
