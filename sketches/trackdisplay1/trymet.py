'''------------------------------------------------------------------------------trymet.py
 *
 * This is a one stop one route transit tracker to send data to a serial display.
 * It is an ugly little hack of Dan Colish's PyMET code.
 *
 * https://github.com/dcolish/PyMET/blob/master/pymet/pymet.py
 * and inherits the following copyright.
 *
 * Copyright (c) 2009 Dan Colish <dcolish@gmail.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *
 * Hacked to bits by don@suspectdevices.com
 *
'''
import gc
import serial
import time
import urllib
from optparse import OptionParser
from xml.etree import ElementTree as ET

# gc.set_debug(gc.DEBUG_LEAK)

def getArrivals():
  try:
    number_of_times=0
    application_id = "EC36A740E55BB5A803BB2602B" # I should use the id i registered....
    local_dict = []
    stop_num = '7536'
    route_num='75'
#    for i in stop_num:
    x = 0
    user_url = "http://developer.trimet.org/ws/V1/arrivals/locIDs/" + \
        '7536' + "/appID/" + application_id
    f = urllib.urlopen(user_url)
    elements = ET.XML(f.read())
    subelements = elements.getchildren()

    retval=""

    #get all of the stops for the route we're taking
    for children in subelements:
        if children.get('route', route_num) == route_num:
            local_dict += list([children.attrib])

    for things in local_dict:
        if 'estimated' in things:
            arriving_at = time.strftime("~%I:%M",
                                        time.localtime(
                    float(things.get('estimated')) / 1000))
            retval=retval+arriving_at+" "
        elif 'scheduled' in things:
            arriving_at = time.strftime("*%I:%M", time.localtime(
                    float(things.get('scheduled')) / 1000))
            retval=retval+arriving_at+" "
    return retval 
  except IOError:
    return "No Interbutts"
    
if __name__ == "__main__":
#  try:
    ser=serial.Serial('/dev/tty.usbmodem1d11') # hardcode == arduino style == bad. 
    while(1):
        ser.write ("\376\001"+time.strftime("%b%d %I:%M:%S%p",time.localtime())
                   +"\376\300"+getArrivals())
        time.sleep(7)
#  except as e:
#    print e
