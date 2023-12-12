Data-Collector Program
======================

The data-collector program is in subdirectory `src`. It is implemented
in CircuitPython.

The program is a framework with these main blocks:

  - setup of base-hardware (including RTC, display, sd-card)
  - configuration of sensors
  - data-collection
  - execution of post-collection tasks (e.g. save to sd, update display)
  - configuration of next wake-up alarm


Installation
------------

You should install the current version of CircuitPython for your device.
Downloads and instructions are available from the CircuitPython homepage
<www.circuitpython.org>.

After installation of CP and a power-cycle, mount the device if not done
automatically by your operating system.

Copy everything below `src` to the device. Linux-users should use something
like

    rsync -av -L \
          --no-owner --no-group --delete --modify-window=2 \
          src/ /path-to-your-device
    sync

(note the `/` at the end of `src/`). Using `rsync` will speed up repeated
copies considerably.


Updates
-------

The datalogger program will run only for a very short time and then will
shutdown the system. This makes updates difficult, you must hit CTRL-C in
the console just at the right moment.

There is one trick that solves the problem: run the device without an
inserted SD-card. This will crash the program and will allow you to update
the device.


Configuration
-------------

Configuration needs various extra files. These files are not tracked
by github and are therefore not part of the repository:

  - `config.py`: copy `src/config_template.py` to `src/config.py` and adapt to your needs
  - `secrets.py`: see below
  - `log_config.py`: copy `src/log_config_template.py` to `src/log_config.py`

The configuration-variables should be self explainatory.

You also have to provide a file `src/secrets.py` with your WLAN-credentials.
Rename `src/sec_template.py` and adapt it to your environment:

    class Settings:
      pass
    
    secrets = Settings()
    
    secrets.ssid      = 'my_wlan_ssid'
    secrets.password  = 'my_very_secret_password'
    secrets.retry     = 2
    secrets.debugflag = False
    #secrets.channel   = 6         # optional
    #secrets.timeout   = 10        # optional
    
    secrets.time_url = 'http://worldtimeapi.org/api/ip'

Note that WLAN-access is only necessary for intial time-configuration.
Don't forget to remove `secrets.py` after rtc-initialization if you
want your WLAN-credentials to be secret.


CSV-Filename
------------

The name of the generated csv-file with the data is dynamic. It uses
the configuration `CSV_FILENAME`, which can contain the following
placeholders:

  - `{ID}`: the logger-id
  - `{YMD}`: the date in the format `yyyy-mm-dd`
  - `{Y}`: the year in the format `yyyy`
  - `{M}`: the month in the format `mm`
  - `{D}`: the day in the format `dd`

`CSV_FILENAME` must start with  `/sd/`.


Logging
-------

The file `log_config.py` (see above) defines the destination of technical
log messages. Various options exist:

  - no output
  - output to the console
  - output to the file `messages.log` on the sd-card
  - output to UART-serial

The last option lets you monitor the system even when running on batteries.


Admin-Mode
----------

Administration mode can only be entered during start or reset. When the
device is powered down, hold SW-A and press the on-button. If running in
continuous mode, hold SW-A and press the reset-button.


Initial RTC-Setup
-----------------

You have to set the time of the RTC to a valid value. If you use a coin-cell
backup-battery, this is a one-time task.

The following prerequisites are necessary:

  - access to a WLAN with correctly configured credentials (see above)
  - configuration-variable in `src/main.py` is `NET_UPDATE = TRUE`.

The program checks at startup if the time of the external RTC is valid and
sensible (details in `src/lib/rtc_ext/base.py`). If not, it tries to
fetch the time from an internet-timeserver. Note that this does not
use NTP (which always fetches UTC-time), but timeapi.org which provides
local time.

Timeapi.org is a free but unreliable service, so you might have to retry
if it is temporarily not available.
