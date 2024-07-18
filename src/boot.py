#-----------------------------------------------------------------------------
# Pico initialization file after hard reset. This file will check if
# certain GPs are low (e.g. button SW-A is pressed) and will enter
# special modes (e.g. admin-mode, broadcast-mode).
#
# Author: Bernhard Bablok
#
# Website: https://github.com/pcb-pico-datalogger
#-----------------------------------------------------------------------------

import time
import board
import storage
import supervisor
from digitalio import DigitalInOut, Pull, Direction

import pins
from config import TEST_MODE

# --- configure hardware   ---------------------------------------------------

if hasattr(pins,"PIN_SWA"):
  switch_a = DigitalInOut(pins.PIN_SWA)
  switch_a.direction = Direction.INPUT
  switch_a.pull = Pull.UP
else:
  switch_a = None

if hasattr(pins,"PIN_SWB"):
  switch_b = DigitalInOut(pins.PIN_SWB)
  switch_b.direction = Direction.INPUT
  switch_b.pull = Pull.UP
else:
  switch_b = None

if hasattr(pins,"PIN_SWC"):
  switch_c = DigitalInOut(pins.PIN_SWC)
  switch_c.direction = Direction.INPUT
  switch_c.pull = Pull.UP
else:
  switch_c = None

if hasattr(pins,"PIN_SWD"):
  led_d = DigitalInOut(pins.PIN_SWD)
  led_d.direction = Direction.OUTPUT
else:
  led_d = None

# --- blink LED on button-press   --------------------------------------------

if led_d and (TEST_MODE or
              (switch_a and not switch_a.value) or
              (switch_b and not switch_b.value) or
              (switch_c and not switch_c.value)):
  for _ in range(3):
    led_d.value = True
    time.sleep(0.15)
    led_d.value = False
    time.sleep(0.15)

# --- check if switch A is pressed and if so, enter admin-mode   -------------

if switch_a and not switch_a.value:
  # make flash writable
  storage.remount("/",False)
  supervisor.set_next_code_file("admin.py",sticky_on_reload=True)
  supervisor.reload()

# --- check if switch B is pressed and if so, enter broadcast-mode   ---------

if switch_b and not switch_b.value:
  supervisor.set_next_code_file("broadcast.py",sticky_on_reload=True)
  supervisor.reload()
