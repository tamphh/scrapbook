# Connect new repository to Bitbucket
Get your local Git repository on Bitbucket

Step 1: Switch to your repository's directory

```bash

cd /path/to/your/repo

git init # only do this if it's not initialized
```

Step 2: Connect your existing repository to Bitbucket

```bash

git remote add origin https://tamphh@bitbucket.org/tamphh/guesswords.git

git add sth # need to add sth new

git push -u origin master
```
