#!/usr/bin/env zsh

helpStr='finalize: Finalizes a website. Runs scripts on HTML and CSS files.
Make sure that is run from the root directory of the project as 
    scripts/finalize.
Options:
    --help: print this help string
    --nodate: ignore the modification dates, run every script on every file'

[ "$1" = "--help" ] && echo "$helpStr" && exit 0

grep '\:based\:' "$HOME/.emacs.d/elfeed.org" -v > files/elfeed.org


# TODO Make these date sensitive
cp -r res site-final/
cp -r css site-final/
cp -r files site-final/

cp index.html programs.html site-final/.

# For blogs
foreach script in "scripts/blogize.sh"; do
	foreach html in blogs/*.html; do
		([ "$1" = "--nodate" ] || [ "$html" -nt ".lastmod" ]) && "$script" "$html"
	done
done


# Finishing touches (like last modified date)
foreach script in "scripts/setdate.zsh"; do
	foreach html in site-final/*.html site-final/blogs/*.html; do
		([ "$1" = "--nodate" ] || [ "$html" -nt ".lastmod" ]) && "$script" "$html"
	done
done


rm .lastmod && touch .lastmod