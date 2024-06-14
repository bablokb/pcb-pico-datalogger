// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) for datalogger: dimensions for footer and sensor-holder.
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// -----------------------------------------------------------------------------

z_case_b = b + z_sup + z_pcb;       // bottom (10.4)
z_case_t = b + b + zsize;           // top (12.8)
z_case   = z_case_b + z_case_t;

x_bat_holder = 73.0 + 2*gap;
y_bat_holder = 33.7 + 2*gap + 2*w4;
z_bat_holder = 20.0;

//x_foot = ysize + 20;
x_foot = x_bat_holder+4*w4;    // for testing
y_foot = y_bat_holder + 2*w4;
// echo("Diff y_foot-z_case: ",y_foot-z_case);
z_foot = b + z_bat_holder;

//x_foot_add = 40;
//y_foot_add = 20;
x_foot_add = 0;
y_foot_add = 0;
