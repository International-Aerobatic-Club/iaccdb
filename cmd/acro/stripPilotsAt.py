#!/usr/bin/env python
import re
import sys
import subprocess

if len(sys.argv) < 2:
  print "provide results location url"
url = sys.argv[1]
regex = re.compile(r"<a href=\"javascript:popUp\('([^>]+\.htm)'\)")
ct = 0
for line in sys.stdin.readlines():
  ct += 1
  instances = regex.findall(line)
  for instance in instances:
    location = url + instance
    print str(ct) + ": " + location
    subprocess.Popen(['wget', '-Np', location])

