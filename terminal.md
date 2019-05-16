#### Kill process with id: p_id
```sh
kill -9 <p_id>
```

#### Get processess which are listening on port 3100
```sh
lsof -wni tcp:3100
```

#### Find folder/files
Ex: find anything begin with ```qt@``` in ```/usr```

```sh
cd /usr # 1. go to /usr
find . -name qt@* # 2. find in /usr
```
