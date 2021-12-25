# Removing a .env file from Git history
I'm sure this happens to everyone sometimes. You accidentally pushed a file with secrets or a password that shouldn't have gotten into the Git history.

In the following example, I "accidentally" pushed my ```.env``` file to Git simply because I forgot to add it to me ```.gitignore``` file.

![T3V0EKt1o](https://user-images.githubusercontent.com/12711066/147387722-95267130-5cbf-4084-b826-998a8663536f.jpeg)

**Note: If you accidentally pushed secret keys to a repo, you should always revoke them and generate fresh keys!**

## Removing the file right away
The best thing to do now is to remove the file right away and add it to your ```.gitignore``` file.

In my case, I added the following to the ```.gitignore```.
```shell
# Secret file
.env
```
Let's try and push that to see what happens.

![RI8Em9uCt](https://user-images.githubusercontent.com/12711066/147387743-609653c1-e5a6-43ff-9633-59ec1c6952c3.jpeg)

Gitignore doesn't work on existing files

Yep, the ```.gitignore``` file doesn't untracked already committed changes. So how can we fix this now?

## Removing a file from Git only
You can remove a file from Git by running the following command.
```shell
git rm -r --cached .env
```
If we then push this change, you will see that the file is gone in GitHub.

![MPGXB39KG](https://user-images.githubusercontent.com/12711066/147387760-1f67c1b9-596a-415a-9ad9-f758dce97cb0.jpeg)

However, this didn't completely solve our issue. If we look at our Git history, we can still find the file and expose the secrets!

![VVukCpfUd](https://user-images.githubusercontent.com/12711066/147387776-481a8f2c-5710-4b6b-8ffd-1dfaba746fbf.jpeg)

## Completely remove a file from Git history
To remove the file altogether, we can use the following command.
```shell
git filter-branch --index-filter "git rm -rf --cached --ignore-unmatch .env" HEAD
```
You will get some warnings about this messing up your history as this goes through your whole history and 100% removes its occurrence.

To push this, you have to run the following command.
```shell
git push --force
```
If we look at our history, we can still see the commits that include this ```.env``` file, but the content is empty.

![p840Qj48P](https://user-images.githubusercontent.com/12711066/147387804-76c07f53-9cba-4651-a91b-381fed81f158.jpeg)

Few, thanks for having our back Git!

You can find the repo it tried this in on GitHub.

Source: https://h.daily-dev-tips.com/removing-a-env-file-from-git-history
