#!/usr/bin/env zsh

# Print the title and remove all HTML tags
function gettitle() {
    sed -n -e 's/.*<title>\(.*\)<\/title>.*/\1/p' "$1" | sed -e 's/<[^>]*>//g'
}

# Get the pubDate
function getdate() {
    date --date="$(grep "$1:t" site-final/blogs/btimes  | awk '{printf "%s %s %s %s", $2, $3, $4, $5}')" +"%a, %d %b %Y %H:%M:%S %z"
}

# Print the second paragraph tag (the beginning of the post)
function getdescr() {
    sed -n '/<p>/,/<\/p>/p' "$1" | head | head -2
}

function getcontent() {
    sed -n '/<p>/,/<\/p>/p' "$1" | awk 'NR != 1'
}

function genitemdata() {
    printf '<item>\n'
    printf '<title>%s</title>\n' "$(gettitle $1)"
    printf '<guid>https://ryanmj.xyz/blogs/%s</guid>\n' "$1:t"
    printf '<link>https://ryanmj.xyz/blogs/%s</link>\n' "$1:t"
    printf '<pubDate>%s</pubDate>\n' "$(getdate $1)"
    printf '<description><![CDATA[%s]]></description>\n' "$(getdescr $1)"
    printf '<content:encoded>%s</content:encoded>' "$(getcontent $1)"
    printf '</item>\n'
}

# Print header and information
printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n'\
       '<!--  <?xml-stylesheet type="text/css" href="rss.css" ?>  -->'\
       '<!--  <?xml-stylesheet href="rss.xsl" type="text/xsl" media="screen"?>  -->'\
       '<rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">'\
       '<channel>'\
       '<title>The Latest From Ryan</title>'\
       "<description>Ryan's general blog feed. Contains all of my blog posts and updates.</description>"\
       '<language>en-us</language>'\
       '<link>https://ryanmj.xyz/rss.xml</link>'\
       '<atom:link href="https://ryanmj.xyz/rss.xml" rel="self" type="application/rss+xml"/>'\
       '<image>'\
       '<title>The Latest From Ryan</title>'\
       '<link>https://ryanmj.xyz/ryan.jpg</link>'\
       '</image>'

foreach blog in `find blogs -printf "%T@ %Tc %p\n" | grep '\.html$' | sort -nr | awk '{print $9}'`; do
    grep "$blog:t" site-final/blog.html || continue
    genitemdata "$blog"
done

printf '</channel>\n</rss>\n'
