# Running Rubocop Only On Modified Files
If you are using Rubocop as a code analyzer and following its guidelines as a standard for your project, then like me you also might have faced the annoyance of running Rubocop on each and every modified file individually. Its boring and a little time consuming as well. Hence, its lot more productive to run it only on the updated files and for once.
There are two ways to run Rubocop on modified files:

## [1] Before committing
To view the list of files that have been modified, you can do:
```sh
git ls-files -m
```
This lists all the modified files regardless of the extensions as well as the deleted files. To exclude deleted files you can do:
```sh
git ls-files -m | xargs ls -1 2>/dev/null
```
Again, if you wish to view only the modified files with .rb extension, you can do:
```sh
git ls-files -m | xargs ls -1 2>/dev/null | grep '\.rb$'
```
Hence, the final command to run Rubocop for modified files is:
```sh
git ls-files -m | xargs ls -1 2>/dev/null | grep '\.rb$' | xargs rubocop
```

## [2] After committing
There are two ways to view the list of changed files after you have committed. First is to compare the changes with master or you can compare it with the current upstream.
To compare with master:
```sh
git diff-tree -r --no-commit-id --name-only head origin/master
```
To compare with current upstream:
```sh
git diff-tree -r --no-commit-id --name-only @\{u\} head
```
_Note: This won’t work if you haven’t yet set up a remote branch._
Hence, the file command to run Rubocop for modified files is:
```sh
git diff-tree -r --no-commit-id --name-only head origin/master | xargs rubocop
```
or
```sh
git diff-tree -r --no-commit-id --name-only @\{u\} head | xargs rubocop
```
With this, you will be saving quite a time. To top if off, you can also create aliases for these.
source: https://medium.com/devnetwork/running-rubocop-only-on-modified-files-a21aed86e06d
