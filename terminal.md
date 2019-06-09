### Kill process with id: p_id
```sh
kill -9 <p_id>
```
### How to kill multiple PIDs with ```grep```, ```xargs```
```sh
ps auxww | grep application | grep processtobekilled | gawk '{print $2}' | grep -v grep | xargs kill -9
```

### Get processess which are listening on port 3100
```sh
lsof -wni tcp:3100
```

### Find folder/files by name
Ex: find anything begin with ```qt@``` in ```/usr```

```sh
cd /usr # 1. go to /usr
find . -name qt@* # 2. find in /usr
```
### Show top 5 most used commands

```sh
history | \
awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | \
grep -v "./" | \
column -c3 -s " " -t | \
sort -nr | nl |  head -n 5
```
