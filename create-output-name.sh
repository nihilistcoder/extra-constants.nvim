#!/usr/bin/bash

echo -n $(echo "${1}" | sed "s/\/home\/${USER}\///" | tr "/" "." | sed "s/^\.//").vim
