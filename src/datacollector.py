#-----------------------------------------------------------------------------
# Basic data-collection program. This program is a framework that
#
#   - initializes hardware (RTC, display, SD, sensors)
#   - update RTCs (time-server->) external-RTC -> internal-RTC
#   - collects data
#   - execute post collection tasks, e.g.
#     - update the display
#     - save data
#   - set next wakeup alarm
#   - turn power off
#
# Author: Bernhard Bablok
#
# Website: https://github.com/pcb-pico-datalogger
#-----------------------------------------------------------------------------

import time

# init timings
g_ts = []
g_ts.append((time.monotonic(),None))

import gc
import board
import alarm
import os
import builtins

from digitalio import DigitalInOut, Direction, Pull

# import for SD-card
import sdcardio
import storage

# imports for i2c and rtc
import busio

# sleep-helper
from sleep import TimeSleep

# pin definitions
import pins

g_ts.append((time.monotonic(),"import"))

# --- early configuration of the log-destination   ---------------------------

try:
  from log_config import g_logger
except:
  from log_writer import Logger
  g_logger = Logger('console')

g_ts.append((time.monotonic(),"log-config"))

# imports for rtc
from rtc_ext.ext_base import ExtBase

# pin definitions
import pins

# --- default configuration is in config.py on the pico.   -------------------

class Settings:
  def import_config(self):
    """ import config-module and make variables attributes """
    import config

    # set defaults
    self.HAVE_PM       = True
    self.SHUTDOWN_HIGH = True
    self.HAVE_RTC      = "PCF8523(1)"
    self.HAVE_SD       = True
    self.HAVE_I2C0     = False
    self.HAVE_I2C_MP   = None
    self.HAVE_LIPO     = False
    self.HAVE_DISPLAY  = None
    self.HAVE_LORA     = False
    self.HAVE_OLED     = None

    # RTC related
    self.NET_UPDATE  = True    # update RTC from time-server if time is invalid
    self.SAVE_WAKEUP = False   # save wakup-time on SD (workaround for buggy batteries)

    #sample-mode and interval/time-table
    self.STROBE_MODE = True      # strobe-mode or continuous-mode
    self.INTERVAL    = 900       # interval (in seconds)
    self.TIME_TABLE  = None      # no time-table

    # test (dev) mode settings
    self.TEST_MODE        = False
    self.BLINK_START      = 3      # blink n times  before sensor-readout
    self.BLINK_TIME_START = 0.5    # blink duration before sensor-readout
    self.BLINK_END        = 5      # blink n times  after  sensor-readout
    self.BLINK_TIME_END  = 0.25    # blink duration after  sensor-readout

    # various
    self.CSV_FILENAME        = "/sd/log_{ID}_{YMD}.csv"
    self.CSV_HEADER_EXTENDED = False
    self.SENSORS_CSV_ONLY    = ""
    self.SHOW_UNITS          = True   # show units in dump_data
    self.SIMPLE_UI           = False  # use tabular UI
    self.FONT_DISPLAY        = 'DejaVuSansMono-Bold-18-subset'

    # update configuration variables from imported config.py
    for var in dir(config):
      if var[0] != '_':
        g_logger.print(f"{var}={getattr(config,var)}")
        setattr(self,var,getattr(config,var))
    config = None
    if not hasattr(self,"LOGGER_TITLE"):
      self.LOGGER_TITLE = f"{self.LOGGER_ID}: {self.LOGGER_NAME}"

    if hasattr(self,"HAVE_PCB"):   # compatibility to old configurations
      self.HAVE_PM = self.HAVE_PCB
      if not self.HAVE_PCB and not hasattr(config,"HAVE_RTC"):
        # HAVE_PCB==False and HAVE_RTC not set
        HAVE_RTC = None

    gc.collect()

g_config = Settings()
g_config.import_config()

g_ts.append((time.monotonic(),"settings"))

# --- main application class   -----------------------------------------------

class DataCollector():
  """ main application class """

  # --- initialize I2C-busses   ----------------------------------------------

  def _init_i2c(self):
    """ create list of I2C-busses """

    # Standard busses 0 and 1. Bus 0 is shared with UART, so we check
    # the configuration before creating it.
    try:
      self.i2c = [None,busio.I2C(pins.PIN_SCL1,pins.PIN_SDA1)]
    except:
      g_logger.print("could not create i2c1")
      self.i2c = [None,None]
    if g_config.HAVE_I2C0:
      try:
        self.i2c[0] = busio.I2C(pins.PIN_SCL0,pins.PIN_SDA0)
      except:
        g_logger.print("could not create i2c0 although configured, check wiring!")

    # create busses behind a multiplexer
    if g_config.HAVE_I2C_MP:
      import adafruit_tca9548a
      for spec in g_config.HAVE_I2C_MP.split():
        name,loc = spec.rstrip(')').split('(')
        try:
          bus,addr = loc.split(',')
        except:
          bus = loc
          addr = '0x70'
        bus = self.i2c[int(bus)]
        addr = int(addr,16)
        if name[-2:] == '46' or name[-3:] == '46A':
          i2c_mp = adafruit_tca9548a.PCA9546A(bus,addr)
        else:
          i2c_mp = adafruit_tca9548a.TCA9548A(bus,addr)
        g_logger.print(f"adding {len(i2c_mp)} I2C-busses from {name}")
        for i2cbus in i2c_mp:
          self.i2c.append(i2cbus)
    if g_config.TEST_MODE:
      g_logger.print(f"setup: free memory after create i2c-busses: {gc.mem_free()}")

  # --- hardware-setup   -----------------------------------------------------

  def setup(self):
    """ create hardware-objects """

    # save LiPo status
    self.with_lipo = g_config.HAVE_LIPO

    # pull CS of display high to prevent it from floating
    if hasattr(pins,"PIN_INKY_CS"):
      self._cs_display = DigitalInOut(pins.PIN_INKY_CS)
      self._cs_display.switch_to_output(value=True)

    # early setup of SD-card (in case we send debug-logs to sd-card)
    self.spi = None
    if g_config.HAVE_SD:
      self.spi = busio.SPI(pins.PIN_SD_SCK,pins.PIN_SD_MOSI,pins.PIN_SD_MISO)
      sdcard     = sdcardio.SDCard(self.spi,pins.PIN_SD_CS,1_000_000)
      self.vfs   = storage.VfsFat(sdcard)
      storage.mount(self.vfs, "/sd")
      g_ts.append((time.monotonic(),"sd-mount"))
      if g_config.TEST_MODE:
        g_logger.print(f"setup: free memory after sd-mount: {gc.mem_free()}")

    # create self.i2c (list of I2C-busses)
    self._init_i2c()

    # Initialise RTC if configured.
    if g_config.HAVE_RTC:
      rtc_spec = g_config.HAVE_RTC.split('(')
      rtc_name = rtc_spec[0]
      rtc_bus  = int(rtc_spec[1][0])
    else:
      rtc_name = None
      rtc_bus  = 0

    try:
      self.rtc = ExtBase.create(rtc_name,self.i2c[rtc_bus],
                                net_update=g_config.NET_UPDATE)
      if rtc_name == "PCF8523":
        if pins.PCB_VERSION > 0:
          self.rtc.rtc_ext.high_capacitance = True  # uses a 12.5pF capacitor
        if self.with_lipo:
          self.rtc.rtc_ext.power_managment = 0b001  # direct switchover Vdd<Vbat
        else:
          self.rtc.rtc_ext.power_managment = 0b000  # Vdd<Vbat and Vdd < Vth

      # update RTC, fallback to wakeup time on SD if necessary
      rc = self.rtc.update()                 # (time-server->)ext-rtc->int-rtc
      if not rc and g_config.HAVE_SD and getattr(g_config,'SAVE_WAKEUP',False):
        try:
          with open("/sd/next_wakeup", "rt") as f:
            wakeup = f.readline()
            self.rtc.update(int(wakeup))
          g_logger.print("restored RTC from wakeup-time on SD")
        except:
          g_logger.print("could not restore RTC from SD")

      if g_config.TEST_MODE:
        g_logger.print(f"setup: free memory after rtc-update: {gc.mem_free()}")
    except Exception as ex:
      # could not detect or configure RTC
      g_logger.print(f"error while configuring RTC: {ex}")
      g_config.HAVE_RTC = None
    g_ts.append((time.monotonic(),"rtc-update"))

    # display
    if hasattr(pins,"PIN_INKY_CS"):
      self._cs_display.deinit()
    if g_config.HAVE_DISPLAY:
      from display import Display
      self.display = Display(g_config,self.spi)
      if g_config.TEST_MODE:
        g_logger.print(f"setup: free memory after create display: {gc.mem_free()}")

    g_ts.append((time.monotonic(),"display-config"))

    # just for testing
    if g_config.TEST_MODE and hasattr(pins,"PIN_LED"):
      self._led            = DigitalInOut(pins.PIN_LED)
      self._led.direction  = Direction.OUTPUT

    self.sd_status = "_"
    self.lora_status = "~"

    #configure sensors
    if g_config.TEST_MODE:
      g_logger.print(f"setup: free memory before config sensors: {gc.mem_free()}")
    self._configure_sensors()
    if g_config.TEST_MODE:
      g_logger.print(f"setup: free memory after config sensors: {gc.mem_free()}")

    g_ts.append((time.monotonic(),"sensor-config"))

  # --- configure sensors   ---------------------------------------------------

  def _configure_sensors(self):
    """ configure sensors """

    self.formats = []
    sensors_ignore = g_config.SENSORS_CSV_ONLY
    sensors_ignore = sensors_ignore.split(" ")
    self.csv_header = f"#ID: {g_config.LOGGER_ID}\n#Location: {g_config.LOGGER_LOCATION}\n"
    column_headings = "#ts"
    self._sensors = []

    # parse sensor specification. Will fail if i2c0 is requested, but not
    # configured
    self._sensor_init_time = 0
    for spec in g_config.SENSORS.split(' '):
      # ignore fully qualified spec for display
      csv_only = True if spec in sensors_ignore else False
      # spec is sensor(addr,bus) or sensor(bus,addr) with bus and/or addr optional
      # defaults for normal case without addr/bus
      spec   = spec.split('(')
      sensor = spec[0]
      addr   = None
      i2c    = list(self.i2c)
      # check for parameters
      if len(spec) > 1:
        spec = spec[1][:-1].split(',')   # remove trailing ) and split
        # parse parameters: can be (addr), (bus), (addr,bus) or (bus,addr)
        para1 = spec.pop(0).upper()
        if not 'X' in para1:             # first parameter is a bus
          bus = int(para1)
          i2c = [None]*len(self.i2c)     # don't search the other busses
          i2c[bus] = self.i2c[bus]
          addr = None                    # init address as None
        else:                            # first parameter is an address
          addr = int(para1,16)
        if len(spec):                    # we have a second parameter
          if addr:                       # we already have an address, so
            bus = int(spec[0])           # this must be a bus
            i2c = [None]*len(self.i2c)   # don't search the other busses
            i2c[bus] = self.i2c[bus]
          else:                          # first parameter was bus, so
            addr = int(spec[0],16)       # second parameter is address

      sensor_module = builtins.__import__("sensors."+sensor,
                                          None,None,[sensor.upper()],0)
      sensor_class = getattr(sensor_module,sensor.upper())
      _sensor = sensor_class(g_config,i2c,addr,None)
      _sensor.ignore = csv_only
      self._sensors.append(_sensor.read)
      if not csv_only:
        self.formats.extend(_sensor.formats)
      column_headings += f",{_sensor.headers}"
      self._sensor_init_time = max(self._sensor_init_time,
                                   getattr(_sensor,"init_time",0))

    # insert extended header
    if g_config.CSV_HEADER_EXTENDED:
      for f_nr,field in enumerate(column_headings[1:].split(',')):
        self.csv_header += f"# {f_nr:2d}: {field}\n"

    # add column headings as last line of csv-header
    self.csv_header += f"{column_headings}"

  # --- blink   --------------------------------------------------------------

  def blink(self, count=1, blink_time=0.25):
    for _ in range(count):
      self._led.value = 1
      time.sleep(blink_time)
      self._led.value = 0
      time.sleep(blink_time)

  # --- collect data   -------------------------------------------------------

  def collect_data(self):
    """ collect sensor data """

    # wait globally for the request init-time, instead of multiple sleeps
    # within the sensor-wrapper
    if self._sensor_init_time:
      g_logger.print(f"sensor initialization time: {self._sensor_init_time}s ...")
      TimeSleep.light_sleep(duration=self._sensor_init_time)
      g_logger.print("...done")
      self._sensor_init_time = 0

    ts = time.localtime()
    ts_str = f"{ts.tm_year}-{ts.tm_mon:02d}-{ts.tm_mday:02d}T{ts.tm_hour:02d}:{ts.tm_min:02d}:{ts.tm_sec:02d}"
    self.data = {
      "ts":     ts,
      "ts_str": ts_str
      }
    self.record = ts_str

    if g_config.TEST_MODE:
      g_logger.print(f"sensors: free memory before readout: {gc.mem_free()}")
    self.values = []
    for read_sensor in self._sensors:
      rec = read_sensor(self.data,self.values)
      self.record += f",{rec}"
    if g_config.TEST_MODE:
      g_logger.print(f"sensors: free memory after readout: {gc.mem_free()}")
    gc.collect()

  # --- check if file already exists   --------------------------------------

  def file_exists(self, filename):
    """ check if file exists """
    try:
      status = os.stat(filename)
      return True
    except OSError:
      return False

  # --- run configured tasks   -----------------------------------------------

  def run_tasks(self):
    """ parse task-config and run tasks """

    if not hasattr(g_config,"TASKS"):
      return

    for task in g_config.TASKS.split(" "):
      if g_config.TEST_MODE:
        g_logger.print(f"{task}: free memory before task: {gc.mem_free()}")
      try:
        g_logger.print(f"{task}: loading")
        task_module = builtins.__import__("tasks."+task,None,None,["run"],0)
        g_logger.print(f"{task} starting")
        task_module.run(g_config,self)
        g_ts.append((time.monotonic(),f"{task}"))
        g_logger.print(f"{task} ended")
      except Exception as ex:
        g_logger.print(f"{task} failed: exception: {ex}")
      if g_config.TEST_MODE:
        g_logger.print(f"{task}: free memory after task: {gc.mem_free()}")
      task_module = None
      gc.collect()

  # --- print timings   ------------------------------------------------------

  def print_timings(self):
    """ print timings """

    if not g_config.TEST_MODE:
      return

    g_logger.print(60*"-")
    for i in range(1,len(g_ts)):
      g_logger.print(f"{g_ts[i][0]-g_ts[i-1][0]:0.3f} ({g_ts[i][1]})")
    g_logger.print(f"{g_ts[-1][0]-g_ts[0][0]:0.3f} (total)")
    g_logger.print(60*"-")

  # --- read battery   -------------------------------------------------------

  def read_battery(self):
    """ read battery if not already done """

    if "battery" not in self.data:
      from sensors.battery import BATTERY
      bat = BATTERY(g_config,None)
      bat.read(self.data,self.values)

  # --- set next wakeup   ----------------------------------------------------

  def configure_wakeup(self):
    """ configure rtc for next wakeup """

    # don't wake up on low LiPo
    if self.with_lipo and self.data["battery"] < 3.0:
      g_logger.print("!!! LiPo voltage low: wakeup disabled !!!")
      # prevent that goto_sleep() fails (unlikely to be called anyhow)
      self.wakeup = ExtRTC.get_alarm_time(d=365)
      return

    if g_config.TIME_TABLE:
      self.wakeup = ExtBase.get_table_alarm(g_config.TIME_TABLE)
    else:
      self.wakeup = ExtBase.get_alarm_time(s=g_config.INTERVAL)

    if not g_config.STROBE_MODE:  # only calculate wakeup, don't set alarm
      return

    self.rtc.set_alarm(self.wakeup)   # might be a noop

    # save alarm time to SD
    if g_config.HAVE_SD and getattr(g_config,'SAVE_WAKEUP',False):
      try:
        with open("/sd/next_wakeup", "wt") as f:
          f.write(f"{time.mktime(self.wakeup)}\n")
        g_logger.print("next wakeup-time saved to SD")
      except:
        g_logger.print("could not save next wakeup-time to SD")

  # --- shutdown   -----------------------------------------------------------

  def shutdown(self):
    """ tell the power-controller to cut power """

    if g_config.HAVE_PM and hasattr(pins,"PIN_DONE"):
      g_logger.print("signal power-off")

      if type(pins.PIN_DONE) == DigitalInOut:
        self.done           = pins.PIN_DONE
      else:
        self.done           = DigitalInOut(pins.PIN_DONE)

      # The following statement is not reliable: even if value is False
      # it might create a short High while switching. This does not
      # matter, "worst case" would be that it already turns of power.
      self.done.switch_to_output(value=not g_config.SHUTDOWN_HIGH)

      self.done.value = g_config.SHUTDOWN_HIGH
      time.sleep(0.001)
      self.done.value = not g_config.SHUTDOWN_HIGH
      time.sleep(2)
    else:
      g_logger.print("ignoring shutdown (don't have PM or PIN_DONE undefined)")

  # --- cleanup   ------------------------------------------------------------

  def cleanup(self):
    """ cleanup ressources """

    self._cs_display.deinit()
    self.spi.deinit()

  # --- run datacollector   ------------------------------------------------

  def run(self):
    """ run datacollector """
    global g_logger, g_config, g_ts

    g_logger.print("main program start")
    if g_config.TEST_MODE:
      TimeSleep.light_sleep(duration=5)       # give console some time to initialize
      g_ts.append((time.monotonic(),"delay test-mode"))

    g_logger.print("setup of hardware")
    g_ts.append((time.monotonic(),"DataCollector()"))
    self.setup()
    self.print_timings()

    while True:
      if g_config.TEST_MODE:
        if hasattr(pins,"PIN_LED"):
          self.blink(count=g_config.BLINK_START,
                     blink_time=g_config.BLINK_TIME_START)
        # reset timings
        g_ts = []
        g_ts.append((time.monotonic(),None))

      self.collect_data()
      g_ts.append((time.monotonic(),"collect data"))
      # always read battery (if not yet done as part of sensors)
      self.read_battery()

      if g_config.TEST_MODE and hasattr(pins,"PIN_LED"):
        self.blink(count=g_config.BLINK_END, blink_time=g_config.BLINK_TIME_END)

      # run tasks after data-collection
      self.run_tasks()
      self.print_timings()

      # configure wakeup-time
      self.configure_wakeup()

      # check for low LiPo
      if self.with_lipo and self.data["battery"] < 3.1:
        # prevent continuous-mode
        break

      if not g_config.STROBE_MODE:
        g_logger.print(
          f"continuous mode: next measurement " +
          f"at {ExtBase.print_ts(None,self.wakeup)}")
        if g_config.INTERVAL < 61:
          TimeSleep.light_sleep(until=self.wakeup)
        else:
          TimeSleep.deep_sleep(until=self.wakeup)
      else:
        break

    self.shutdown()

    # we are only here if
    # - we use strobe-mode
    # - we are running on USB-power
    # - we are running on a v2-PCB or without PCB
    # Switch to deep-sleep (better than nothing)
    g_logger.print(
      f"wakeup from deep-sleep at {ExtBase.print_ts(None,self.wakeup)}")
    TimeSleep.deep_sleep(until=self.wakeup)
