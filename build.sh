#!/bin/bash

if [ -s "$HOME/.dvm/scripts/dvm" ] ; then
    . "$HOME/.dvm/scripts/dvm" ;
    dvm use 2.098.0
fi

dmd source/config.d source/renotify/*.d \
  -vcolumns -Isource -fPIC -betterC -shared -oflibrenotify.so $@
