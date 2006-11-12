#!/usr/bin/env python
# ex:ts=4:sw=4:sts=4:et
# -*- tab-width: 4; c-basic-offset: 4; indent-tabs-mode: nil -*-
"""
BitBake 'Fetch' implementations

Classes for obtaining upstream sources for the
BitBake build tools.

Copyright (C) 2003, 2004  Chris Larson

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 59 Temple
Place, Suite 330, Boston, MA 02111-1307 USA. 

Based on functions from the base bb module, Copyright 2003 Holger Schurig
"""

import os, re
import bb
from   bb import data
from   bb.fetch import Fetch
from   bb.fetch import FetchError
from   bb.fetch import MissingParameterError

class Cvs(Fetch):
    """
    Class to fetch a module or modules from cvs repositories
    """
    def supports(self, url, ud, d):
        """
        Check to see if a given url can be fetched with cvs.
        """
        return ud.type in ['cvs', 'pserver']

    def localpath(self, url, ud, d):
        if not "module" in ud.parm:
            raise MissingParameterError("cvs method needs a 'module' parameter")
        ud.module = ud.parm["module"]

        ud.tag = ""
        if 'tag' in ud.parm:
            ud.tag = ud.parm['tag']

        # Override the default date in certain cases
        if 'date' in ud.parm:
            ud.date = ud.parm['date']
        elif ud.tag:
            ud.date = ""

        ud.localfile = data.expand('%s_%s_%s_%s.tar.gz' % (module.replace('/', '.'), ud.host, ud.tag, ud.date), d)

        return os.path.join(data.getVar("DL_DIR", d, 1), ud.localfile)

    def go(self, loc, ud, d):

        localdata = data.createCopy(d)
        data.setVar('OVERRIDES', "cvs:%s" % data.getVar('OVERRIDES', localdata), localdata)
        data.update_data(localdata)

        if not "module" in ud.parm:
            raise MissingParameterError("cvs method needs a 'module' parameter")
        else:
            module = ud.parm["module"]

        dlfile = ud.localpath
        dldir = data.getVar('DL_DIR', localdata, 1)

        # setup cvs options
        options = []

        if "method" in ud.parm:
            method = ud.parm["method"]
        else:
            method = "pserver"

        if "localdir" in ud.parm:
            localdir = ud.parm["localdir"]
        else:
            localdir = module

        cvs_rsh = None
        if method == "ext":
            if "rsh" in ud.parm:
                cvs_rsh = ud.parm["rsh"]

        tarfn = ud.localfile

        # try to use the tarball stash
        if Fetch.check_for_tarball(d, tarfn, dldir, date):
            bb.msg.debug(1, bb.msg.domain.Fetcher, "%s already exists or was mirrored, skipping cvs checkout." % tarfn)
            return

        if ud.date:
            options.append("-D %s" % ud.date)
        if ud.tag:
            options.append("-r %s" % ud.tag)

        olddir = os.path.abspath(os.getcwd())
        os.chdir(data.expand(dldir, localdata))

        # setup cvsroot
        if method == "dir":
            cvsroot = ud.path
        else:
            cvsroot = ":" + method + ":" + ud.user
            if ud.pswd:
                cvsroot += ":" + ud.pswd
            cvsroot += "@" + ud.host + ":" + ud.path

        data.setVar('CVSROOT', cvsroot, localdata)
        data.setVar('CVSCOOPTS', " ".join(options), localdata)
        data.setVar('CVSMODULE', module, localdata)
        cvscmd = data.getVar('FETCHCOMMAND', localdata, 1)
        cvsupdatecmd = data.getVar('UPDATECOMMAND', localdata, 1)

        if cvs_rsh:
            cvscmd = "CVS_RSH=\"%s\" %s" % (cvs_rsh, cvscmd)
            cvsupdatecmd = "CVS_RSH=\"%s\" %s" % (cvs_rsh, cvsupdatecmd)

        # create module directory
        bb.msg.debug(2, bb.msg.domain.Fetcher, "Fetch: checking for module directory")
        pkg=data.expand('${PN}', d)
        pkgdir=os.path.join(data.expand('${CVSDIR}', localdata), pkg)
        moddir=os.path.join(pkgdir,localdir)
        if os.access(os.path.join(moddir,'CVS'), os.R_OK):
            bb.msg.note(1, bb.msg.domain.Fetcher, "Update " + loc)
            # update sources there
            os.chdir(moddir)
            myret = os.system(cvsupdatecmd)
        else:
            bb.msg.note(1, bb.msg.domain.Fetcher, "Fetch " + loc)
            # check out sources there
            bb.mkdirhier(pkgdir)
            os.chdir(pkgdir)
            bb.msg.debug(1, bb.msg.domain.Fetcher, "Running %s" % cvscmd)
            myret = os.system(cvscmd)

        if myret != 0 or not os.access(moddir, os.R_OK):
            try:
                os.rmdir(moddir)
            except OSError:
                 pass
            raise FetchError(module)

        os.chdir(moddir)
        os.chdir('..')
        # tar them up to a defined filename
        myret = os.system("tar -czf %s %s" % (os.path.join(dldir,tarfn), os.path.basename(moddir)))
        if myret != 0:
            try:
                os.unlink(tarfn)
            except OSError:
                pass
        os.chdir(olddir)
