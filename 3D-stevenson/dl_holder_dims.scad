// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) adapter for stevenson-screen: shared dimensions.
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// -----------------------------------------------------------------------------

include <dimensions.scad>

x_pcb = 56;
z_pcb = 70;

r_pcb =  1.5;       // for M2.5 screws
o_pcb =  3.0;       // offset screw-holes

x_base = x_pcb + 2*w2;   // increase dimensions for printing
y_base = 2.6;
z_base = z_pcb + 2*w2;

x_foot = 40;   // clearance foot
z_foot = 10;

x_pico = w4;
y_pico =  2.0;
z_pico = 55.0;
o1_pico = 9.8;
o2_pico = 8.0;
