// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) case (bottom) for datalogger.
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// -----------------------------------------------------------------------------

$fa = 1;
$fs = 0.4;
$fn = 48;

fuzz = 0.01;
w2 = 0.86;                 // 2 walls Prusa3D
w4 = 1.67;                 // 4 walls Prusa3D
gap = 0.5;                 // gap pcb to case

x_pcb = 80;               // pcb-dimensions
y_pcb = 90;
z_pcb = 1.6;
r_pcb = 3.0;               // corner radius

xy_sup = 8;
z_sup  = 13;                // hight of pcb-support (with display)
d_sup  = 2.5;               // diameter mounting-hole

xdelta = 5;
ydelta = 5;
xsize = x_pcb+2*xdelta;    // inner size
ysize = y_pcb+2*ydelta;

zsize = 15;                // height above pcb 
b     = 1.4;               // base thickness

y1_lora = 46+ydelta;       // cutout LoRa (left side, from top)
y2_lora = 57+ydelta;

x1_uart = 13+xdelta;       // cutout UART (top side, from left)
x2_uart = 25+xdelta;

y1_adc  = 11+ydelta;       // cutout ADC (right side, from top)
y2_adc  = 20.5+ydelta;

y1_bat  = 50+ydelta;       // cutout BAT+reset (right side, from top)
y2_bat  = 83+ydelta;

x1_sd   = 40+xdelta;       // cutout sd-card+on (bottom side, from left)
x2_sd   = 73+xdelta;

// calculations for cutouts
x_cutout = xdelta+w4-gap;
y_cutout = ydelta+w4-gap;

x_lora = -xsize/2 - w4 + x_cutout/2;
y_lora = ysize/2 - y1_lora - (y2_lora-y1_lora)/2;

x_uart = -xsize/2 + x1_uart + (x2_uart-x1_uart)/2;
y_uart = ysize/2 + w4 - y_cutout/2;

x_adc = +xsize/2 + w4 - x_cutout/2;
y_adc = ysize/2 - y1_adc - (y2_adc-y1_adc)/2;

x_bat = +xsize/2 + w4 - x_cutout/2;
y_bat = ysize/2 - y1_bat - (y2_bat-y1_bat)/2;

x_sd = -xsize/2 + x1_sd + (x2_sd-x1_sd)/2;
y_sd = -ysize/2 - w4 + y_cutout/2;
