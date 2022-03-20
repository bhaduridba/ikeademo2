#!/usr/bin/env python
# coding: utf-8

import sys
import time
import subprocess
import random

from time import sleep
from json import dumps

def setup_streaming():
    import subprocess
    subprocess.call(['./01-setup.sh'])
    #subprocess.call(['./Users/sobhan/Documents/projects/ikeademo2/01-setup.sh'])

def main():

   #process1()

   #process2()

   #process3()

   setup_streaming()

if __name__ == "__main__":
   main()
