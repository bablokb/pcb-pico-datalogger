#-----------------------------------------------------------------------------
# Sensor definition for BH1750.
#
# Naming convention:
#   - filenames in lowercase (bh1750.py)
#   - class name the same as filename in uppercase (BH1750)
#   - the constructor must take four arguments (config,i2c,addr,spi)
#     and probe for the device
#   - the read-method must update the data and return a string with the
#     values for the csv-record
#
# Author: Bernhard Bablok
#
# Website: https://github.com/pcb-pico-datalogger
#-----------------------------------------------------------------------------

from log_writer import Logger
g_logger = Logger()

import adafruit_bh1750

class BH1750:
  formats = ["L/bhx0:", "{0:.0f}lx"]
  headers = 'L/bhx0 lx'

  def __init__(self,config,i2c,addr=None,spi=None):
    """ constructor """

    self.ignore = False
    self.bh1750 = None
    for nr,bus in enumerate(i2c):
      if not bus:
        continue
      try:
        g_logger.print(f"testing bh1750 on (i2c{nr},{addr})")
        self.bh1750 = adafruit_bh1750.BH1750(bus,0x23 if not addr else addr)
        g_logger.print(f"detected bh1750 on i2c{nr}")
        break
      except Exception as ex:
        g_logger.print(f"exception: {ex}")
    if not self.bh1750:
      raise Exception("no bh1750 detected. Check config/cabling!")

  def read(self,data,values):
    lux = round(self.bh1750.lux,0)
    data["bh1750"] = {
      "l": lux,
      self.formats[0]: self.formats[1].format(lux)
    }
    if not self.ignore:
      values.extend([None,lux])
    return f"{lux:.0f}"
