Confirming All Routes Are Intact
To be sure you haven’t completely destroyed any endpoints on your app, check your new routes into a branch and run the following:

```sh
git checkout master
rake routes | cat > routes_before.txt

git checkout route_split
rake routes | cat > routes_after.txt

diff -u routes_before.txt routes_after.txt
#=> No results means no changes!
```
Ref: https://mattboldt.com/separate-rails-route-files/
