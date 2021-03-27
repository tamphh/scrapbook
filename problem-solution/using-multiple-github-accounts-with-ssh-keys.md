
# Problem
I have two Github accounts: *oanhnn* (personal) and *superman* (for work).
I want to use both accounts on same computer (without typing password everytime, when doing git push or pull).

# Solution
Use ssh keys and define host aliases in ssh config file (each alias for an account).

# How to?
## Method #1
1. [Generate ssh key pairs for accounts](https://help.github.com/articles/generating-a-new-ssh-key/) and [add them to GitHub accounts](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/).
2. Edit/Create ssh config file (`~/.ssh/config`):

   ```conf
   # Default github account: oanhnn
   Host github.com
      HostName github.com
      IdentityFile ~/.ssh/oanhnn_private_key
      IdentitiesOnly yes
      
   # Other github account: superman
   Host github-superman
      HostName github.com
      IdentityFile ~/.ssh/superman_private_key
      IdentitiesOnly yes
   ```
   
3. [Add ssh private keys to your agent](https://help.github.com/articles/adding-a-new-ssh-key-to-the-ssh-agent/):

   ```shell
   $ ssh-add ~/.ssh/oanhnn_private_key
   $ ssh-add ~/.ssh/superman_private_key
   ```

4. Test your connection

   ```shell
   $ ssh -T git@github.com
   $ ssh -T git@github-superman
   ```

   With each command, you may see this kind of warning, type `yes`:

   ```shell
   The authenticity of host 'github.com (192.30.252.1)' can't be established.
   RSA key fingerprint is xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:
   Are you sure you want to continue connecting (yes/no)?
   ```

   If everything is OK, you will see these messages:

   ```shell
   Hi oanhnn! You've successfully authenticated, but GitHub does not provide shell access.
   ```
   
   ```shell
   Hi superman! You've successfully authenticated, but GitHub does not provide shell access.
   ```

5. Now all are set, just clone your repositories

   ```shell
   $ git clone git@github-superman:org2/project2.git /path/to/project2
   $ cd /path/to/project2
   $ git config user.email "superman@org2.com"
   $ git config user.name  "Super Man"
   ```

Done!

## Method #2:
### 1. Generate SSH keys
When we create SSH keys on our machine, it automatically generates some files and configurations for us. In this tutorial, we will assume you haven't set up any SSH keys yet.

We get started with the command that will generate the first key:
```sh
ssh-keygen -t rsa
```
You will be prompted and asked to enter the folder/file name you want to go with. Press ENTER to go with the default location and generate the ***~/.ssh*** folder.

You now have a ***~/.ssh*** folder, with the just created SSH key. Let's use this default key for our personal account.

Next up is creating a key for our work account. (You can repeat this process for as many keys as necessary) And for this we will have to ***specify the key with some flags***. ```-C``` adds a comment/tag and ```-f``` specifies the name of the file we want to save the key to.

Go into your ***~/.ssh*** folder:
```sh
cd ~/.ssh
```

And create your next key with custom flags.
```sh
ssh-keygen -t rsa -C "email@githubworkemail.com" -f "id_rsa_workname"
```
To dive deeper, here is a list of the different flags you can add:
https://www.ssh.com/ssh/keygen/#command-and-option-summary

To double-check that all of your keys are there, type:
```sh
ls ~/.ssh
```
### 2. Create a config to manage multiple keys
Now that we have created our keys, we need a configuration file that knows which key to use when we access a repo of one of our GitHub accounts.

For this inside our ***~/.ssh*** folder, we create and open a ***config*** file.
```sh
touch ~/.ssh/config && code ~/.ssh/config
```
In here we define our different accounts:
```yaml
# personal account
Host github.com
   HostName github.com
   User git
   IdentityFile ~/.ssh/id_rsa

# work account 1
Host github.com-workname
   HostName github.com
   User git
   IdentityFile ~/.ssh/id_rsa_workname
```
***Two things are important to note here:***

The host, which we will need to remember later when we get our SSH links from GitHub.
```sh
Host github.com-workname
```
and the identity file, to make sure it points to the correct SSH key that we created before.
```sh
IdentityFile ~/.ssh/id_rsa_workname
```
### 3. Register our ssh-agent
Now to keep track of our different SSH keys and their configurations, there is a service called "ssh-agent". It is essentially the key manager for SSH.

For our purposes, we need to know 3 different commands.
```sh
ssh-add -D              // removes all currently registered ssh keys from the ssh-agent
ssh-add -l              // lists all currently in the ssh-agent registered ssh keys
ssh-add ~/.ssh/id_rsa   // adds the specified key to the ssh-agent
```
If you haven't configured any keys previously your ssh-agent has most likely not registered any keys, but let's be completely sure and run:
```sh
ssh-add -D              // removes all currently registered ssh keys from the ssh-agent
```
Next up is registering our keys with their ids:
```sh
ssh-add ~/.ssh/id_rsa && ssh-add ~/.ssh/id_rsa_workname
```
***Done!*** With this, our local machine is set up and all that is left to do is to register our keys in GitHub and clone our first repo!
### 4. Add the SSH keys to your GitHub accounts
There are two steps to this. First, copy the correct key and second, add the key in your dashboard on GitHub.

***1. Copying the correct key.***
This will copy your ***public key*** to your clipboard
```sh
 pbcopy < ~/.ssh/id_rsa.pub
```

***2. Add the key in your dashboard at https://github.com/settings/keys.***

Login into your work GitHub account and repeat this process with your another SSH key.

### 5. Clone your repo
> ***Important to note!*** The reason why your computer knows which SSH key to use, is because we defined the URL in our config file.
This means that for our work repositories, when we clone a repo from the account, url like so: *git@github.com:tamphh/repo.git*

We have to change the URL from:

git@***github.com***:workname/repo.git ==> git@***github.com-workname***:workname/repo.git

The same URL we have previously defined in our ~/.ssh/config file.
```sh
Host github.com-workname  // HERE
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_rsa_workname
```
With this, you can now clone your repositories and get going! Back to coding, I'd say!
That’s it!

# Reference

Source: https://gist.github.com/oanhnn/80a89405ab9023894df7

Further reading: [How to manage multiple GitHub accounts on your local machine](https://dev.to/codetraveling/how-to-manage-multiple-github-accounts-on-your-local-machine-3gj0)
