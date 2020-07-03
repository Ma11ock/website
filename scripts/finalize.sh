#!/usr/bin/env zsh

helpStr='finalize: Finalizes a website. Runs scripts on HTML and CSS files.
Make sure that is run from the root directory of the project as 
    scripts/finalize.
Options:
    --help: print this help string
    --nodate: ignore the modification dates, run every script on every file'

[ "$1" = "--help" ] && echo "$helpStr" && exit 0

# TODO Make these date sensitive
cp -r res site-final/
cp -r css site-final/
cp -r files site-final/

# For changes that need only happen if the file was modified
foreach script in "scripts/setdate.zsh"; do
	foreach html in *.html; do
		([ "$1" = "-nodate" ] || [ "$html" -nt ".lastmod" ]) && "$script" "$html"
	done
done

# For blogs
foreach script in "scripts/setdate.zsh" "scripts/blogize.sh"; do
	foreach html in blogs/*.html; do
		([ "$1" = "--nodate" ] || [ "$html" -nt ".lastmod" ]) && "$script" "$html"
	done
done


rm .lastmod && touch .lastmod