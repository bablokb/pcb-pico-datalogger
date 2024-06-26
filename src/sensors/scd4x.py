#-----------------------------------------------------------------------------
# Base class for Sensor definitions for SCD40/SCD41. Don't use this class
# directly!
#
# Naming convention:
#   - filenames in lowercase (scd4x.py)
#   - class name the same as filename in uppercase (SCD4X)
#   - the constructor must take four arguments (config,i2c,addr,spi)
#     and probe for the device
#   - the read-method must update the data and return a string with the
#     values for the csv-record
#
# Author: Bernhard Bablok
#
# Website: https://github.com/pcb-pico-datalogger
#-----------------------------------------------------------------------------

SAMPLES = 2
DISCARD = True                # only keep last reading

from log_writer import Logger
g_logger = Logger()

import time
import adafruit_scd4x

class SCD4X:
  # we don't use timestamps on the display ...
  formats = ["CO2:", "{0}", "T/SCD:", "{0:.1f}°C","H/SCD:", "{0:.0f}%rH"]
  headers = 'CO2 ppm,T/SCD °C,H/SCD %rH'

  def __init__(self,config,i2c,addr=None,spi=None):
    """ constructor """

    if hasattr(config,"SCD4X_SAMPLES"):
      self.SAMPLES = config.SCD4X_SAMPLES
    else:
      self.SAMPLES = SAMPLES
    if hasattr(config,"SCD4X_DISCARD"):
      self.DISCARD = config.SCD4X_DISCARD
    else:
      self.DISCARD = DISCARD

    if not self.DISCARD:
      self.headers = 't (1),CO2 ppm (1)'
      for i in range(1,self.SAMPLES):
        self.headers += f",t ({i+1}),CO2 ppm ({i+1})"
      self.headers += ',T/SCD °C,H/SCD %rH'

    self.scd4x = None
    for bus,nr in i2c:
      try:
        g_logger.print(f"testing {self.product} on i2c{nr}")
        self.scd4x = adafruit_scd4x.SCD4X(bus)
        g_logger.print(f"detected {self.product} on i2c{nr}")
        break
      except Exception as ex:
        g_logger.print(f"exception: {ex}")
    if not self.scd4x:
      raise Exception(f"no {self.product} detected. Check config/cabling!")

  def read_sensor(self):
    """ dummy method, must be implemented by subclass if necessary """
    pass

  def read(self,data,values):
    # take multiple readings
    csv_results = ""
    t0 = time.monotonic()
    for i in range(self.SAMPLES):
      g_logger.print(f"{self.product}: waiting for data...")
      while True:
        self.read_sensor()
        if self.scd4x.data_ready:
          t_rel = time.monotonic() - t0
          co2   = self.scd4x.CO2
          temp  = round(self.scd4x.temperature,1)
          hum   = round(self.scd4x.relative_humidity,0)
          g_logger.print(f"{self.product}: CO2 at {t_rel:.2f}: {co2}")
          if not self.DISCARD:
            csv_results += f",{t_rel:.2f},{co2}"
          break
        else:
          time.sleep(0.2)

    if self.DISCARD:
      # keep last reading
      csv_results = f",{co2}"
    csv_results += f",{temp:.1f},{hum:.0f}"
    
    # only show last reading on display
    data[self.product] = {
      "temp": temp,
      "hum":  hum,
      "co2":  co2
    }
    values.extend([None,co2])
    values.extend([None,temp])
    values.extend([None,hum])
    return csv_results[1:]
