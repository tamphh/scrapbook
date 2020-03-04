## Checkout/Connect new reposistory
### Clone private github repository
Private clone URLs take the form ```git@github.com:username/repo.git``` - perhaps you needed to use ```git@``` rather than ```git://?```

```git://``` URLs are read only, and it looks like private repos do not allow this form of access.

Ref: https://stackoverflow.com/questions/2505096/cloning-a-private-github-repo?answertab=votes#tab-top

### Connect new repository to Bitbucket
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
# 
### How to use multiple github accounts with ssh keys on same computer
I have two Github accounts: oanhnn (personal) and superman (for work). I want to use both accounts on same computer (without typing password everytime, when doing git push or pull).

***Solution:***

Use ssh keys and define host aliases in ssh config file (each alias for an account).

Link: https://gist.github.com/oanhnn/80a89405ab9023894df7
### Remove a already pushed commit by resetting to commit #7f6d03
```bash
git reset 7f6d03 --hard
git push origin -f
```

### Reset develop branch to master
```bash
git checkout develop
git reset --hard master
git push --force origin develop
```

### Change branch name (stay on branch need to be renamed)
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
  
### Tag commands
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
### How to update forked repository

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
https://digitaldrummerj.me/git-syncing-fork-with-original-repo/

### Stop tracking and start ignoring
```
git rm --cached <file/directory name>
# E.g. git rm --cached package.json
```
The ```--cached``` flag removes the files from the repository and leaves the local copies undisturbed. And the ```–r``` flag recursively removes the files inside the directory specified.

Now that we removed the files from the repo, Git thinks that the local copies of the deleted files are something new we added to the repo. So adding these file names to the ```.gitignore``` file will tell git to ignore these files and they won’t be pushed again.

### Show and filter branches
#### &nbsp;&nbsp;&nbsp;&nbsp;Show all local branches without (master|staging|pre-production)
```sh
git branch | grep -vE '(master|staging|pre-production)'
```

#### &nbsp;&nbsp;&nbsp;&nbsp;Get all local branches which contain 'c4b' and without 'C4B-586'
```sh
git branch | grep 'c4b' | grep -vE 'C4B-586'
```

### Delete filtered branches
#### &nbsp;&nbsp;&nbsp;&nbsp;Delete all local branches without (master|staging|pre-production)
```sh
git branch | grep -vE '(master|staging|pre-production)' | xargs git branch -D
```

### List branches and copy to clipboard
```sh
git branch | pbcopy
```
### Check if branch name exists?
```sh
git rev-parse --verify --quiet <branch_name>
```

# Commit - problem & solution
### Combining the commits
**To squash the last 3 commits into one:**
```sh
git reset --soft HEAD~3
git commit -m "New message for the combined commit"
```
**Pushing the squashed commit**

If the commits have been pushed to the remote:
```sh
git push origin +name-of-branch
```
The plus sign forces the remote branch to accept your rewritten history, otherwise you will end up with divergent branches

If the commits have NOT yet been pushed to the remote:
```sh
git push origin name-of-branch
```
In other words, just a normal push like any other. Source: https://gist.github.com/patik/b8a9dc5cd356f9f6f980

### Removing an entire commit
I call this operation "cherry-pit" since it is the inverse of a "cherry-pick". You must first identify the SHA of the commit you wish to remove. You can do this using gitk --date-order or using git log --graph --decorate --oneline You are looking for the 40 character SHA-1 hash ID (or the 7 character abbreviation). Yes, if you know the "^" or "~" shortcuts you may use those.

```sh
git rebase -p --onto SHA^ SHA
```

Obviously replace "SHA" with the reference you want to get rid of. The "^" in that command is literal.

However, please be warned. If some of the commits between SHA and the tip of your branch are merge commits, it is possible that git rebase -p will be unable to properly recreate them. Please inspect the resulting merge topology gitk --date-order HEAD ORIG_HEAD and contents to ensure that git did want you wanted. If it did not, there is not really any automated recourse. You can reset back to the commit before the SHA you want to get rid of, and then cherry-pick the normal commits and manually re-merge the "bad" merges. Or you can just suffer with the inappropriate topology (perhaps creating fake merges git merge --ours otherbranch so that subsequent development work on those branches will be properly merged in with the correct merge-base).
Ref: https://sethrobertson.github.io/GitFixUm/fixup.html

# gitignore & exclude
### Global git ignore
Add to Global Git ignore Mac
1. Create ```~/.gitignore_global``` file if not existed.
```sh
touch ~/.gitignore_global
```
2. Add .gitignore_global as the global gitignore file in your global git config
```sh
git config --global core.excludesfile ~/.gitignore_global
```
3. Update/Edit ignore items
```sh
vim ~/.gitignore_global
```
Sample:
```sh
tags
tags.temp
gems
*.svg
tmp/
*.cache
*.json
tps-main.js
*.min.*
*min.js
.DS_Store
.keep

```
### Exclude locally
In Git, you can exclude a file locally - i.e. only on the current computer.

Inside the ```.git``` folder for your project, there is a file ```/info/exclude```. This file has the exact same structure as a  ```.gitignore``` file, so you can add the file patterns for any files which must be excluded locally, inside that file.
for example, I want to exclude ```.rubycop.yml``` locally: 
in path: ```.git/info/exclude```
```
# git ls-files --others --exclude-from=.git/info/exclude
# Lines that start with '#' are comments.
# For a project mostly in C, the following would be a good set of
# exclude patterns (uncomment them if you want to use them):
# *.[oa]
# *~
# exclude .rubocop.yml
.rubocop.yml

```
source: https://www.jerriepelser.com/blog/exlude-git-files-locally/
#

## Git log
### Log format options
```
%H  - Commit hash
%h  - Abbreviated commit hash
%T  - Tree hashes
%t  - Abbreviated tree hash
%P  - Parent hashes
%p  - Abbreviated parent hashes
%an - Author name
%ae - Author email
%ad - Author date (format respects the --date=option)
%ar - Author date, relative
%cn - Committer name
%ce - Committer email
%cd - Committer date
%cr - Committer date, relative
%s  - Subject
%B  - Message
```
#
