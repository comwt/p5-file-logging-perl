#!/bin/bash

#Source: http://bratislava.pm.org/en/tutorial/new-module.html

perl Build.PL; ./Build clean; perl Build.PL && ./Build distcheck && ./Build disttest && ./Build dist
