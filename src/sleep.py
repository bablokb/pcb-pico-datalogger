#-----------------------------------------------------------------------------
# Optimized sleep:
#
#   - use light-sleep/deep-sleep
#   - reduce cpu-frequency
#   - support duration and time-point
#
# Notes:
#
#   - changing CPU-frequency is not yet supported with 8.0.5 and only
#     available on RP2040 boards
#   - the alarm-module is currently not implemented for RP2350
#
# Author: Bernhard Bablok
#
# Website: https://github.com/pcb-pico-datalogger
#-----------------------------------------------------------------------------

import time

try:
  import alarm
  HAVE_ALARM = True
except:
  HAVE_ALARM = False
import microcontroller

# --- class Sleep   ----------------------------------------------------------

class TimeSleep:
  """ minimal wrapper class for light and deep sleep """

  CPU_FREQ_LOW   = 20000000
  cpu_freq_sleep = None

  @classmethod
  def _sleep_impl(cls,duration=0,until=None,sleep_func=None):
    """ implement sleep """

    # convert until to seconds since epoch
    if until:
      if isinstance(until,int):
        ep_alarm = until
      else:
        ep_alarm = time.mktime(until)

    if not HAVE_ALARM:
      # fallback to time.sleep
      if until:
        time.sleep(ep_alarm-time.time())
      else:
        time.sleep(duration)
      return

    if until:
      time_alarm = alarm.time.TimeAlarm(epoch_time=ep_alarm)
    elif duration >= 2:
      time_alarm = alarm.time.TimeAlarm(
        monotonic_time=time.monotonic()+duration)
    else:
      time.sleep(duration)
      return

    if TimeSleep.cpu_freq_sleep:
      try:
        old_freq = microcontroller.cpu.frequency
        microcontroller.cpu.frequency = TimeSleep.cpu_freq_sleep
        have_freq = True
      except:
        have_freq = False

    sleep_func(time_alarm)   # the code below won't execute with deep-sleep!

    if TimeSleep.cpu_freq_sleep and have_freq:
      try:
        microcontroller.cpu.frequency = old_freq
      except:
        pass

  # --- light sleep   ----------------------------------------------------------

  @classmethod
  def light_sleep(cls,duration=0,until=None):

    """ sleep the given duration or until given time-point """
    TimeSleep._sleep_impl(duration=duration,until=until,
                      sleep_func=alarm.light_sleep_until_alarms)

  # --- deep sleep   ----------------------------------------------------------

  @classmethod
  def deep_sleep(cls,duration=0,until=None):

    """ sleep the given duration or until given time-point """
    TimeSleep._sleep_impl(duration=duration,until=until,
                      sleep_func=alarm.exit_and_deep_sleep_until_alarms)
