"""
/***************************************************************************
    QGIS Server Plugin Filters: Add a new request to print a specific atlas
    feature
    ---------------------
    Date                 : October 2017
    Copyright            : (C) 2017 by Michaël Douchin - 3Liz
    Email                : mdouchin at 3liz dot com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
 This script initializes the plugin, making it known to QGIS and QGIS Server.
"""


def classFactory(iface):
    from qgis.PyQt.QtWidgets import QMessageBox

    class Nothing:

        def __init__(self, iface):
            self.iface = iface

        def initGui(self):
            QMessageBox.warning(
                self.iface.mainWindow(),
                'AtlasPrint plugin',
                'AtlasPrint is plugin for QGIS Server. There is nothing in QGIS Desktop.',
            )

        def unload(self):
            pass

    return Nothing(iface)


def serverClassFactory(serverIface):  # pylint: disable=invalid-name
    """Load atlasprint class from file atlasprint.

    :param serverIface: A QGIS Server interface instance.
    :type serverIface: QgsServerInterface
    """
    from .server import AtlasPrintServer
    return AtlasPrintServer(serverIface)
