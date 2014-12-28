#!/usr/bin/env python
# -*- coding: utf-8 -*-

__author__ = 'tg123'

from zipfile import ZipFile
from glob import glob
from itertools import groupby
from optparse import OptionParser
from fnmatch import fnmatchcase


class Printer:
    def before(self):
        pass

    def put(self, clzname, jars):
        pass

    def after(self):
        pass


class JarOnlyPrinter(Printer):
    bucket = []

    def put(self, clzname, jars):
        if jars not in self.bucket:
            print jars
            self.bucket.append(jars)


class AllPrinter(Printer):
    def put(self, clzname, jars):
        print clzname, jars


class HTMLPrinter(Printer):
    bucket = {}

    def before(self):
        print '''<html>
        <head>
            <style>
                .odd {background-color:#ffddee;}
                ul {display:none}
            </style>

            <script>
                var opentab = function(target){
                    while(target.nodeName != 'DIV')	target = target.parentNode;
                    var ul = target.getElementsByTagName('UL')[0];
                    ul.style.display = ul.style.display == 'block' ? 'none' : 'block';
                }
            </script>
        </head>
        <body>
        '''

    def put(self, clzname, jars):
        jars = '&nbsp;&nbsp;'.join(
            ['<span class="%s">%s</span>' % ('odd' if jars.index(j) % 2 == 0 else 'even', j.split('/')[-1]) for j in
             jars])
        if self.bucket.has_key(jars):
            self.bucket[jars] += [clzname]
        else:
            self.bucket[jars] = [clzname]

    def after(self):
        for jars, clznames in self.bucket.items():
            print '''<div><h3><a href="javascript:;" onclick="javascript:opentab(this);">%s</a></h3><ul>''' % jars
            for clzname in clznames:
                print '''<li>%s &nbsp;&nbsp;<a href="javascript:;" onclick="javascript:opentab(this);">CLOSE</a></li> ''' % clzname.rstrip(
                    '.class').replace('/', '.')
            print '''</ul></div>'''

        print '''</body>
        </html>
        '''


walkzip = lambda f: [(cf, f) for cf in ZipFile(f).namelist() if cf.lower().endswith('.class')]


def matchexclude(z, excludes):
    if isinstance(excludes, str):
        excludes = excludes.split(',')

    for patten in excludes:
        if fnmatchcase(z.split('/')[-1], patten):
            return True

    return False


def zfilter(clzname, jars):
    jars = tuple(jars)
    if len(jars) > 1:
        yield (clzname, [j[1] for j in jars])


if __name__ == '__main__':
    op = OptionParser('usage: %prog [options] dir1 dir2 ...')

    op.add_option("--html", dest="html", default=False, action="store_true")
    op.add_option("-r", dest="recursive", default=False, action="store_true")  # not impl
    op.add_option("-v", dest="verbose", default=False, action="store_true")
    op.add_option("-e", "--excludes", dest="excludes", default=[])

    options, args = op.parse_args()
    if len(args) == 0:
        args = ['.']

    printer = HTMLPrinter() if options.html else (AllPrinter() if options.verbose else JarOnlyPrinter() )

    printer.before()
    class_file_to_jar = [c for p in args
                         for z in glob(p + '/*.jar') if not matchexclude(z, options.excludes)
                         for c in walkzip(z)]
    for t in groupby(sorted(class_file_to_jar), lambda x: x[0]):
        for clzname, jars in zfilter(*t):
            printer.put(clzname, jars)

    printer.after()
