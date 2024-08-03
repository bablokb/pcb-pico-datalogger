// -----------------------------------------------------------------------------
// 3D-Model (OpenSCAD) adapter for stevenson-screen: shared dimensions.
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
// -----------------------------------------------------------------------------

$fa = 1;
$fs = 0.4;
$fn= $preview ? 32 : 128;

fuzz = 0.01;
w2 = 0.86;                 // 2 walls
w4 = 1.67;                 // 4 walls
gap = 0.2;                 // gap pcb to case

b = 1.4;               // base thickness
