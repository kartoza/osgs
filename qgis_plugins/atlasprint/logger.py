__copyright__ = 'Copyright 2019, 3Liz'
__license__ = 'GPL version 3'
__email__ = 'info@3liz.org'
__revision__ = '$Format:%H$'

from qgis.core import Qgis, QgsMessageLog


class Logger:

    def __init__(self):
        self.plugin = 'wfsOutputExtension'

    def info(self, message):
        QgsMessageLog.logMessage(message, self.plugin, Qgis.Info)

    def critical(self, message):
        QgsMessageLog.logMessage(message, self.plugin, Qgis.Critical)
