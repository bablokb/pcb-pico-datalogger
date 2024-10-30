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
import ssl
import adafruit_requests

from log_writer import Logger
from secrets import secrets
from singleton import singleton

@singleton
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

    self._radio    = None
    self._pool     = None
    self._requests = None
    self._socket   = None

  # --- initialze and connect to AP and to remote-port   ---------------------

  def connect(self):
    """ initialize connection """

    if not self._radio:
      import wifi
      self._radio = wifi.radio
    if not self._radio.enabled:
      self._radio.enabled = True
      self._pool = None
      self._requests = None

    if self._pool:
      return

    self.logger.print("connecting to %s" % secrets.ssid)
    retries = secrets.retry
    while True:
      try:
        self._radio.connect(secrets.ssid,
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
    self._pool = socketpool.SocketPool(self._radio)
    self._requests = None

  # --- return requests-object   --------------------------------------------

  def _get_request(self):
    """ return requests-object """
    if not self._requests:
      self._requests = adafruit_requests.Session(self._pool,
                                                 ssl.create_default_context())
    return self._requests

  # --- return implementing radio   -----------------------------------------

  @property
  def radio(self):
    """ return radio """
    return self._radio

  # --- execute get-request   -----------------------------------------------

  def get(self,url):
    """ process get-request """
    self.connect()
    self.logger.print(f"wifi: get({url})")
    return self._get_request().get(url)

  # --- execute transmit-command   ------------------------------------------

  def sendto(self,data,udp_ip,udp_port):
    """ send to given destination """
    self.connect()
    self.logger.print(f"wifi: send to {udp_ip}:{udp_port}")
    with self._pool.socket(family=socketpool.SocketPool.AF_INET,
                           type=socketpool.SocketPool.SOCK_DGRAM) as socket:
      socket.sendto(data,(udp_ip,udp_port))

  # --- no specific deep-sleep mode   ---------------------------------------

  def deep_sleep(self):
    """ disable radio """

    try:                                       # wifi might not be imported
      self._radio.enabled = False
    except:
      pass
