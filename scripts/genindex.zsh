#!/usr/bin/env zsh


function getdate() {
    ls -dl "$1" | awk '{printf "%s %2d ", $6, $7} '
    date +'%G'
}

function printwc() {
    local orgOrig=${1:r}.org
    if test -f "$orgOrig"; then
        local wcout="$(wc -w < "$orgOrig" | numfmt --to=si)"
        echo "${(l:4:)wcout}"
    else
        local otherout="$(sed -e 's/<[^>]*>//g' $1 | wc -w)"
        echo "${(l:4:)otherout}"
    fi
}

function print_dirc() {
    local dircout="$(ls $1 | wc -l)"
    echo "${(l:4:)dircout}"
}

file_size_locals=($(find blogs/ . -name '*.org'))

function lsize() {
    echo "<p>total $(wc -w < **/*.org | numfmt --to=si) Words</p>"
    # TODO convert from regular number to K or M or B etc (like ls output)
    # For Directories
    foreach mydir in files; do
    echo "<p>drwxr-xr-x 2 ryan ryan $(print_dirc)" \
         "$(getdate $mydir)<a href=\"$mydir\"> $mydir</a></p>"
    done
    # for html files
    foreach htmlf in blog.html programs.html; do
        echo "<p>-rw-r--r-- 1 ryan ryan $(printwc $htmlf)"\
            "$(getdate "$htmlf")<a href=\""$htmlf"\">"\
            "$(sed -n -e 's/.*<title>\(.*\)<\/title>.*/\1/p' "$htmlf")</a></p>"
    done
}

while read -r line; do
    if [ "$line" = '<!--REPLACE HERE-->' ]; then
        lsize
    elif [ "$line" = '<!--TITLE HERE-->' ]; then
        echo '<p>'
        figlet "Ryan's Homepage"
        echo '</p>'
    elif [ "$line" = '<meta name="author" content="Ryan Jeffrey">' ]; then
        echo '<!--'
#        figlet 'The industrial revolution and its consequences have been a disaster for the human race.'
        echo '-->'
    else
        echo "$line"
    fi
done < "index.html"
