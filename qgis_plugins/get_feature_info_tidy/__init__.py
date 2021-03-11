# -*- coding: utf-8 -*-
"""
 This script initializes the plugin, making it known to QGIS.
"""


def serverClassFactory(serverIface):
    from .gfi_tidy import GetFeatureInfoTidy
    return GetFeatureInfoTidy(serverIface)