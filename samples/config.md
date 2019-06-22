#### git ssh config samle
Create/Edit ```~/.ssh/config```
```ruby
# Default github account: work
Host github.com
   HostName github.com
   AddKeysToAgent yes
   UseKeychain yes
   IdentityFile ~/.ssh/work/id_rsa
   IdentitiesOnly yes

# Thanos github account: thanos
Host github.com_thanos
   HostName github.com
   AddKeysToAgent yes
   UseKeychain yes
   IdentityFile ~/.ssh/thanos/id_rsa
   IdentitiesOnly yes
```
