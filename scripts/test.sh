opening=$(tr "\n" "|" < blogs/mu4e.html | grep -o '<p>.*</p>' | tr "|" "\n" | head)
mainBlogPage='blog.html'

# Modify the blog file
foreach blogfile in $@
do
    opening=$(tr "\n" "|" < "$blogFile" | grep -o '<p>.*</p>' | tr "|" "\n" | head)

    while read line
    do
        echo "$line" | grep -- '<center><h1>Blog</h1></center>' && echo "\n<div class=\"opening\">$opening<\div>" >> site-final/"$mainBlogPage"
    done < "$mainBlogPage"
done

