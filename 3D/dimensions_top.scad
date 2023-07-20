// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) for datalogger: dimensions for top.scad
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// -----------------------------------------------------------------------------

zsize = 10;                // height above pcb 

x1_uart = 13+xdelta;       // cutout UART (top side, from left)
x2_uart = 25+xdelta;

y1_adc  = 11+ydelta;       // cutout ADC (right side, from top)
y2_adc  = 20.5+ydelta;

y1_bat  = 50+ydelta;       // cutout BAT+reset (right side, from top)
y2_bat  = 83+ydelta;

x1_sd   = 40+xdelta;       // cutout sd-card+on (bottom side, from left)
x2_sd   = 73+xdelta;

x_uart = -xsize/2 + x1_uart + (x2_uart-x1_uart)/2;
y_uart = ysize/2 + w4 - y_cutout/2;

x_adc = +xsize/2 + w4 - x_cutout/2;
y_adc = ysize/2 - y1_adc - (y2_adc-y1_adc)/2;

x_bat = +xsize/2 + w4 - x_cutout/2;
y_bat = ysize/2 - y1_bat - (y2_bat-y1_bat)/2;

x_sd = -xsize/2 + x1_sd + (x2_sd-x1_sd)/2;
y_sd = -ysize/2 - w4 + y_cutout/2;
