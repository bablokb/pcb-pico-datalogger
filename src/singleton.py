#-----------------------------------------------------------------------------
# This class implements the singleton tag.
#
# Credits: https://stackoverflow.com/questions/6760685/creating-a-singleton-in-python
#
# Author: Bernhard Bablok
#
# Website: https://github.com/pcb-pico-datalogger
#-----------------------------------------------------------------------------


def singleton(class_):
  instances = {}
  def getinstance(*args, **kwargs):
    if class_ not in instances:
      instances[class_] = class_(*args, **kwargs)
    return instances[class_]
  return getinstance
