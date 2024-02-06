[![Cover image for Remove merged branches from your local machine](https://media.dev.to/cdn-cgi/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fc45zlonke5sq5pa37qbj.jpg)](https://media.dev.to/cdn-cgi/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fc45zlonke5sq5pa37qbj.jpg)

[![Image description](https://media.dev.to/cdn-cgi/image/width=800%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fmkjtthqq993po9j5elzs.jpg)](https://media.dev.to/cdn-cgi/image/width=800%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fmkjtthqq993po9j5elzs.jpg)

## [](https://dev.to/wagenrace/remove-merged-branches-from-your-local-machine-5737?ref=dailydev#remove-merged-branches-from-your-local-machine)Remove merged branches from your local machine

If you work with a remote Git repository, you might encounter a situation where you still have branches on your local machine, but those branches have been removed from the remote repository.

-   Open a bash terminal (if you are on Windows you will have git bash. CMD, and PowerShell will not work).
    
-   Run the following command:  
    

```
    git fetch <span>-p</span> <span>&amp;&amp;</span> git branch <span>-vv</span> | <span>awk</span> <span>'/: gone]/{print $1}'</span> | xargs git branch <span>-d</span>
```

Let’s break down the command:

git fetch -p: This command fetches the branches and their commits from the remote repository to your local repository. The -p or --prune option removes any remote-tracking references (i.e., origin/branch-name) to branches that have been deleted on the remote repository.

`&&`: This is a logical AND operator. In the context of command-line operations, it means “execute the following command only if the previous command succeeded.”

`git branch -vv`: This command lists all local branches and their upstream branches. If a local branch’s upstream branch has been deleted, it will show \[gone\] next to it.

[![An example where  raw `deleted-branch` endraw  is deleted,  raw `only-local-branch` endraw  was never pushed to the remote repository, and  raw `main` endraw  and  raw `test-branch` endraw  are both local and remote.](https://media.dev.to/cdn-cgi/image/width=800%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2F4i2d56rhqqwhju4g2qyb.png)](https://media.dev.to/cdn-cgi/image/width=800%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2F4i2d56rhqqwhju4g2qyb.png)  
_An example where `deleted-branch` is deleted, `only-local-branch` was never pushed to the remote repository, and `main` and `test-branch` are both local and remote._

`|awk '/:gone]/{print $1}'`: This part of the command pipes (|) the output of the previous command to awk, a text processing utility. The awk command is programmed to match lines containing `:gone]` and print the first field ($1) of those lines, which is the branch name.

[![The result of command so far given me only  raw `deleted-branch` endraw ](https://media.dev.to/cdn-cgi/image/width=800%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fth99z8egahzsaja9om72.png)](https://media.dev.to/cdn-cgi/image/width=800%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fth99z8egahzsaja9om72.png)  
_The result of `git fetch -p && git branch -vv | awk ‘/: gone]/{print $1}’` given me only `deleted-branch`_

`| xargs git branch -d`: This part of the command pipes the output of the previous command (i.e., the names of the branches to be deleted) to xargs, which executes the git branch `-d` command for each input. The `git branch -d` command deletes a branch.

So, in summary, this command fetches updates from the remote repository, identifies local branches whose upstream branches have been deleted, and deletes those local branches.

## [](https://dev.to/wagenrace/remove-merged-branches-from-your-local-machine-5737?ref=dailydev#bonus)Bonus

This is the error if you try to run it **during** a merge

[![A screenshot showing the error message error: The branch 'branch name' is not fully merged.](https://media.dev.to/cdn-cgi/image/width=800%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fw15hc9rp7tqkzcamz6wy.png)](https://media.dev.to/cdn-cgi/image/width=800%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fw15hc9rp7tqkzcamz6wy.png)

source: https://dev.to/wagenrace/remove-merged-branches-from-your-local-machine-5737
