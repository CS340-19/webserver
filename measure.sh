#!/bin/bash

cd ../students
git pull
cd ../webserver

ls -f ../students/[a-z]*.md | while read i; do cat $i | \
   perl -ane 'chop();print "'$i';$1\n" if m/([1-9][0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/'; 
done | sed 's|.*/||'  > complete

nn=1
cat complete | while IFS=\; read i ip; 
do echo "$nn;$i;$ip;"$(wget http://$ip -t 1 --timeout=3 -O - 2> /dev/null|perl -ane 's/\n/ /g;print'); 
nn=$(($nn+1))
done > complete.works

echo "# results for automatic build" > results.md

echo "|Row|netid|IP|Response|" >> results.md
echo "|--|-----|--|--------|">> results.md
sed 's/;/|/g;s/^/|/;s/$/|/' complete.works >> results.md
cut -d\; -f2 complete.works| sed 's/\.md$//' | join -v2 - eml | awk '{print "| |" $1 "|nothing||"}'>> results.md 
git add results.md
git commit -m 'Current status'
git push


cat results.md  | grep '||$' | cut -d\| -f3  | sort -u > empty

git log --format="%h" | while read i; do git show $i:results.md 2> /dev/null; done | grep -Ff empty  | sort -u | grep -v '||$' | cut -d\| -f3 | uniq | awk '{ "OK;" $1}' >> results.md


