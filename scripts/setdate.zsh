#!/usr/bin/env zsh

sed -i "s+<\!--DATE-->+$(date '+%d/%m/%Y %H:%M')+g" $1

