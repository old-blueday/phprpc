#!/usr/bin/env python
import sys
from distutils.core import setup
if sys.version_info < (2, 4):
  raise Error, "Python 2.4 or later is required"

setup(name='phprpc',
      version='3.0.2',
      description='PHPRPC is a Perfect High Performance Remote Procedure Calling that works over the Internet.',
      author='Ma Bingyao',
      author_email='andot at phprpc com',
      url='http://www.phprpc.org',
	  packages=['phprpc'],
	  package_dir={'phprpc': 'src/phprpc'},
	  package_data={'phprpc': ['dhparams/*.dhp']},
     )
