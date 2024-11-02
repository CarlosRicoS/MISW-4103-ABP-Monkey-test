#!/bin/zsh

ls -l ./Entregable | awk '{print $9}' | sed '1,2d' | awk -F'-' '{print $2}' | sort -n > ./seeds-entregable.txt