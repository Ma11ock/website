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
# TODO this css file will change
mainCSSPath='<link href="../css/emacs.css" rel="stylesheet">'
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
foreach blogfile in blogs/*.html weight.html
do
    outFile=""$outDir"$blogfile"
    stat "$outFile" &>/dev/null
    retval=$?
    if [ $retval -eq 0 ]  && [ "$blogfile" -nt "$outfile" ]; then 
        echo "An update occured so $outfile is being deleted and remade." && rm "$outfile"
    elif [ $retval -ne 0 ]; then
        echo "Generating new blogfile for $blogfile"
    else
        continue
    fi
    
    echo "Outputting to file $outFile..."
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

