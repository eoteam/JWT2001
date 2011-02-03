echo -n "Committing ... "
git status
git add .
read message
git commit -a -m "$message"
git push origin edge
