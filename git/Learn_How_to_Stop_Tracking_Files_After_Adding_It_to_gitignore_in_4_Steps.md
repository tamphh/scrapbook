# Learn How to Stop Tracking Files After Adding It to .gitignore in 4 Steps
source: https://hackernoon.com/learn-how-to-stop-tracking-files-after-adding-it-to-gitignore-in-4-steps?source=rss

When we track a file in git, it can sometimes get cached and remain tracked, even if we add it to our `.gitignore` file. This is simply because .gitignore prevents files from being added to Git's tracking system, but it will not actively remove those that are already tracked.

This can lead to issues when you have something you no longer want to be tracked, but can't seem to remove from your git repository.

Fortunately, there is an easy way to fix this. `git` has a built-in `rm` function which lets us remove cached or tracked changes. To run it, you can use the following command to remove a specific file, where `[filename]` can be removed with the file you wish to stop tracking:

```sh
git rm --cached [filename]
```

Similarly, if an entire directory needs to be removed, use the `-r` flag which means recursive, to remove an entire directory and everything within it from tracking:

```sh
git rm -r --cached [directory]
```

After running this command, you can then add amend your commit and push it to your remote:

```sh
git add .
git commit -m "Removed tracked files which shouldn't be tracked"
git push
```

**NOTE:** 

This will not remove files from your local computer, but it will remove the tracking of files from your git repository.

It will also remove files from other developers, computers, or servers upon your next git pull.

Be careful with this command!










