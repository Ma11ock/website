#!/usr/bin/env zsh

outDir='site-final/'

helpStr='blogize: takes an org-generated HTML file and turns it into a proper 
         blog post (along with adding it to blog.html).
         This program is only meant to take ONE HTML file.
Params:  blogize should be given the HTML files of the blogs it is to
         generate. It does not check for modification dates or 
         anything like that.
--help:  To get this help message.'

[ "$1" = "--help" ] && echo "$helpStr" && exit 0

# link with path to the style sheet
mainCSSPath='<link href="../css/main.css" rel="stylesheet">'
# style divs
styleDivs='<div class="emacs">
             <div class="ebar-top"></div>
            <div class="ebar">
                <p class="title-red">------</p>
                <img id="gnu-emacs" src="../res/gnu-emacs.png"/> <p>*Blog*</p>
                <div class="last">
                    <p class="modded">Last Modified: <!--DATE--></p>
                </div>
            </div>
            <div class="ebar-bot"></div>
            <a href="../blog.html"><h4><-Back</h4></a>'
            
echoerr() { printf "\e[31;1m%s\e[0m\n" "$*" >&2; }

# Modifies each new blog entry to have the styling of the rest of the site 
foreach blogfile in "$@"
do
    outFile=""$outDir"$blogfile"
    echo "Outputting to file $outFile"
    # TODO if the file already exists, then likely the latest version is a 
    # revision. That should be mentioned in the title.
    stat "$outFile" &>/dev/null && echo "$outFile exists. Deleting." && rm "$outFile"
    while read line
    do
        echo "$line" >> "$outFile"
        echo "$line" | grep -- '<\/title>' &>/dev/null && echo "$mainCSSPath" >> "$outFile" && didCSS="1"
        echo "$line" | grep -- '<body>' &>/dev/null    && echo "$styleDivs"   >> "$outFile" && didStyle="1"
        echo "$line" | grep -- 'class="validation"' &>/dev/null && echo '</div>' >> "$outFile" && didDiv="1"
    done < "$blogfile"
    [ -v didCSS ] || echoerr "Warning: CSS file not linked to: "$blogfile""
    [ -v didStyle ] || echoerr "Warning: styledivs not written: "$blogfile""
    [ -v didDiv ] || echoerr "Warning: style div not closed: "$blogfile""
    
    unset didCSS
    unset didStyle
    unset didDiv
done

# The location of the blogfile
mainBlogPage='blog.html'

# Get the opening of the article
opening=$(tr "\n" "|" < "$1" | grep -o '<p>.*</p>' | tr "|" "\n" | head)
title=$(tr "\n" "|" < blogs/mu4e.html | grep -o '<title>.*</title>' | sed -e 's/<title>//g' -e 's-</title>--g')

stat site-final/"$mainBlogPage" &>/dev/null && echo "Deleting existing final $mainBlogPage" && rm site-final/"$mainBlogPage"

blogdate=$(grep -o '<p class=\"date\">.*</p>' "site-final/$1" | sed -e 's/<p class=\"date\">//g' -e 's-</p>--g')

# Modify the blog file
foreach blogfile in $@
do
    opening=$(tr "\n" "|" < "$1" | grep -o '<p>.*</p>' | tr "|" "\n" | head)

    while read line
    do
        echo "$line" >> site-final/"$mainBlogPage"
        echo "$line" | grep -q '<h1>Blog</h1>' \
            && echo "\n<div class=\"blogpreview\">\n<div class=\"bloghead\">\n<a href=\"$1\"><h3>$title</h3></a>\n</div>\n" >> site-final/"$mainBlogPage" \
            && echo "\n<h5>$blogdate</h5>" >> site-final/"$mainBlogPage" \
            && echo "\n<div class=\"opening\">\n$opening\n</div>" >> site-final/"$mainBlogPage" \
            && echo "\n</div>\n<!--END_BLOGPOAST-->\n" >> site-final/"$mainBlogPage"
    done < "$mainBlogPage"
done


exit 0