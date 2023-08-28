#-----------------------------------------------------------------------------
# Task: send data using LoRa (adafruit_rfm9x.py)
#
# Authors: Syed Omer Ali, Björn Haßler
# Author: Bernhard Bablok
#
# Website: https://github.com/pcb-pico-datalogger
#-----------------------------------------------------------------------------

from log_writer import Logger
g_logger = Logger()

from digitalio import DigitalInOut, Direction, Pull
import busio
import time
import adafruit_rfm9x
import pins

# --- helper class for LoRa   ------------------------------------------------

class LORA:
  def __init__(self,config):
    """ constructor """

    # don't catch exceptions, main.py will handle that

    g_logger.print("Setting up SPI1")
    spi1 = busio.SPI(pins.PIN_LORA_SCK,pins.PIN_LORA_MOSI,pins.PIN_LORA_MISO)
    pin_cs                = DigitalInOut(pins.PIN_LORA_CS)
    pin_reset             = DigitalInOut(pins.PIN_LORA_RST)
    pin_enable            = DigitalInOut(pins.PIN_LORA_EN)
    pin_enable.direction  = Direction.OUTPUT

    g_logger.print("Enabling rfm9x on SPI1")
    pin_enable.value = 1
    time.sleep(config.LORA_ENABLE_TIME)
    g_logger.print("Initializing rfm9x on SPI1")
    self.rfm9x = adafruit_rfm9x.RFM9x(
      spi1, pin_cs,pin_reset,config.LORA_FREQ,baudrate=100000)
      
    g_logger.print("configuring rfm9x on spi")
    self.rfm9x.enable_crc = True
    #self.rfm9x.tx_power = 23
    self.rfm9x.ack_delay = 0.1
    self.rfm9x.node = config.LORA_NODE_ADDR                 # node or this device
    self.rfm9x.destination = config.LORA_BASE_ADDR  # base station or destination
    self.rfm9x.ack_wait = 0.5
    self.rfm9x.ack_retries = 3

    # --- transmit command   ----------------------------------------------

    def transmit(self, header, string):
      """ send data """
      g_logger.print("LoRa transmit")
      message = self.rfm9x.send_with_ack(bytes(string, "UTF-8"))
      g_logger.print("Success? "+str(message))

def run(config,app):
  """ send data using LoRa """
  lora = LORA(config)
  lora.transmit(app.csv_header,app.record)
