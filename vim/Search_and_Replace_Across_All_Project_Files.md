### TL;DR:
The grep and cfdo commands let you easily perform search and replace across all files in a project. 
To replace the string original_string with new_string, run this in command mode.
```sh
# grep/ag/rg
:grep original_string
:cfdo %s/original_string/new_string/g | write
```
source: https://nithinbekal.com/posts/vim-search-replace/
