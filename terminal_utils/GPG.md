# Encrypt/Decrypt With GPG
```brew install gnupg``` if needed

### Encrypt/Decrypt file without keys
```sh
# Encrypt
gpg -c --cipher-algo AES256 --no-symkey-cache --output test.asc test.zip 

# Decrypt
gpg --decrypt --no-symkey-cache --output test.zip test.asc
```
Source: https://dev.to/efe/how-to-use-gnupg-for-encrypting-files-on-macos-2kke
