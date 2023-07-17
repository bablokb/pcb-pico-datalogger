# ----------------------------------------------------------------------------
# DisplayFactory: Utility class with static methods to create display-objects
#
# See directory examples for example/test-programs.
#
# Author: Bernhard Bablok
# License: GPL3
#
# Website: https://github.com/bablokb/circuitpython-dataviews
#
# ----------------------------------------------------------------------------

import board
import busio
import displayio

class DisplayFactory:

  # --- return builtin-display   ---------------------------------------------

  @staticmethod
  def builtin():
    return board.DISPLAY

  # --- create SSD1306-based I2C-display   -----------------------------------

  @staticmethod
  def ssd1306(i2c=None,sda=None,scl=None,width=128,height=64,addr=0x3c):
    """ factory-method for SSD1306-based I2C-displays """

    from adafruit_displayio_ssd1306 import SSD1306

    if i2c is None:
      if sda is None:
        sda = board.SDA
      if scl is None:
        scl = board.SCL
      i2c = busio.I2C(sda=sda,scl=scl,frequency=400000)
    display_bus = displayio.I2CDisplay(i2c, device_address=addr)
    return SSD1306(display_bus,width=width,height=height)

  # --- create ST7789-based SPI-display   ------------------------------------

  @staticmethod
  def st7789(pin_dc,pin_cs,spi=None,pin_rst=None,
             height=135,width=240,rotation=270,rowstart=40,colstart=53):
    """ factory-method for ST7789-based SPI-displays """

    from adafruit_st7789 import ST7789

    if spi is None:
      spi = board.SPI()

    bus = displayio.FourWire(spi,command=pin_dc,chip_select=pin_cs,
                             reset=pin_rst)
    return ST7789(bus,width=width,height=height,rotation=rotation,
                  rowstart=rowstart,colstart=colstart)

  # --- cerate ST7789-based display for the Pimoroni Pico-Display-Pack  ------

  @staticmethod
  def display_pack(spi=None):
    """ factory-method for a Display-Pack display """

    if spi is None:
      spi = busio.SPI(clock=board.GP18,MOSI=board.GP19)
    return DisplayFactory.st7789(pin_dc=board.GP16,pin_cs=board.GP17,spi=spi)

  # --- create ST7735-based SPI-display   ------------------------------------

  @staticmethod
  def st7735(pin_dc,pin_cs,spi=None,pin_rst=None,
             height=128,width=160,rotation=90,bgr=True):
    """ factory-method for ST7735-based SPI-displays """

    from adafruit_st7735r import ST7735R       # SPI-TFT  display

    if spi is None:
      spi = board.SPI()

    bus = displayio.FourWire(spi,command=pin_dc,chip_select=pin_cs,
                             reset=pin_rst)
    return ST7735R(bus,width=width,height=height,
                   rotation=rotation,bgr=bgr)

  # --- create pygame-based display   ----------------------------------------

  @staticmethod
  def pygame(height=400,width=600,**kwargs):
    """ factory-method for pygame-based displays """

    from blinka_displayio_pygamedisplay import PyGameDisplay
    return PyGameDisplay(width=width,height=height,**kwargs)

  # --- create display for Pimoronis Pico Inky-Pack   -------------------------

  @staticmethod
  def inky_pack(spi=None):
    """ create display for InkyPack """

    import InkyPack

    if spi is None:
      spi = busio.SPI(board.GP18,MOSI=board.GP19)

    display_bus = displayio.FourWire(
      spi, command=board.GP20, chip_select=board.GP17,
      reset=board.GP21, baudrate=1000000
    )
    return InkyPack.InkyPack(display_bus,busy_pin=board.GP26)

  # --- create display for Adafruits Monochrom 2.13" e-ink   ------------------

  @staticmethod
  def ada_2_13_mono(pin_dc,pin_cs,spi=None,pin_rst=None,pin_busy=None,
                    rotation=270):
    """ create display for 2.13 monochrom display """

    import adafruit_ssd1675

    if spi is None:
      spi = board.SPI()

    display_bus = displayio.FourWire(
      spi, command=pin_dc, chip_select=pin_cs,
      reset=pin_rst, baudrate=1000000
    )
    return adafruit_ssd1675.SSD1675(display_bus, width=250, height=122,
                                    busy_pin=pin_busy, rotation=rotation)

  # --- create display for Adafruits monochrome 1.54" e-ink   ----------------

  @staticmethod
  def ada_1_54_mono(pin_dc,pin_cs,spi=None,pin_rst=None,pin_busy=None,
                    rotation=0):
    """
    create display for 1.54 monochrome display.
    Note that Adafruit also sells a SSD1681-variant of the display.
    """

    import adafruit_ssd1608

    if spi is None:
      spi = board.SPI()

    display_bus = displayio.FourWire(
      spi, command=pin_dc, chip_select=pin_cs,
      reset=pin_rst, baudrate=1000000
    )
    return adafruit_ssd1608.SSD1608(display_bus, width=200, height=200,
                                    busy_pin=pin_busy, rotation=rotation)

  # --- create display for Adafruits tri-color 1.5" e-ink   ------------------

  @staticmethod
  def ada_1_5_color(pin_dc,pin_cs,spi=None,pin_rst=None,pin_busy=None,
                    rotation=180):
    """ create display for 1.54 tri-color display """

    import adafruit_il0373

    if spi is None:
      spi = board.SPI()

    display_bus = displayio.FourWire(
      spi, command=pin_dc, chip_select=pin_cs,
      reset=pin_rst, baudrate=1000000
    )

    return adafruit_il0373.IL0373(display_bus,width=152,height=152,
                                  busy_pin=pin_busy,
                                  highlight_color=0xFF0000,
                                  rotation=roation)
