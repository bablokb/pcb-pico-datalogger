// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) for datalogger: shared dimensions.
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// -----------------------------------------------------------------------------

$fa = 1;
$fs = 0.4;
$fn= $preview ? 32 : 48;

fuzz = 0.01;
w2 = 0.86;                 // 2 walls Prusa3D
w4 = 1.67;                 // 4 walls Prusa3D
gap = 0.2;                 // gap pcb to case

x_pcb = 80;                // pcb-dimensions
y_pcb = 90;
z_pcb = 1.6;
r_pcb = 3.0;               // corner radius
b     = 1.4;               // base thickness

xdelta = gap;
ydelta = gap;
xsize = x_pcb+2*xdelta;    // inner size
ysize = y_pcb+2*ydelta;

y1_lora = 46+ydelta;       // cutout LoRa (left side, from top)
y2_lora = 57+ydelta;
yw_lora = 7;               // inner length cutout
d_lora  = 6 + w4;          // depth of cutout

// calculations for cutouts
x_cutout = xdelta+w4-gap;
y_cutout = ydelta+w4-gap;

x_lora = -xsize/2 - w4 + d_lora/2;
y_lora = ysize/2 - y1_lora - (y2_lora-y1_lora)/2;
z_lora = 4.8;
