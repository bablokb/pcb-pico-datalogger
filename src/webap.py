# -------------------------------------------------------------------------
# Run AP together with a web-server.
#
# Author: Bernhard Bablok
# License: GPL3
#
# Website: https://github.com/bablokb/circuitpython-examples
#
# -------------------------------------------------------------------------

import gc
import os
import board
import wifi
import mdns
import socketpool
import ehttpserver

class WebAP(ehttpserver.Server):
  """ Access-point and webserver """

  # --- constructor   --------------------------------------------------------

  def __init__(self,config):
    """ constructor """
    self._config = config
    super().__init__(debug=config["debug"])
    self._import_config()
    self.add_route(self._handle_main,"/","GET")
    self.add_route(self._handle_favicon,"/favicon.ico","GET")
    self.add_route(self._handle_static,"/[^.]*\.(js|css|html)","GET")
    self.add_route(self._handle_save_config,"/save_config","POST")

# --- request-handler for /   -----------------------------------------------

  def _handle_main(self,path,query_params, headers, body):
    """ handle request for main-page """
    self.debug("_handle_main...")
    return ehttpserver.Response("<h1>Hello from WebAP!</h1>",
                            content_type="text/html")

  # --- request-handler for /favicon.ico   -----------------------------------

  def _handle_favicon(self,path,query_params, headers, body):
    """ handle request for favicon """
    self.debug("_handle_favicon...")
    return ehttpserver.Response("",status_code=400)

  # --- request-handler for static files   -----------------------------------

  def _handle_static(self,path,query_params, headers, body):
    """ handle request for static-files """
    self.debug(f"_handle_static for {path}")
    return ehttpserver.FileResponse(f"/www/{path}")

  # --- request-handler for /save_config   -----------------------------------

  def _handle_save_config(self,path,query_params, headers, body):
    """ handle request for /save_config """
    self.debug(f"_handle_save_config...\n{body}")
    self._export_config(body)
    return ehttpserver.Response("<h1>configuration saved</h1>",
                                content_type="text/html")

  # --- import configuration   -----------------------------------------------

  def _import_config(self):
    """ import config-module and create json-model """
    import config           # TODO: change to config later after merge
    self._model = {}
    for var in dir(config):
      if var[0] != '_':
        if var in ["SENSORS", "TASKS"]:
          self._model[var] = getattr(config,var).split(" ")
        else:
          self._model[var] = getattr(config,var)
        self.debug(f"{var}={self._model[var]}")
    config = None
    gc.collect()

    # add select-options for sensors and tasks
    self._model["_s_options"] = [f.split(".")[0] for f in os.listdir("sensors")]
    self._model["_t_options"] = [f.split(".")[0] for f in os.listdir("tasks")]
    self.debug(f"_s_options = {self._model['_s_options']}")
    self.debug(f"_t_options = {self._model['_t_options']}")

  # --- export configuration   -----------------------------------------------

  def _export_config(self,body):
    """ export json-model to config-module """

    # update model
    fields = body.decode().split("&")
    self.debug(f"{fields}")
    self._model['SENSORS'] = []
    self._model['TASKS'] = []
    self._model['HAVE_SD'] = False
    self._model['HAVE_LORA'] = False
    for field in fields:
      key,value = field.split("=")
      if '%' in value:
        value = self.html_decode(value)
      if key in ["SENSORS", "TASKS"]:
        self._model[key].append(value)
      elif key in ["have_sd", "have_lora"]:
        self._model[key.upper()] = True
      else:
        self._model[key] = value

    # dump to config (needs write access to flash -> boot.py)
    for key in sorted(self._model.keys()):
      if key[0] == "_":
        continue
      value = self._model[key]
      if key in ["SENSORS", "TASKS"]:
        print(f"{key}=\"{' '.join(value)}\"")
      elif type(value) in [int,float,bool,list]:
        print(f"{key}={value}")
      elif value in ["True","False"]:
        print(f"{key}={value}")
      elif value.isdigit() and (value[0] != "0" or len(value) == 1):
        print(f"{key}={value}")
      else:
        print(f"{key}=\"{value}\"")

  # --- run AP   -------------------------------------------------------------

  def start_ap(self):
    """ start AP-mode """

    wifi.radio.stop_station()
    try:
      wifi.radio.start_ap(ssid=self._config["ssid"],
                          password=self._config["password"])
    except NotImplementedError:
      # workaround for older CircuitPython versions
      pass

  # --- run server   ---------------------------------------------------------

  def run_server(self):

    server = mdns.Server(wifi.radio)
    server.hostname = self._config["hostname"]
    server.advertise_service(service_type="_http",
                             protocol="_tcp", port=80)
    pool = socketpool.SocketPool(wifi.radio)
    self.debug(f"starting {server.hostname}.local ({wifi.radio.ipv4_address_ap})")
    with pool.socket() as server_socket:
      yield from self.start(server_socket)

  # --- run AP and server   --------------------------------------------------

  def run(self):
    """ start AP and then run server """
    self.start_ap()
    started = False
    for _ in self.run_server():
      if not started:
        self.debug(f"Listening on http://{wifi.radio.ipv4_address_ap}:80")
        started = True
      gc.collect()
