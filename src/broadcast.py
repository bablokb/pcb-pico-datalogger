#-----------------------------------------------------------------------------
# Start broadcast-mode: run LoRa communication to optimize antenna setup
#
# Broadcast-data is in CSV-format:
#     B,<ts>,<id>,<nr>,<node>
# with a fixed "B", followed by the timestamp, logger-id, packet-number
# and LoRa-node-id.
#
# Author: Bernhard Bablok
#
# Website: https://github.com/pcb-pico-datalogger
#-----------------------------------------------------------------------------

import board
import wifi
import time
import busio
from digitalio import DigitalInOut, Pull, Direction

import displayio

from adafruit_bitmap_font import bitmap_font
from adafruit_display_text import label as label
from vectorio import Rectangle

try:
  from log_config import g_logger
except:
  from log_writer import Logger
  g_logger = Logger('console')
g_logger.print("!!! Starting in Broadcast-Mode !!!")

from settings import Settings
g_config = Settings(g_logger)
g_config.import_config()

import pins

import hw_helper
from lora import LORA
from rtc_ext.ext_base import ExtBase
from sleep import TimeSleep

# --- init environment   -----------------------------------------------------

if hasattr(pins,"PIN_SWD"):
  switch_d = DigitalInOut(pins.PIN_SWD)
  switch_d.direction = Direction.OUTPUT
  switch_d.value = True
elif hasattr(pins,'PIN_LED'):
  switch_d = DigitalInOut(pins.PIN_LED)
  switch_d.direction = Direction.OUTPUT
  switch_d.value = True

# --- application class for broadcast-mode   ---------------------------------

class Broadcast:
  """ main application class for broadcast-mode """

  # --- constructor   --------------------------------------------------------

  def __init__(self):
    """ constructor """
    self._display = None
    self._lines   = [""]*5
    self._pnr     = 0
    self._pok     = 0

    self._init_spi()
    self._init_display()
    self._lora = LORA(g_config,self.spi1)

    self._i2c  = hw_helper.init_i2c(pins,g_config,g_logger)
    self._rtc  = hw_helper.init_rtc(pins,g_config,self._i2c)

    self._oled = hw_helper.init_oled(self._i2c,g_config,g_logger)
    if self._oled:
      self._display   = self._oled.get_display()
      self._textlabel = self._oled.get_textlabel()

    if self._oled or not self._display:
      self.interval = getattr(g_config,'BROADCAST_INT',10)
    else:
      # set update-interval to at least 60 seconds to protect display
      self.interval = max(getattr(g_config,'BROADCAST_INT',10),60)
      self._last_ref = 0

  # --- create SPI   ---------------------------------------------------------

  def _init_spi(self):
    if hasattr(pins,"PIN_SD_SCK"):
      self.spi = busio.SPI(pins.PIN_SD_SCK,pins.PIN_SD_MOSI,pins.PIN_SD_MISO)
    if pins.PIN_SD_SCK == pins.PIN_LORA_SCK:
      if hasattr(self,"spi"):
        self.spi1 = self.spi
      else:
        self.spi1 = busio.SPI(pins.PIN_LORA_SCK,pins.PIN_LORA_MOSI,
                              pins.PIN_LORA_MISO)

    else:
      self.spi1 = busio.SPI(pins.PIN_LORA_SCK,pins.PIN_LORA_MOSI,
                            pins.PIN_LORA_MISO)

  # --- standard display   -------------------------------------------------

  def _init_display(self):
    """ initialize standard display """

    if g_config.HAVE_DISPLAY:
      from display import Display

      g_logger.print("initializing display...")
      self._display = Display(g_config,self.spi).get_display()

      font = bitmap_font.load_font(f"fonts/{g_config.FONT_DISPLAY}.bdf")
      group = displayio.Group()
      shader = displayio.Palette(2)
      shader[0] = 0xFFFFFF
      shader[1] = 0x000000
      group.append(Rectangle(pixel_shader=shader,x=0,y=0,
                             width=self._display.width,
                             height=self._display.height,
                             color_index=0))
      heading = label.Label(font=font,color=shader[1],scale=2,
                            text='Broadcast-Mode',anchor_point=(0.5,0))
      heading.anchored_position = (self._display.width/2,0)
      group.append(heading)

      self._textlabel = label.Label(font=font,color=shader[1],scale=1,
                                    text="",line_spacing=1.0,
                                    anchor_point=(0,0))
      self._textlabel.anchored_position = (2,heading.height+15)
      group.append(self._textlabel)

      self._display.root_group = group
      g_logger.print("... finished")

  # --- update info   --------------------------------------------------------

  def update_info(self,lines,row=0):
    """ update info-text """

    for line in lines:
      if row >= len(self._lines):
        break
      self._lines[row] = line
      row += 1

  # --- update display   -----------------------------------------------------

  def update_display(self):
    """ update display """
    if self._display:
      self._textlabel.text = "\n".join(self._lines)
      if not self._oled:
        # refresh only once per minute
        wait_for_ref = max(0,60-(time.monotonic()-self._last_ref))
        g_logger.print(f"waiting {wait_for_ref}s for display refresh")
        TimeSleep.light_sleep(
          duration=max(0,self.interval-(time.monotonic()-self._last_ref)))
        self._last_ref = time.monotonic()
      g_logger.print(f"refreshing display")
      self._display.refresh()
      if not self._oled:
        time.sleep(3)             # e-ink needs some additional time

  # --- clear display   ------------------------------------------------------

  def clear(self):
    """ clear display """
    self._lines = [""]*len(self._lines)
    if self._display:
      self._textlabel.text = ""
      if self._oled:
        self._display.refresh()

  # --- update time   --------------------------------------------------------

  def update_time(self):
    """ update time """

    self.update_info(["Updating time..."])
    new_time = self._lora.get_time(timeout=3)
    if new_time:
      g_logger.print(f"Broadcast: updating device-time from gateway-time")
      self._rtc.update(new_time)
      self.update_info(["... ok!",self._rtc.print_ts(None,new_time)],
                       row=1)
    else:
      self.update_info(["... failed!"],row=1)
    self.update_display()

  # --- send broadcast-packet   ----------------------------------------------

  def send_packet(self):
    """ send broadcast packet """

    self._pnr += 1

    # update time on display (will not show on 128x32)
    self.update_info([self._rtc.print_ts(None,time.localtime())],row=4)

    # send packet and receive response
    start = time.monotonic()
    packet = self._lora.broadcast(self._pnr,timeout=self.interval)
    duration = time.monotonic()-start
    if not packet:
      self.update_info([f"packet {self._pnr} failed!",
                        f"count: {self._pok}/{self._pnr} ok",
                        f"RTT: {duration}s"],row=1)
      return

    # try to decode packet
    try:
      data,my_snr,my_rssi = packet
      nr,gw_snr,gw_rssi = data.split(',')
      nr      = int(nr)
      gw_snr  = round(float(gw_snr),1)
      gw_rssi = int(gw_rssi)
    except Exception as ex:
      g_logger.print(
          f"Broadcast: packet {self._pnr}: wrong data-format: {data}")
      nr = 0    # will trigger failed-message

    # check packet
    try:
      if nr != self._pnr:
        g_logger.print(
          f"Broadcast: received wrong packet ({nr} but expected {self._pnr})")
        self.update_info([f"packet {self._pnr} failed!",
                          f"count: {self._pok}/{self._pnr} ok",
                          f"RTT: {duration}s"],row=1)
      else:
        self._pok += 1
        g_logger.print(
          f"Broadcast: packet {self._pnr}: SNR(gw), RSSI(gw): {gw_snr:0.1f}, {gw_rssi}dBm")
        g_logger.print(
          f"Broadcast: packet {self._pnr}: SNR(node), RSSI(node): {my_snr:0.1f}, {my_rssi}dBm")
        g_logger.print(
          f"Broadcast: packet {self._pnr}: roundtrip-time: {duration}s")
        self.update_info([f"SNR: {gw_snr:0.1f},RSSI:{gw_rssi}dBm",
                          f"count: {self._pok}/{self._pnr} ok",
                          f"RTT: {duration}s"],row=1)
    except Exception as ex:
      g_logger.print(f"excepion: {ex}")   # not expected
    return

# --- main program start   ---------------------------------------------------

app = Broadcast()
app.update_time()
TimeSleep.light_sleep(duration=5)

app.clear()
app.update_info([f"Node: {g_config.LORA_NODE_ADDR}, ID: {g_config.LOGGER_ID}"])

start = time.monotonic()
while True:
  stime = max(0,app.interval - (time.monotonic()-start))
  g_logger.print(f"Broadcast: next cycle in  {stime}s...")
  TimeSleep.light_sleep(duration=stime)
  app.send_packet()
  app.update_display()
  start = time.monotonic()
