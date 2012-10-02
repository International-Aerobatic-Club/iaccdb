#!/usr/bin/env python
import re
import sys
import subprocess

url = "http://nationals.iac.org"
if len(sys.argv) < 2:
  print "say au or psi"
dir = "/files/results/" + sys.argv[1] + "/"
regex = re.compile(r"<a href=\"javascript:popUp\('([^>]+\.htm)'\)")
ct = 0
for line in sys.stdin.readlines():
  ct += 1
  instances = regex.findall(line)
  for instance in instances:
    location = url + dir + instance
    print str(ct) + ": " + location
    subprocess.Popen(['wget', '-Np', location])

