# Learn How to Stop Tracking Files After Adding It to .gitignore in 4 Steps
source: https://hackernoon.com/learn-how-to-stop-tracking-files-after-adding-it-to-gitignore-in-4-steps?source=rss

When we track a file in git, it can sometimes get cached and remain tracked, even if we add it to our .gitignore file. This is simply because .gitignore prevents files from being added to Git's tracking system, but it will not actively remove those that are already tracked.

This can lead to issues when you have something you no longer want to be tracked, but can't seem to remove from your git repository.

Fortunately, there is an easy way to fix this. git has a built-in rm function which lets us remove cached or tracked changes. To run it, you can use the following command to remove a specific file, where [filename] can be removed with the file you wish to stop tracking:
