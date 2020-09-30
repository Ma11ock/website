#!/usr/bin/env zsh

# returns hour and seconds if current year, else returns year
function getfinaldate() {
    local year="$1"
    local hour="$2"
    [ "$year" -lt "$(date '+%G')" ] &&  echo "$year" && return
    echo "${(l:5:)hour}"
}

function echoerr() {
    echo "$@" 1>&2
}

function getdate() {
    ls -l "$1" | awk '{printf "%s %2d %s", $6, $7, $8}'
}

function printwc() {
    local orgOrig=${1:r}.org
    local wcout="$(wc -w < "$orgOrig" | numfmt --to=si)"
    echo "${(l:4:)wcout}"
}

# This is a ghetto-trash solution but it is the only one so long as zfs does not support getting the btime/crtime from the userland
function getbtime() {
    (grep "$1:t" site-final/blogs/btimes  | awk '{printf "%s %s ", $2, $3}') || (echoerr "ERROR: Cannot find $1 in btime" && exit 1)
    getfinaldate "$(grep "$1:t" site-final/blogs/btimes  | awk '{printf "%s", $4}')"\
                 "$(grep "$1:t" site-final/blogs/btimes  | awk '{printf "%s", $5}')"
}

function lsize() {
    echo "<p>total $(wc -w < blogs/*.org | numfmt --to=si) Words</p>"
    
    # TODO convert from regular number to K or M or B etc (like ls output)
    foreach htmlf in `find blogs -printf "%T@ %Tc %p\n" | grep '\.html$' | sort -nr | awk '{print $9}'`; do
        echo "<p>-rw-r--r-- 1 ryan ryan $(printwc $htmlf)"\
             "$(getdate "$htmlf") |"\
             "$(getbtime $htmlf)<a href=\"$htmlf\">"\
            "$(sed -n -e 's/.*<title>\(.*\)<\/title>.*/\1/p' "$htmlf")</a></p>"
    done
}

while read line; do
    (echo "$line" | grep '<!--REPLACE HERE-->' -q) && lsize
    echo "$line"
done < "blog.html"
