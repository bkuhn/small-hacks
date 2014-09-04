#!/usr/bin/python
# ods2xls.py
# adapted from ssconv.py
# see also
#  https://help.libreoffice.org/Common/About_Converting_Microsoft_Office_Documents
#  http://wiki.openoffice.org/wiki/Documentation/DevGuide/Spreadsheets/Filter_Options
#  http://linuxsleuthing.blogspot.com/2012/01/unoconv-is-number-one.html
#
# Copyright © 2013, Tom Marble.
#
# This software's license gives you freedom; you can copy, convey,
# propogate, redistribute and/or modify this program under the terms of
# the GNU  Lesser General Public License (LGPL) as published by the Free
# Software Foundation (FSF), either version 2.1 of the License, or (at your
# option) any later version of the LGPL published by the FSF.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program in a file in the toplevel directory called
# "LGPLv2.1".  If not, see <http://www.gnu.org/licenses/>.

import os
import ooutils
import time

import uno
from com.sun.star.task import ErrorCodeIOException

class SSConverter:
    """
    Spreadsheet converter class.
    Converts spreadsheets to XLS files.
    """

    def __init__(self, oorunner=None):
        self.desktop  = None
        self.oorunner = None


    def convert(self, inputFile, outputFile):
        """
        Convert the input file (a spreadsheet) to a XLS file.
        """

        # Start openoffice if needed.
        if not self.desktop:
            if not self.oorunner:
                self.oorunner = ooutils.OORunner()

            # DEBUG
            print('oorunner should be working here')
            self.desktop = self.oorunner.connect()
            time.sleep(1)
            print(os.popen('fuser -u 8100/tcp').read())
            print('connected to LibreOffice...')

        inputUrl  = uno.systemPathToFileUrl(os.path.abspath(inputFile))
        outputUrl = uno.systemPathToFileUrl(os.path.abspath(outputFile))
        document  = self.desktop.loadComponentFromURL(inputUrl, "_blank", 0, ooutils.oo_properties(Hidden=True))

        try:
            # Additional property option:
            #   FilterOptions="59,34,0,1"
            #     59 - Field separator (semicolon), this is the ascii value.
            #     34 - Text delimiter (double quote), this is the ascii value.
            #      0 - Character set (system).
            #      1 - First line number to export.
            #
            # For more information see:
            #   http://wiki.services.openoffice.org/wiki/Documentation/DevGuide/Spreadsheets/Filter_Options
            #
            document.storeToURL(outputUrl, ooutils.oo_properties(FilterName="MS Excel 97"))
        finally:
            document.close(True)


if __name__ == "__main__":
    from sys import argv
    from os.path import isfile

    if len(argv) == 2  and  argv[1] == '--shutdown':
        ooutils.oo_shutdown_if_running()
    else:
        if len(argv) < 2:
            print "USAGE:"
            print "  python %s INPUT-FILE [INPUT-FILE ...]" % argv[0]
            print "OR"
            print "  python %s --shutdown" % argv[0]
            exit(255)
        if not isfile(argv[1]):
            print "File not found: %s" % argv[1]
            exit(1)

        try:
            i = 1
            converter = SSConverter()
            while i < len(argv):
                odsname = argv[i]
                xlsname = odsname.replace('.ods', '.xls')
                print '%s => %s' % (odsname, xlsname)
                converter.convert(odsname, xlsname)
                i += 1

        except ErrorCodeIOException, exception:
            print "ERROR! ErrorCodeIOException %d" % exception.ErrCode
            exit(1)
