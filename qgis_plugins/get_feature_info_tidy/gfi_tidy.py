__author__ = 'Tim Sutton'
__date__ = 'March 2021'
__copyright__ = '(C) 2021, Tim Sutton, Kartoza'

import sys
import os
import re

from qgis.server import *
from qgis.core import *


class GetFeatureInfoTidy:
    """Plugin to tidy up the get feature info request results.html
    
    This will rewrite the GFI response from QGIS Server to:

    - remove tables for layers with no data
    - use the beauter (https://beauter.io/docs/) CSS framework to lay out the data in a grid
    
    Note that you may find it more efficient to parse / use the application/json gfi response data
    from QGIS Server and simply parse the result in javascript.
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
            body.replace(b"""<HEAD>""", b"""""")
            body.replace(b"""<TITLE> GetFeatureInfo results </TITLE>""", b"""""")
            body.replace(b"""<META http-equiv="Content-Type" content="text/html;charset=utf-8"/>""", b"""""")
            body.replace(b"""</HEAD>""", b"""""")
            body.replace(b"""<BODY>""", b"""""")
            body.replace(b'</BR>', b"""""")
            body.replace(b'<BR>', b"""""")
            body.replace(b'<TR><TH>', b"""<tr><th>""")
            body.replace(b'</TD></TR>', b"""</td></tr>""")
            body.replace(b'<TABLE border=1 width=100%>', b"""""")
            body.replace(b'</TABLE>', b"""""")
            body.replace(b'<TR><TH width=25%>', b"""<tr><th>""")
            body.replace(b'</TH>', b"""</th>""")
            body.replace(b'<TD>', b"""<td>""")
            #body.replace(b'</TD></TR>', b"""</td></tr>""")
            body.replace(b"""</BODY>""", b"""""")
            # replace NULL with hyphen for cosmetic appeal
            body.replace(b'NULL', b'-')
            # Get rid of blank lines
            body.replace(b'\n\n', b'\n')
            # Once more to remove double blank lines
            body.replace(b'\n\n', b'\n')

            # Strip away empty tables too. After the above replacements,
            # they will typically have a single line with the first cell containing the word 'Layer' e.g.
            # <div class="col m6 _nightblue">Layer</div><div class="col m6">Roofs</div>
            layers = []
            content = str(body, 'utf-8')
            # Uncomment for debugging only
            #QgsMessageLog.logMessage("Body as string:", 'plugin', Qgis.Info) 
            #QgsMessageLog.logMessage(content, 'plugin', Qgis.Info) 
            cleaned_content = """<div class="card _alignCenter">
            <h5>Query Results</h5>
            <div class="-content">
            <table class="_width100">"""
            last_line_is_layer = False
            last_line = ""
            for line in content.splitlines():
                if "Layer</th>" in line and "Layer</th>" in last_line:
                    #forget the last line, it is an empty table
                    pass
                else:
                    cleaned_content += last_line + '\n'
                last_line = line
            cleaned_content += '</table>'
            cleaned_content += '</div>'
            cleaned_content += '</div>'
            # Uncomment for debugging only
            #QgsMessageLog.logMessage("Cleaned content as string:", 'plugin', Qgis.Info) 
            #QgsMessageLog.logMessage(cleaned_content, 'plugin', Qgis.Info) 

            handler.clearBody()
            handler.appendBody(cleaned_content.encode('utf-8'))
