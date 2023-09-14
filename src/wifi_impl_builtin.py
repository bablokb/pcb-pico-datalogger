# ----------------------------------------------------------------------------
# wifi_impl_builtin.py: Wifi-implementation for builtin wifi
#
# Author: Bernhard Bablok
# License: GPL3
#
# Website: https://github.com/bablokb/pcp-pico-datalogger
#
# ----------------------------------------------------------------------------

import board
import time
import socketpool
import adafruit_requests

from log_writer import Logger
from secrets import secrets

class WifiImpl:
  """ Wifi-implementation for MCU with integrated wifi """

  # --- constructor   --------------------------------------------------------

  def __init__(self):
    """ constructor """

    self.logger = Logger()                 # reuse global settings

    if not hasattr(secrets,'channel'):
      secrets.channel = 0
    if not hasattr(secrets,'timeout'):
      secrets.timeout = None

    self._radio = None

  # --- initialze and connect to AP and to remote-port   ---------------------

  def connect(self):
    """ initialize connection """

    import wifi
    self._radio = wifi.radio
    self.logger.print("connecting to %s" % secrets.ssid)
    retries = secrets.retry
    while True:
      try:
        wifi.radio.connect(secrets.ssid,
                           secrets.password,
                           channel = secrets.channel,
                           timeout = secrets.timeout
                           )
        break
      except:
        self.logger.print("could not connect to %s" % secrets.ssid)
        retries -= 1
        if retries == 0:
          raise
        time.sleep(1)
        continue
    self.logger.print("connected to %s" % secrets.ssid)
    pool = socketpool.SocketPool(wifi.radio)
    self._requests = adafruit_requests.Session(pool)

  # --- return implementing radio   -----------------------------------------

  @property
  def radio(self):
    """ return radio """
    return self._radio

  # --- execute get-request   -----------------------------------------------

  def get(self,url):
    """ process get-request """

    return self._requests.get(url)

  # --- no specific deep-sleep mode   ---------------------------------------

  def deep_sleep(self):
    """ disable radio """

    try:                                       # wifi might not be imported
      self._radio.enabled = False
    except:
      pass
