// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) for datalogger: dimensions for top.scad
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// -----------------------------------------------------------------------------

zsize = 10;                // height above pcb 

d_screw   = 2.5 + gap/2;     // diameter screw
d_screw_h = 4.0 + gap/2;     // diameter screw-head

x1_uart = 13+xdelta;       // cutout UART (top side, from left)
x2_uart = 25+xdelta;
x_uart  = xsize/2 - x1_uart - (x2_uart-x1_uart)/2;     // offset

y1_adc  = 11+ydelta;       // cutout ADC (right side, from top)
y2_adc  = 20.5+ydelta;
y_adc   = ysize/2 - y1_adc - (y2_adc-y1_adc)/2;        // offset

y1_bat  = 50.5+ydelta;       // cutout BAT (right side, from top)
y2_bat  = 60+ydelta;
y_bat   = ysize/2 - y1_bat - (y2_bat-y1_bat)/2;        // offset
z_bat   = 6.0;

x1_sd   = 56+xdelta;       // cutout sd-card (bottom side, from left)
x2_sd   = 73+xdelta;
x_sd    = -xsize/2 + (xsize-x2_sd) + (x2_sd-x1_sd)/2;  // offset
z_sd = 2.3;

x1_i2c  = 32.0;            // cutout I2C + pico
x2_i2c  = 57.0;
d_i2c   = 21.0;
z_i2c   = 6.6;
x_i2c   = -xsize/2 + (xsize-x2_i2c) + (x2_i2c-x1_i2c)/2;  // offset
y_i2c   = ysize/2 + w4 - d_i2c/2;
