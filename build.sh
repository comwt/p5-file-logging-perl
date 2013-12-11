#!/bin/bash

#Source: http://bratislava.pm.org/en/tutorial/new-module.html

cd File-Logging && \
  perl Build.PL && \
  ./Build clean && \
  perl Build.PL && \
  ./Build distcheck && \
  ./Build disttest && \
  ./Build dist && \
  echo SUCCESS
