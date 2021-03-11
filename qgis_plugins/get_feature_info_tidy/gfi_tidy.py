__author__ = 'Tim Sutton'
__date__ = 'March 2021'
__copyright__ = '(C) 2021, Tim Sutton, Kartoza'

import sys
import os

from qgis.server import *
from qgis.core import *


class GetFeatureInfoTidy:
    """Plugin to tidy up the get feature info request results.html
    
    This will rewrite the GFI response from QGIS Server to:

    - remove tables for layers with no data
    - use the beauter (https://beauter.io/docs/) CSS framework to lay out the data in a grid
    
    """
    QgsMessageLog.logMessage("GetFeatureInfoTidy plugin loaded yay!", 'plugin', Qgis.Info) 
    def __init__(self, serverIface):
        self.serverIface = serverIface        
        priority = 1
        try:
            serverIface.registerFilter( GetFeatureInfoFilter(serverIface), priority * 100 )
        except Exception as e:
                QgsLogger.debug("Error loading GetFeatureInfoFilter filter %s" % (e))


class GetFeatureInfoFilter(QgsServerFilter):

    def __init__(self, serverIface):
        super(GetFeatureInfoFilter, self).__init__(serverIface)

    def responseComplete(self):
        handler = self.serverInterface().requestHandler()
        params = handler.parameterMap( )

        if (params.get('SERVICE', '').upper() == 'WMS' \
                and params.get('REQUEST', '').upper() == 'GETFEATUREINFO' \
                and params.get('INFO_FORMAT', '').upper() == 'TEXT/HTML' \
                and not handler.exceptionRaised() ):
            body = handler.body()
            body.replace(b'<BODY>', b"""<BODY><STYLE type="text/css">* {font-family: arial, sans-serif; color: #09095e;} table { border-collapse:collapse; } td, tr { border: solid 1px grey; }</STYLE>""")
            handler.clearBody()
            handler.appendBody(body)