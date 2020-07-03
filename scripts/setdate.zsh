#!/usr/bin/env zsh

sed -e "s+<\!--DATE-->+$(date '+%d/%m/%Y %H:%M')+g" $1 > site-final/$1

