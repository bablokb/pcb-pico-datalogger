#-----------------------------------------------------------------------------
# Base class for external RTC-support.
#
# Author: Bernhard Bablok
#
# Website: https://github.com/pcb-pico-datalogger
#-----------------------------------------------------------------------------

import rtc
import time
from log_writer import Logger

# --- class ExtBase   ----------------------------------------------------------

class ExtBase:

  # --- constructor   --------------------------------------------------------

  def __init__(self,rtc_ext,wifi=None,net_update=False):
    """ constructor """

    self.logger      = Logger()            # reuse global settings
    self._rtc_ext    = rtc_ext
    self._wifi       = wifi
    self._net_update = net_update
    
    self._rtc_int = rtc.RTC()
    self._init_rtc()             # basic settings, clear alarms etc.

  # --- init wifi-object if not supplied   ----------------------------------

  def _init_wifi(self):
    """ init wifi with default implementation """

    from wifi_impl_builtin import WifiImpl
    self._wifi = WifiImpl()

  # --- check state of external RTC   ---------------------------------------

  def _check_rtc(self,r):
    """ check if RTC needs update, i.e. time is invalid """

    ts = r.datetime
    return not (ts.tm_year > 2022 and ts.tm_year < 2099 and
                ts.tm_mon > 0 and ts.tm_mon < 13 and
                ts.tm_mday > 0 and ts.tm_mday < 32 and
                ts.tm_hour < 25 and ts.tm_min < 60 and ts.tm_sec < 60)

  # --- init rtc   -----------------------------------------------------------

  def _init_rtc(self):
    """ init rtc, must be implemented by subclass """
    pass

  # --- check power-state   --------------------------------------------------

  def _lost_power(self):
    """ check for power-loss, must be plemented by subclass """
    pass

  # --- print struct_time   --------------------------------------------------

  def print_ts(self,label,ts):
    """ print struct_time """
    self.logger.print("%s: %04d-%02d-%02d %02d:%02d:%02d" %
          (label,ts.tm_year,ts.tm_mon,ts.tm_mday,
           ts.tm_hour,ts.tm_min,ts.tm_sec)
          )

  # --- update rtc   ---------------------------------------------------------

  def update(self):
    """ update rtc """

    # update internal rtc to valid date
    self.print_ts("rtc int",self._rtc_int.datetime)
    if self._check_rtc(self._rtc_int):
      if self._lost_power() or self._check_rtc(self._rtc_ext):
        self.print_ts("rtc ext",self._rtc_ext.datetime)
        if not self._fetch_time():
          self.logger.print("rtc-ext not updated from time-server")
          self.logger.print("setting rtc-ext to 2022-01-01 12:00:00")
          self._rtc_ext.datetime = time.struct_time((2022,1,1,12,00,00,5,1,-1))
        else:
          self.logger.print("rtc-ext updated from time-server")
      self.logger.print("updating internal rtc from external rtc")
      ext_ts = self._rtc_ext.datetime   # needs two statements!
      self._rtc_int.datetime = ext_ts
      self.print_ts("new time",ext_ts)
    else:
      # this will typically happen when starting from Thonny
      self.logger.print("assuming valid rtc int")
      int_ts = self._rtc_int.datetime   # needs two statements!
      self._rtc_ext.datetime = int_ts
      self.logger.print("updated external rtc from internal rtc")

  # --- update time from time-server   ---------------------------------------

  def _fetch_time(self):
    """ update time from time-server """

    if not self._net_update:
      self.logger.print("net_update not set")
      return False

    try:
      if not self._wifi:
        self._init_wifi()
      from secrets import secrets
      response = self._wifi.get(secrets.time_url).json()
      self._wifi.radio.enabled = False
    except Exception as ex:
      import traceback
      traceback.print_exception(ex)
      return False

    if 'struct_time' in response:
      self._rtc_ext.datetime = time.struct_time(tuple(response['struct_time']))
      return True

    current_time = response["datetime"]
    the_date, the_time = current_time.split("T")
    year, month, mday = [int(x) for x in the_date.split("-")]
    the_time = the_time.split(".")[0]
    hours, minutes, seconds = [int(x) for x in the_time.split(":")]

    year_day = int(response["day_of_year"])
    week_day = int(response["day_of_week"])
    week_day = 6 if week_day == 0 else week_day-1
    is_dst   = int(response["dst"])

    self._rtc_ext.datetime = time.struct_time(
      (year, month, mday, hours, minutes, seconds, week_day, year_day, is_dst))
    return True

  # --- get alarm-time   ----------------------------------------------------

  def get_alarm_time(self,d=None,h=None,m=None,s=None):
    """ get alarm-time. """

    # you can pass either a fixed date (alarm_time) or an interval
    # in days, hours, minutes, seconds
    sleep_time = 0
    if d is not None:
      sleep_time += d*86400
    if h is not None:
      sleep_time += h*3600
    if m is not None:
      sleep_time += m*60
    if s is not None:
      sleep_time += s
    if sleep_time == 0:
      return
    alarm_time = time.localtime(time.time() + sleep_time)
    self.print_ts("next rtc-wakeup",alarm_time)
    return alarm_time

  # --- get alarm from table   ---------------------------------------------

  def get_table_alarm(self,time_table):
    """ get alarm from time-table.
        This is a list of daily entries in
        the form
          [((h_start,h_end,h_incr),(m_start,m_end,m_incr)),
           ((h_start,h_end,h_incr),(m_start,m_end,m_incr)),
           ...
           ]
        with one entry per day (starting with Monday==0).
        x_start and x_end are inclusive, i.e. (0,23,1),(0,59,1) will trigger
        every minute.
        Replace (h_start,h_end,h_inc) with None to skip a day.
    """

    now_epoch = time.time()                          # seconds since 01/01/1970
    now_ts    = time.localtime(now_epoch)            # struct-time
    now_day   = (int(now_epoch/86400)+3) % 7         # 01/01/1970 is Thursday
    sod       = now_epoch - (now_ts.tm_hour*3600 +   # start of day
                             now_ts.tm_min*60 +
                             now_ts.tm_sec)

    self.logger.print("looking up next boot from time-table")
    self.print_ts("now",now_ts)
    self.logger.print(f"weekday: {now_day}")

    # search table (wrap-around, starting from current weekday)
    for i in range(now_day,now_day+7,1):
      wd_index = i % 7
      hours, minutes = time_table[wd_index]
      if not hours:       # no alarm on given day
        sod += 86400      # advance start of day
        continue
      (h_start,h_end,h_inc) = hours
      (m_start,m_end,m_inc) = minutes
      # iterate over all hours/minutes and find first time-point larger
      # than now
      for h in range(h_start,h_end+1,h_inc):
        for m in range(m_start,m_end+1,m_inc):
          alarm_epoch = sod + h*3600 + m*60
          if alarm_epoch > now_epoch:
            next_alarm = time.localtime(alarm_epoch)
            self.print_ts("next alarm",next_alarm)
            return next_alarm

      # no suitable time-point today. Try next day
      sod += 86400      # advance start of day

    # we should not be here
    raise Exception("no alarm from time-table")

  # --- set alarm   --------------------------------------------------------

  def set_alarm(self,alarm_time):
    """ set alarm. Must be implemented by subclass """
    pass

  # --- getter for RTCs   --------------------------------------------------

  @property
  def rtc_ext(self):
    """ return external RTC """
    return self._rtc_ext

  @property
  def rtc_int(self):
    """ return internal RTC """
    return self._rtc_int
