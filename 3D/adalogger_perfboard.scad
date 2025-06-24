//-----------------------------------------------------------------------------
// 3D-Model (OpenSCAD): enclosure for Adalogger on a perfboard.
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/pcb-pico-datalogger
//---------------------------------------------------------------------------

include <dimensions.scad>
include <BOSL2/std.scad>
include <pcb_holder.scad>

x_perfboard = 100.0;
y_perfboard =  50.2;
z_perfboard =   4.6;
z_support   =   4.6;

pcb_holder(x_pcb = x_perfboard,
           y_pcb = y_perfboard,
	        z_pcb = z_perfboard,
	        z_support = z_support,
          screws = [0,0,0,0]);
