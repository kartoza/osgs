#!/bin/python3

# 
#
# 
#
#
import subprocess
from subprocess import Popen, PIPE
from shlex import split
subprocess.run("docker-compose ps".split())
p1 = Popen(split("ls"), stdout=PIPE)
p2 = Popen(split("awk '{print $1}'"), stdin=p1.stdout)

filename = "enabled-profiles"
with open(filename) as f_in:
    lines = filter(None, (line.rstrip() for line in f_in))
