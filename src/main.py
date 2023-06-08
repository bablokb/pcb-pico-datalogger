#-----------------------------------------------------------------------------
# Basic data-collection program. This program will
#
#   - initialize hardware
#   - update RTCs (time-server->) external-RTC -> internal-RTC
#   - collect data
#   - update the display
#   - save data
#   - set next wakeup alarm
#   - turn power off
#
# Author: Bernhard Bablok
#
# Website: https://github.com/pcb-pico-datalogger
#-----------------------------------------------------------------------------

import time
import board
import alarm
from digitalio import DigitalInOut, Direction, Pull
from analogio import AnalogIn

# import for SD-card
import storage
import adafruit_sdcard

# imports for i2c and rtc
import busio
from rtc_ext.pcf8523 import ExtPCF8523 as ExtRTC

# imports for sensors
import adafruit_ahtx0          # AHT20
import adafruit_mcp9808
from pimoroni_circuitpython_ltr559 import Pimoroni_LTR559

# --- configuration   --------------------------------------------------------

TEST_MODE   = False       # set to FALSE for a productive setup
NET_UPDATE  = True        # update RTC from time-server if time is invalid
OFF_MINUTES = 1           # turn off for x minutes
BLINK_TIME  = 0.25        # blink time of LED
BLINK_START = 0           # blink n times before start of data-collection
BLINK_END   = 0           # blink n times after finish of data-collection

HAVE_SD      = True
HAVE_DISPLAY = False
HAVE_AHT20   = True
HAVE_LTR559  = False
HAVE_MCP9808 = False

# --- pin-constants (don't change unless you know what you are doing)   ------

PIN_DONE = board.GP4   # connect to 74HC74 CLK
PIN_SDA  = board.GP2   # connect to RTC
PIN_SCL  = board.GP3   # connect to RTC

PIN_SD_CS   = board.GP22
PIN_SD_SCK  = board.GP18
PIN_SD_MOSI = board.GP19
PIN_SD_MISO = board.GP16

class DataCollector():
  """ main application class """

  # --- hardware-setup   -----------------------------------------------------

  def setup(self):
    """ create hardware-objects """

    # i2c - RTC and sensors
    i2c = busio.I2C(PIN_SCL,PIN_SDA)
    self.rtc = ExtRTC(i2c,net_update=NET_UPDATE)  # this will also clear interrupts
    self.rtc.rtc_ext.high_capacitance = True      # the pcb uses a 12.5pF capacitor
    self.rtc.update()                             # (time-server->)ext-rtc->int-rtc

    # just for testing
    if TEST_MODE:
      self._led            = DigitalInOut(board.LED)
      self._led.direction  = Direction.OUTPUT

    self.done           = DigitalInOut(PIN_DONE)
    self.done.direction = Direction.OUTPUT
    self.done.value     = 0

    # sensors
    if HAVE_AHT20:
      self.aht20 = adafruit_ahtx0.AHTx0(i2c)
    if HAVE_LTR559:
      self.ltr559 = Pimoroni_LTR559(i2c)
    if HAVE_MCP9808:
      self.mcp9808 = adafruit_mcp9808.MCP9808(i2c)

    # spi - SD-card and display
    if HAVE_SD:
      spi    = busio.SPI(PIN_SD_SCK,PIN_SD_MOSI,PIN_SD_MISO)
      cs     = DigitalInOut(PIN_SD_CS)
      sdcard = adafruit_sdcard.SDCard(spi,cs)
      vfs    = storage.VfsFat(sdcard)
      storage.mount(vfs, "/sd")

  # --- blink   --------------------------------------------------------------

  def blink(self,count=1):
    for _ in range(count):
      led.value = 1
      time.sleep(BLINK_TIME)
      led.value = 0
      time.sleep(BLINK_TIME)
    
  # --- collect data   -------------------------------------------------------

  def collect_data(self):
    """ collect sensor data """

    ts = time.localtime()
    ts_str = f"{ts.tm_year}-{ts.tm_mon:02d}-{ts.tm_mday:02d}T{ts.tm_hour:02d}:{ts.tm_min:02d}:{ts.tm_sec:02d}"
    self.data = {
      "ts":   ts_str
      }
    self.record = ts_str
    self.read_battery()
    if HAVE_AHT20:
      self.read_AHT20()
    if HAVE_LTR559:
      self.read_LTR559()
    if HAVE_MCP9808:
      self.read_MCP9808()

  # --- read battery level   -------------------------------------------------

  def read_battery(self):
    """ read battery level """

    adc = AnalogIn(board.VOLTAGE_MONITOR)
    level = adc.value *  3 * 3.3 / 65535
    adc.deinit()
    self.data["battery"] = level
    self.record += f",{level:0.1f}"

  # --- read AHT20   ---------------------------------------------------------

  def read_AHT20(self):
    t = self.aht20.temperature
    h = self.aht20.relative_humidity
    self.data["aht20"] = {
      "temp": t,
      "hum":  h
    }
    self.record += f",{t:0.1f},{h:0.0f}"

  # --- read LTR559   --------------------------------------------------------

  def read_LTR559(self):
    lux = self.ltr559.lux
    self.data["ltr559"] = {
      "lux": lux
    }
    self.record += f",{lux:0.1f}"

  # --- read MCP9808   -------------------------------------------------------

  def read_MCP9808(self):
    t = self.mcp9808.temperature
    self.data["mcp9808"] = {
      "temp": t
    }
    self.record += f",{t:0.1f}"

  # --- save data   ----------------------------------------------------------

  def save_data(self):
    """ save data """
    if HAVE_SD:
        with open("/sd/data.csv", "a") as f:
            print(self.record)
            f.write(f"{self.record}\n")
    else:
        # Ideally, this would write to internal space... but that would require a remount.
        print("Warning: No SD card in use.")
        print(f"{self.record}\n")
  
  # --- update display   -----------------------------------------------------

  def update_display(self):
    """ update display """
    pass

  # --- set next wakeup   ----------------------------------------------------

  def configure_wakeup(self):
    """ configure rtc for next wakeup """
    self.rtc.set_alarm(self.rtc.get_alarm_time(m=OFF_MINUTES))

  # --- shutdown   -----------------------------------------------------------

  def shutdown(self):
    """ tell the power-controller to cut power """

    self.done.value = 1
    time.sleep(0.2)
    self.done.value = 0
    time.sleep(2)

# --- main program   ---------------------------------------------------------

print("main program start")
if TEST_MODE:
  time.sleep(5)                        # give console some time to initialize
print("setup of hardware")

app = DataCollector()
app.setup()

if TEST_MODE:
  app.blink(count=BLINK_START)

app.collect_data()
app.save_data()

if TEST_MODE:
  app.blink(count=BLINK_END)

if HAVE_DISPLAY:
  app.update_display()

app.configure_wakeup()
app.shutdown()
