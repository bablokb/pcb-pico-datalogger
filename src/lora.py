# -----------------------------------------------------------------------------
# LoRa TX and RX using adafruit_rfm9x.py in /lib folder.
#
# Authors: Syed Omer Ali, Björn Haßler
#
# Website: https://github.com/pcb-pico-datalogger
# -----------------------------------------------------------------------------

import digitalio
import busio
import time
import adafruit_rfm9x
import config
from log_writer import Logger
g_logger = Logger()
import board
from digitalio import DigitalInOut, Direction, Pull

class LORA:

    def __init__(self, freq=433.0):
        """ constructor """

        try:
            from log_config import g_logger
        except:
            from log_writer import Logger
            g_logger = Logger('console')


        # Lora interface (SPI, separate)
        PIN_LORA_CS = board.GP9
        PIN_LORA_RST = board.GP7
        PIN_LORA_EN = board.GP15
        PIN_LORA_SCK = board.GP10
        PIN_LORA_MOSI = board.GP11
        PIN_LORA_MISO = board.GP8

        NODE_ADDRESS = config.NODE_ADDRESS                      # Node address                                                                                                                                             
        BASE_STATION_ADDRESS = config.BASE_STATION_ADDRESS      # Base statio=n address                                                                                                                                    
        #LORA_RANGE_TEST = False             # If this is true, the logger does not undertake the usual functions, but just runs the range test.                                                        
        LORA_ENABLE_TIME = 0                 # wait time between switching on module and lora device registration                                                                                       
        LORA_WAIT_AFTER_SEND = 0             # wait time after sending     

        try:
            g_logger.print("Setting up SPI1")
            spi1 = busio.SPI(PIN_LORA_SCK, PIN_LORA_MOSI, PIN_LORA_MISO)
            CS = DigitalInOut(PIN_LORA_CS)
            RESET = DigitalInOut(PIN_LORA_RST)
            ENABLE = DigitalInOut(PIN_LORA_EN)
            ENABLE.direction  = Direction.OUTPUT
            #self.lora = lora.LORA(433.0, self._spi1, CS, RESET, ENABLE)
            # payload = self.csv_header + "\n" + self.record

            # Define pins connected to the chip, use these if wiring up the breakout according to the guide:
            g_logger.print("Enabling rfm9x on SPI1")
            ENABLE.value = 1
            time.sleep(LORA_ENABLE_TIME)
            g_logger.print("Initializing rfm9x on SPI1")
            self.rfm9x = adafruit_rfm9x.RFM9x(
                spi1, CS, RESET, freq, baudrate=100000)
            g_logger.print("Detected rfm9x on spi")
            # enable CRC checking
            self.rfm9x.enable_crc = True
            # You can however adjust the transmit power (in dB).  The default is 13 dB but
            # high power radios like the RFM95 can go up to 23 dB:
            #self.rfm9x.tx_power = 23
            # set delay before transmitting ACK (seconds)
            self.rfm9x.ack_delay = 0.1
            self.rfm9x.node = NODE_ADDRESS                 # node or this device
            self.rfm9x.destination = BASE_STATION_ADDRESS  # base station or destination
            self.rfm9x.ack_wait = 0.5 # (defaults to 0.5ms)
            #This sets the delay before retrying transmission of a packet after no ACK has been received.
            self.rfm9x.ack_retries = 3 # (defaults to 5 retries)
            #Set the number or retries to attempt if no ACK message is received.
        except Exception as ex:
            g_logger.print(f"exception: {ex}")

    def transmit(self, header, string):
        g_logger.print("LoRa transmit")
        message = self.rfm9x.send_with_ack(bytes(string, "UTF-8"))
        g_logger.print("Success? "+str(message))


