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
### Copy files with progress by ```rsync``` command
Copy the directory itself:
```sh
# result: directory ~/foo contents will be copied in ~/foo@backup/foo
rsync -av -P ~/foo ~/foo@backup
```
Copy the directory contents only:
```sh
# result: directory ~/foo contents will be copied in ~/foo@backup
rsync -av -P ~/foo/ ~/foo@backup
```
### Put anything to Mac menu status bar by sh
https://getbitbar.com/plugins/Music/spotify.10s.sh
