git add -A;
echo -n "Enter commit message";
read message;
git commit -a -m "$message";
git push origin edge;
