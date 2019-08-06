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

### A quick way to save clipboard contents to a file 
Overwrite:
```sh
pbpaste > somefile.txt
```
Append:
```sh
pbpaste >> somefile.txt
```


### Keep system awake by ```caffeinate```
Keep your computer awake for 1 hour:
```sh
caffeinate -t 3600
```
Keep your computer from idling until a Terminal command finishes
```sh
caffeinate -i long_running_script.sh
```
- ```-i``` prevents “idle sleeping.”
- ```-d``` just prevents the display from sleeping
- ```-m``` just prevents disks from sleeping when idle
- ```-s``` keeps the whole system awake

Source: https://brettterpstra.com/2014/02/20/quick-tip-caffeinate-your-terminal/

### Display All The Terminal Colors
```sh
for x in {0..8}; do 
    for i in {30..37}; do 
        for a in {40..47}; do 
            echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "
        done
        echo
    done
done
echo ""
```
source: https://til.hashrocket.com/posts/sfx6uu5qx5-display-all-the-terminal-colors
