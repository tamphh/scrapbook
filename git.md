# Connect new repository to Bitbucket
Get your local Git repository on Bitbucket

Step 1: Switch to your repository's directory

```bash
#1
cd /path/to/your/repo
#2
git init # only do this if it's not initialized
```

Step 2: Connect your existing repository to Bitbucket

```bash
#1
git remote add origin https://tamphh@bitbucket.org/tamphh/guesswords.git
#2
git add sth # need to add sth new
#3
git push -u origin master
```
