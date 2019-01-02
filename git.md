## Connect new repository to Bitbucket
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

## Remove a already pushed commit by resetting to commit #7f6d03
```bash
git reset 7f6d03 --hard
git push origin -f
```

## Change branch name (stay on branch need to be renamed)
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
  
## Tag commands
**Check if pushed tag is on the git remote**
  ```bash
  git ls-remote --tags origin
  ```

**Create annotated tag**
  ```bash
  git tag -a code66_v3.8.4 -m "my message"
  ```

**Push tag 'tag_name'**
  ```bash
  git push origin tag_name
  ```

**Push all unpushed local tags**
  ```bash
  git push origin --tags
  ```
## How to update forked repository

1. Add the remote, call it "upstream":
```
git remote add upstream https://github.com/whoever/whatever.git
```

2. Fetch all the branches of that remote into remote-tracking branches, such as upstream/master:
```
git fetch upstream
```

3. Make sure that you're on your master branch:
```
git checkout master
```

4. Rewrite your master branch so that any commits of yours that aren't already in upstream/master are replayed on top of that other branch:
```
git rebase upstream/master
```

5. Push your updates to master. You may need to force the push with --force.
```
git push -f origin master
```
https://stackoverflow.com/questions/7244321/how-do-i-update-a-github-forked-repository?answertab=votes#tab-top
