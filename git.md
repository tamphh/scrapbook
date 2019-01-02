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

# Remove a already pushed commit by resetting to commit #7f6d03
```bash
git reset 7f6d03 --hard
git push origin -f
```

# Change branch name (stay on branch need to be renamed)
  1. Rename your local branch.
  ```bash
  git branch -m new-name
  ```
  2. Delete the old-name remote branch and push the new-name local branch.
  ```bash
  git push origin :old-name new-name
  ```
  3. Reset the upstream branch for the new-name local branch. Switch to the branch and then:
  ```bash
  git push origin -u new-name
  ```
