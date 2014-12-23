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

    op.add_option("-r", dest="recursive", default=False, action="store_true")  # not impl
    op.add_option("-v", dest="verbose", default=False, action="store_true")
    op.add_option("-e", "--excludes", dest="excludes", default=[])

    options, args = op.parse_args()
    if len(args) == 0:
        args = ['.']

    if options.verbose:
        printer = AllPrinter()
    else:
        printer = JarOnlyPrinter()

    printer.before()
    for t in groupby(sorted(
            [c for p in args for z in glob(p + '/*.jar') if not matchexclude(z, options.excludes) for c in walkzip(z)]),
                     lambda x: x[0]):
        for clzname, jars in zfilter(*t):
            printer.put(clzname, jars)

    printer.after()
